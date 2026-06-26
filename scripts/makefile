.ONESHELL:
SHELL=/bin/bash

-include env
export

-include user_env
export

# generate backup folder unic name
DAY_HASH := ${shell date +%Y_%m_%d}
TIME_HASH := ${shell date +%H_%M_%S}
BACKUP_DIR = /tmp/oct640_backups/${DAY_HASH}/oct640_cu_${TIME_HASH}

# generate absolute log path to have same log file for all make processes (including childs ..)
PWD_PATH  := ${shell pwd}
LOG  := ${PWD_PATH}/${LOG}


# rules

# debug: clean_log impl generate_bitstream copy_bin_file
# debug: clean_log mc_create_release_project mc_copy_elf_file
debug: program_uart_flash
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
# 	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)


clean_log:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@rm -f *.log
	$(ECHO_FOOTER)


clean:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p ${BACKUP_DIR}
	@rsync -a ${ROOT_PATH} ${BACKUP_DIR}
	cd ${ROOT_PATH}
	git clean -qfxd
	@rsync -a --ignore-missing-args ${BACKUP_DIR}/.zed .
	cd scripts
	@rsync -a --ignore-missing-args ${BACKUP_DIR}/scripts/user_env .  										#  restore user env variables override
	@rsync -a --ignore-missing-args ${BACKUP_DIR}/mc/scripts/user_env ${MC_ROOT_PATH}/scripts/user_env  	#  restore mc user env variables override
	$(ECHO_FOOTER)

# rtl/mc complex rules
build_mc_load_elf: clean_log mc_build_app mc_load_elf
build_mc_gen_hw_bin: clean_log mc_build_app mc_copy_elf_file generate_bitstream copy_bin_file
build_mc_gen_hw_bin_load_fpga: clean_log build_mc_gen_hw_bin load_fpga
build_mc_gen_hw_bin_program_flash: clean_log build_mc_gen_hw_bin program_flash

create_mc_gen_hw_bin: clean_log mc_create_release_project mc_copy_elf_file generate_bitstream copy_bin_file

build_release_soc: clean_log synth generate_platform mc_create_release_project mc_copy_elf_file impl generate_bitstream copy_bin_file
build_debug_soc: clean_log synth generate_platform mc_create_debug_project mc_copy_elf_file impl generate_bitstream copy_bin_file

create_build_rls_soc: clean_log create_vivado_project build_release_soc
create_build_dbg_soc: clean_log create_vivado_project build_debug_soc


# dut_tb rules
dtb_build:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make build

dtb_run:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make run_tb

dtb_clean:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make clean

dtb_debug:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make debug


# mc rules
mc_create_debug_project:
	@export APP_BUILD_CONFIG=DEBUG
	@cd ${MC_ROOT_PATH}/scripts
	@make create_project
	@if [ $$? -ne 0 ]; then echo "ERROR | ..Failed. Terminated due to error(s). See log for details: ${LOG}, 1."; exit 1; fi

mc_create_release_project:
	@export APP_BUILD_CONFIG=RELEASE
	@cd ${MC_ROOT_PATH}/scripts
	@make create_project
	@if [ $$? -ne 0 ]; then echo "ERROR | ..Failed. Terminated due to error(s). See log for details: ${LOG}, 1."; exit 1; fi

mc_build_app_ninja:
	@cd ${MC_ROOT_PATH}/scripts
	@make build_app_ninja

mc_build_app_console:
	@cd ${MC_ROOT_PATH}/scripts
	@make build_app_console

mc_build_app:
	@cd ${MC_ROOT_PATH}/scripts
	@make build_app
	@if [ $$? -ne 0 ]; then echo "ERROR | ..Failed. Terminated due to error(s). See log for details: ${LOG}, 1."; exit 1; fi

mc_copy_elf_file:
	@cd ${MC_ROOT_PATH}/scripts
	@make copy_elf_file
	@if [ $$? -ne 0 ]; then echo "ERROR | ..Failed. Terminated due to error(s). See log for details: ${LOG}, 1."; exit 1; fi

mc_load_elf:
	@cd ${MC_ROOT_PATH}/scripts
	@make load_elf
	@if [ $$? -ne 0 ]; then echo "ERROR | ..Failed. Terminated due to error(s). See log for details: ${LOG}, 1."; exit 1; fi

mc_clean:
	@cd ${MC_ROOT_PATH}/scripts
	@make clean_app_ninja

mc_debug:
	@cd ${MC_ROOT_PATH}/scripts
	@make debug

# rtl rules
update_vivado_project: clean_log
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p ${BACKUP_DIR}
	@rsync -a ${ROOT_PATH} ${BACKUP_DIR}
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

create_vivado_project: clean
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

synth:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

impl:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

generate_impl_artefacts:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

generate_platform:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

generate_bitstream:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

copy_bin_file:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	echo "INFO | Copy ${VIVADO_BIN_STREAM} to ${ART_BIN_FOLDER}"
	cp -r ${VIVADO_BIN_STREAM} ${ART_BIN_FOLDER}
	$(ECHO_FOOTER)

load_fpga:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

program_flash:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t program_flash
	$(ECHO_FOOTER)

program_n_flash: clean_log
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t program_n_flash
	$(ECHO_FOOTER)

hw_debug: clean_log
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t debug
	$(ECHO_FOOTER)

# py rules
program_uart_flash:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@cd ${AM_SERIAL_SCRIPTS_ROOT_PATH}
	python3 am_serial_fc.py --flash_type Config --file ${abspath ${PROGRAM_BIN_STREAM}} --port ${AM_SERIAL_PORT}
	$(ECHO_FOOTER)
