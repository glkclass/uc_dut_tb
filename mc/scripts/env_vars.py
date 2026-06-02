import os
from pathlib import Path

VITIS_WORKSPACE_PATH = os.environ.get("VITIS_WORKSPACE_PATH", ".")
VITIS_SRC_PATH = os.environ.get("VITIS_SRC_PATH", ".")
MC_FIRMWARE_GITVERSION_HEADER = os.environ.get("MC_FIRMWARE_GITVERSION_HEADER", ".")

XSA_PLATFORM_FILE = os.environ.get("XSA_PLATFORM_FILE", ".")
ART_ELF_FOLDER = os.environ.get("ART_ELF_FOLDER", ".")

XSA_PLATFORM_OS = os.environ.get("XSA_PLATFORM_OS", None)
XSA_PLATFORM_CPU = os.environ.get("XSA_PLATFORM_CPU", None)
XSA_PLATFORM_OS_STDINOUT_DEBUG = os.environ.get("XSA_PLATFORM_OS_STDINOUT_DEBUG", None)
XSA_PLATFORM_OS_STDINOUT_RELEASE = os.environ.get(
    "XSA_PLATFORM_OS_STDINOUT_RELEASE", None
)
MC_APP_BUILD_DEFINES_DEBUG = os.environ.get("MC_APP_BUILD_DEFINES_DEBUG", None)
MC_APP_BUILD_DEFINES_RELEASE = os.environ.get("MC_APP_BUILD_DEFINES_RELEASE", None)

assert VITIS_WORKSPACE_PATH != ".", (
    "<VITIS_WORKSPACE_PATH> env variable is not defined. Terminated!"
)
assert VITIS_SRC_PATH != ".", (
    "<VITIS_SRC_PATH> env variable is not defined. Terminated!"
)
assert MC_FIRMWARE_GITVERSION_HEADER != ".", (
    "<MC_FIRMWARE_GITVERSION_HEADER> env variable is not defined. Terminated!"
)
assert XSA_PLATFORM_FILE != ".", (
    "<XSA_PLATFORM_FILE> env variable is not defined. Terminated!"
)
assert ART_ELF_FOLDER != ".", (
    "<ART_ELF_FOLDER> env variable is not defined. Terminated!"
)
assert XSA_PLATFORM_OS is not None, (
    "<XSA_PLATFORM_OS> env variable is not defined. Terminated!"
)
assert XSA_PLATFORM_CPU is not None, (
    "<XSA_PLATFORM_CPU> env variable is not defined. Terminated!"
)
assert XSA_PLATFORM_OS_STDINOUT_DEBUG is not None, (
    "<XSA_PLATFORM_OS_STDINOUT_DEBUG> env variable is not defined. Terminated!"
)
assert XSA_PLATFORM_OS_STDINOUT_RELEASE is not None, (
    "<XSA_PLATFORM_OS_STDINOUT_RELEASE> env variable is not defined. Terminated!"
)
assert MC_APP_BUILD_DEFINES_DEBUG is not None, (
    "<MC_APP_BUILD_DEFINES_DEBUG> env variable is not defined. Terminated!"
)
assert MC_APP_BUILD_DEFINES_RELEASE is not None, (
    "<MC_APP_BUILD_DEFINES_RELEASE> env variable is not defined. Terminated!"
)

MC_APP_BUILD_DEFINES_DEBUG = str(MC_APP_BUILD_DEFINES_DEBUG).split()
MC_APP_BUILD_DEFINES_RELEASE = str(MC_APP_BUILD_DEFINES_RELEASE).split()
XSA_PLATFORM_NAME = Path(XSA_PLATFORM_FILE).stem
MC_APP_NAME = f"{XSA_PLATFORM_NAME}_mc"
MC_APP_ELF_FILE_NAME = f"{MC_APP_NAME}.elf"
VITIS_APP_ELF_FILE = os.path.join(
    VITIS_WORKSPACE_PATH, MC_APP_NAME, "build", MC_APP_ELF_FILE_NAME
)
VIVADO_APP_ELF_FILE = os.path.join(ART_ELF_FOLDER, MC_APP_ELF_FILE_NAME)
