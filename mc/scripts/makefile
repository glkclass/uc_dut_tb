.ONESHELL:
SHELL=/bin/bash

-include env
export

-include user_env
export


DAY_HASH := ${shell date +%Y_%m_%d}
TIME_HASH := ${shell date +%H_%M_%S}
BACKUP_DIR = /tmp/oct640_backups/${DAY_HASH}/oct640_cu_mc_${TIME_HASH}

LOG ?= ${MC_LOG}

APP_BUILD_CONFIG ?= ${MC_APP_BUILD_CONFIG}


# tmp var to pass file to be compiled
COMPILE_FILE_NAME ?= ""

# rules
debug:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	python3  utils.py --task check_log_errors --log_file ${LOG}
	$(ECHO_FOOTER)

create_project:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p ${BACKUP_DIR}
	@rsync -a  ${ROOT_PATH} ${BACKUP_DIR}
	cd ${ROOT_PATH}
	git clean -qfxd
	cd scripts
	@rsync -a --ignore-missing-args ${BACKUP_DIR}/scripts/user_env user_env
	@echo "$(INFO_PREFIX) | See ${LOG}, 1 for details"
	@echo "$(INFO_PREFIX) | Build config: ${APP_BUILD_CONFIG}"
	vitis -s vitis_cli_task.py --task create_project --build_config ${APP_BUILD_CONFIG} &>> ${LOG}
	python3  utils.py --task check_log_errors --log_file ${LOG}
	@if [ $$? -ne 0 ]; then exit 1; fi
	$(ECHO_FOOTER)

compile_file:
	$(SETUP_TOOLS)
	echo ${MC_APP_INCLUDE}
	mb-gcc -DSDT -Wall -Wextra -pedantic -O2 -I ${MC_APP_INCLUDE} -c ${COMPILE_FILE_NAME}

build_app_ninja:
	$(SETUP_TOOLS)
	cd ${VITIS_WORKSPACE_PATH}/${MC_APP_NAME}/build
	ninja

clean_app_ninja:
	$(SETUP_TOOLS)
	cd ${VITIS_WORKSPACE_PATH}/${MC_APP_NAME}/build
	ninja clean

build_app_console:
	$(SETUP_TOOLS)
	vitis -s vitis_cli_task.py --task build_app

build_app:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	@echo "$(INFO_PREFIX) | See ${LOG}, 1 for details"
	vitis -s vitis_cli_task.py --task build_app &>> ${LOG}
	python3  utils.py --task check_log_errors --log_file ${LOG}
	@if [ $$? -ne 0 ]; then exit 1; fi
	$(ECHO_FOOTER)

load_elf:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	@echo "$(INFO_PREFIX) | See ${LOG}, 1 for details"
	vitis -s vitis_cli_task.py --task load_elf &>> ${LOG}
	python3  utils.py --task check_log_errors --log_file ${LOG}
	@if [ $$? -ne 0 ]; then exit 1; fi
	$(ECHO_FOOTER)

copy_elf_file:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	python3 utils.py --task copy_elf_file
	@if [ $$? -ne 0 ]; then exit 1; fi
	$(ECHO_FOOTER)
