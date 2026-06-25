import argparse
import json
import logging
import os
import re
import shutil
import subprocess
from pathlib import Path

import vitis
import xsdb
from env_vars import (
    MC_APP_BUILD_DEFINES_DEBUG,
    MC_APP_BUILD_DEFINES_RELEASE,
    MC_APP_NAME,
    VITIS_APP_ELF_FILE,
    VITIS_SRC_PATH,
    VITIS_WORKSPACE_PATH,
    XSA_PLATFORM_CPU,
    XSA_PLATFORM_FILE,
    XSA_PLATFORM_NAME,
    XSA_PLATFORM_OS,
    XSA_PLATFORM_OS_STDINOUT_DEBUG,
    XSA_PLATFORM_OS_STDINOUT_RELEASE,
)
from utils import generate_gitversion_header, generate_flash_type_header

logging.basicConfig(
    level=logging.DEBUG,
    style="{",
    format="{asctime} {levelname} | {message} | {pathname}, {lineno}",
    datefmt="%H:%M:%S",
)

log = logging.getLogger()
log.setLevel(logging.INFO)


def debug():
    generate_gitversion_header()


def create_project(args):
    # check for dumb
    assert os.path.isfile(XSA_PLATFORM_FILE), (
        f"Wrong path to XSA platform file: {XSA_PLATFORM_FILE}!"
    )
    assert os.path.isdir(VITIS_SRC_PATH), f"Wrong path to src folder: {VITIS_SRC_PATH}!"

    generate_gitversion_header()
    generate_flash_type_header()

    log.info(f"Prepare env..")

    if os.path.isdir(VITIS_WORKSPACE_PATH):
        log.debug(f"Remove existing workspace : {VITIS_WORKSPACE_PATH}..")
        shutil.rmtree(VITIS_WORKSPACE_PATH)

    client = vitis.create_client()
    try:
        log.debug(f"Set up workspace: {VITIS_WORKSPACE_PATH}..")
        client.set_workspace(path=VITIS_WORKSPACE_PATH)

        log.debug(f"Create platform: {XSA_PLATFORM_NAME} based on {XSA_PLATFORM_FILE}..")
        platform = client.create_platform_component(
            name=XSA_PLATFORM_NAME,
            hw_design=XSA_PLATFORM_FILE,
            os=XSA_PLATFORM_OS,
            cpu=XSA_PLATFORM_CPU,
        )
        platform.report()

        log.debug(f"Apply {XSA_PLATFORM_NAME} settings ..")
        domain_name = platform.list_domains()[0]["domain_name"]
        domain = platform.get_domain(domain_name)
        if args.build_config in ["DEBUG"]:
            domain.set_config(
                option="os",
                param="standalone_stdin",
                value=XSA_PLATFORM_OS_STDINOUT_DEBUG,
            )
            domain.set_config(
                option="os",
                param="standalone_stdout",
                value=XSA_PLATFORM_OS_STDINOUT_DEBUG,
            )
        elif args.build_config in ["RELEASE", "RELEASE_DEBUG"]:
            domain.set_config(
                option="os",
                param="standalone_stdin",
                value=XSA_PLATFORM_OS_STDINOUT_RELEASE,
            )
            domain.set_config(
                option="os",
                param="standalone_stdout",
                value=XSA_PLATFORM_OS_STDINOUT_RELEASE,
            )
        else:
            assert False, "Non supported config"

        log.info(f"Build platform: {XSA_PLATFORM_NAME}..")
        platform.build()
        log.info("..Done")

        log.debug(
            f"Create application {MC_APP_NAME} based on platform: {XSA_PLATFORM_NAME}.."
        )
        platform = client.find_platform_in_repos(XSA_PLATFORM_NAME)
        app = client.create_app_component(name=MC_APP_NAME, platform=platform)

        log.debug(f"Import sources form {VITIS_SRC_PATH}..")
        app.import_files(from_loc=VITIS_SRC_PATH, is_skip_copy_sources=True)

        log.debug(f"Apply {MC_APP_NAME} build defines ..")
        if "DEBUG" == args.build_config:
            log.debug(MC_APP_BUILD_DEFINES_DEBUG)
            app.append_app_config(
                key="USER_COMPILE_DEFINITIONS", values=MC_APP_BUILD_DEFINES_DEBUG
            )
            app.set_app_config(key="USER_COMPILE_DEBUG_LEVEL", values="-g3")
            app.set_app_config(key="USER_COMPILE_OPTIMIZATION_LEVEL", values="-O0")
        elif "RELEASE" == args.build_config:
            log.debug(MC_APP_BUILD_DEFINES_RELEASE)
            app.append_app_config(
                key="USER_COMPILE_DEFINITIONS", values=MC_APP_BUILD_DEFINES_RELEASE
            )
            app.set_app_config(key="USER_COMPILE_DEBUG_LEVEL", values="-g0")
            app.set_app_config(key="USER_COMPILE_OPTIMIZATION_LEVEL", values="-O3")
        else:
            assert False, "Non supported config"

        log.debug(app.get_app_config())

        log.info(f"Build application: {MC_APP_NAME}..")
        app.build()
        log.info("..Done")

    except Exception as e:
        log.error(f"!!! An error occurred during the script execution: {e} !!!")
    finally:
        vitis.dispose()
        log.debug("Vitis client disposed. Finished.")


def build_app(args):
    # check for dumb
    assert os.path.isdir(VITIS_WORKSPACE_PATH), f"No workspace: {VITIS_WORKSPACE_PATH}!"

    client = vitis.create_client()
    try:
        log.info(f"Prepare env..")

        log.debug(f"Set up workspace: {VITIS_WORKSPACE_PATH}..")
        client.set_workspace(path=VITIS_WORKSPACE_PATH)

        log.debug(f"Remove outdated elfs : {VITIS_APP_ELF_FILE} ..")
        if os.path.isfile(VITIS_APP_ELF_FILE):
            os.remove(VITIS_APP_ELF_FILE)

        log.debug(f"Get application {MC_APP_NAME}..")
        app = client.get_component(name=MC_APP_NAME)

        log.info(f"Build application: {MC_APP_NAME} ..")
        app.build()
        log.info("..Done")

    except Exception as e:
        log.error(f"!!! An error occurred during the script execution: {e} !!!")
    finally:
        vitis.dispose()
        log.debug("Vitis client disposed. Finished.")


def load_elf(args):
    """
    Upload elf to already running Mb using xsdb tools
    """
    try:
        log.info("Load elf binary..")
        # xsdb.help("functions")
        xsdb_logger = logging.getLogger("XSDB-TCF")
        xsdb_logger.setLevel(logging.INFO)
        s = xsdb.start_debug_session()
        xsdb._logger.init_logger(logging.INFO)
        s.connect(url="tcp:127.0.0.1:3121")
        s.targets(3)  # setup Microblaze as target
        s.stop()  # not sure we need it
        s.dow(VITIS_APP_ELF_FILE)  # upload elf binary
        s.rst()
        s.con()  # resume running
        xsdb.dispose()
        log.info("..Done")
    except Exception as e:
        log.error(f"!!! An error occurred during the script execution: {e} !!!")
    finally:
        log.debug("Finished.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Vitis Build Automation")
    parser.add_argument(
        "--task",
        required=True,
        help="Task to execute",
        choices=["create_project", "build_app", "load_elf", "debug"],
    )

    parser.add_argument(
        "--build_config",
        default="RELEASE",
        help="Build configuration (Release or Debug)",
        choices=["RELEASE", "DEBUG"],
    )

    args, unknown = parser.parse_known_args()

    log.debug(f"Vitis task to execute: {args.task}")

    if args.task == "create_project":
        log.debug(f"Build config: {args.build_config}")

    exec(f"{args.task}(args)")
