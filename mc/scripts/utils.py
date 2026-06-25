import argparse
import json
import logging
import os
import re
import shutil
import subprocess

from env_vars import (
    ART_ELF_FOLDER,
    MC_APP_ELF_FILE_NAME,
    MC_FIRMWARE_GITVERSION_HEADER,
    MC_FIRMWARE_FLASH_TYPE_HEADER,
    FLASH_SPI_INTERFACE,
    VITIS_APP_ELF_FILE,
)

logging.basicConfig(
    level=logging.DEBUG,
    style="{",
    format="{asctime} {levelname} | {message} | {pathname}, {lineno}",
    datefmt="%H:%M:%S",
)

log = logging.getLogger()


def generate_flash_type_header():
    with open(MC_FIRMWARE_FLASH_TYPE_HEADER, "w") as f:
        if "SPIx4" == FLASH_SPI_INTERFACE:
            f.write(f"#define FLASH_SPIX4\n")
        elif "SPIx1" == FLASH_SPI_INTERFACE:
            f.write(f"#define FLASH_SPIX1\n")


def generate_gitversion_header():
    clean_env = os.environ.copy()
    spoiled_vars = ["LD_LIBRARY_PATH", "LIBRARY_PATH", "PYTHONPATH"]
    for var in spoiled_vars:
        clean_env.pop(var, None)

    try:
        gitversion = (
            subprocess.check_output(["dotnet-gitversion"], env=clean_env)
            .decode("ascii")
            .strip()
        )
    except Exception:
        gitversion = "DEADDEAD"

    assert isinstance(gitversion, str), "Can't get gitversion!"

    gitversion = json.loads(gitversion)
    with open(MC_FIRMWARE_GITVERSION_HEADER, "w") as f:
        f.write(f"#define FIRMWARE_VERSION_MAJOR {gitversion.get('Major', 255)}\n")
        f.write(f"#define FIRMWARE_VERSION_MINOR {gitversion.get('Minor', 255)}\n")
        f.write(f"#define FIRMWARE_VERSION_PATCH {gitversion.get('Patch', 255)}\n")
        f.write(
            f'#define FIRMWARE_INFORMATIONAL_VERSION "{gitversion.get("InformationalVersion", "None")}"\n'
        )


def copy_elf_file(args):
    try:
        assert os.path.isdir(ART_ELF_FOLDER), f"No such folder : {ART_ELF_FOLDER}!"
        art_elf_file = os.path.join(ART_ELF_FOLDER, MC_APP_ELF_FILE_NAME)
        if os.path.exists(art_elf_file):
            os.remove(art_elf_file)
        assert os.path.isfile(VITIS_APP_ELF_FILE), (
            f"No elf file detected : {VITIS_APP_ELF_FILE}!"
        )
        log.info(f"Copy build artefacts: {VITIS_APP_ELF_FILE} to {art_elf_file} ..")
        shutil.copy(VITIS_APP_ELF_FILE, ART_ELF_FOLDER)
        log.info("..Done")

    except Exception as e:
        log.error(f"!!! An error occurred during the script execution: {e} !!!")
        exit(1)


def check_log_errors(args):
    """
    Check log for errors. Exit with error code if errors are found.
    """
    regex_pattern = r"(( ERROR )|(\[ERROR\])|(FAILED:)|(AssertionError)).*"
    pattern = re.compile(regex_pattern)
    num_errors = 0
    with open(args.log_file, "r") as file:
        for line_num, line in enumerate(file, 1):
            if pattern.search(line):
                log.error(f"{line.strip()} at {args.log_file}, {line_num}")
                num_errors += 1
    if num_errors > 0:
        log.error(f"See log for details: {args.log_file}, {line_num}")
        exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Vitis Build Automation")
    parser.add_argument(
        "--task",
        required=True,
        help="Task to execute",
        choices=["copy_elf_file", "check_log_errors"],
    )

    parser.add_argument("--log_file", default="scripts.log", help="Log file name")

    args, unknown = parser.parse_known_args()

    exec(f"{args.task}(args)")
