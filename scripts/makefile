.ONESHELL:
SHELL=/bin/bash

-include config.env
export

-include user.env
export


# generate backup folder unic name
DAY_HASH := ${shell date +%Y_%m_%d}
TIME_HASH := ${shell date +%H_%M_%S}
BACKUP_DIR = /tmp/oct640_backups/${DAY_HASH}/oct640_cu_${TIME_HASH}

# generate absolute log path to have same log file for all make processes (including childs ..)
PWD_PATH  := ${shell pwd}
LOG  := ${PWD_PATH}/${LOG}


# rules

debug: clean_log program_aes_key_vivado
# 	clean_log upload_fpga_vivado
# 	clean_log program_aes_key_vivado
# 	clean_log generate_aes_bitstream copy_bin_file
# 	source flash_spi_interface_env
# 	@cd ${MC_ROOT_PATH}/scripts
# 	@make debug


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
	#  restore user.env variables override
	@rsync -a --ignore-missing-args ${BACKUP_DIR}/scripts/user.env .
	#  restore mc user.env variables override
	@rsync -a --ignore-missing-args ${BACKUP_DIR}/mc/scripts/user.env ${MC_ROOT_PATH}/scripts/user.env
	$(ECHO_FOOTER)

# rtl/mc complex rules
upload_fpga: upload_fpga_ofp_loader
upload_config_flash: upload_config_flash_ofp_loader

build_mc_upload_elf: clean_log mc_build_app mc_upload_elf
build_mc_gen_hw_bin: clean_log mc_build_app mc_copy_elf_file generate_bitstream copy_bin_file
build_mc_gen_hw_bin_upload_fpga: clean_log build_mc_gen_hw_bin upload_fpga
build_mc_gen_hw_bin_upload_config_flash: clean_log build_mc_gen_hw_bin upload_config_flash

create_mc_rls_project_gen_hw_bin: clean_log mc_create_release_project mc_copy_elf_file generate_bitstream copy_bin_file
create_mc_dbg_project_gen_hw_bin: clean_log mc_create_debug_project mc_copy_elf_file generate_bitstream copy_bin_file

build_release_soc: clean_log synth generate_platform mc_create_release_project mc_copy_elf_file impl generate_bitstream copy_bin_file
build_debug_soc: clean_log synth generate_platform mc_create_debug_project mc_copy_elf_file impl generate_bitstream copy_bin_file


# dut_tb rules
dtb_build:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make build_tb

dtb_elab:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make elab_tb

dtb_run:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make run

dtb_view:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make view

dtb_clean:
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make clean

dtb_debug:dtb_run dtb_view
	@cd ${DUT_TB_ROOT_PATH}/scrpt
	@make debug


# mc rules
mc_create_debug_project:
	@source flash_spi_interface.env
	@export APP_BUILD_CONFIG=DEBUG
	@cd ${MC_ROOT_PATH}/scripts
	@make create_project
	@if [ $$? -ne 0 ]; then echo "ERROR | ..Failed. Terminated due to error(s). See log for details: ${LOG}, 1."; exit 1; fi

mc_create_release_project:
	@source flash_spi_interface.env
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

mc_upload_elf:
	@cd ${MC_ROOT_PATH}/scripts
	@make upload_elf
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
	@source flash_spi_interface.env
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

generate_aes_bitstream:
	$(ECHO_TOOLS_HEADER)
	$(SETUP_TOOLS)
	@source flash_spi_interface.env
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

copy_bin_file:
	$(ECHO_HEADER)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_fpga_vivado:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_config_flash_vivado:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_n_config_flash_vivado: clean_log
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

program_aes_key_vivado:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

detect_jtag_targets: clean_log
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_fpga_ofp_loader:
	$(ECHO_HEADER)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_config_flash_ofp_loader:
	$(ECHO_HEADER)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_settings_flash_ofp_loader:
	$(ECHO_HEADER)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

upload_config_settings_flash_ofp_loader:
	$(ECHO_HEADER)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

combine_config_settings_bin_files:
	$(ECHO_HEADER)
	source vivado_cli.sh -t $@
	$(ECHO_FOOTER)

# py rules
upload_config_flash_uart:
	$(ECHO_HEADER)
	@cd ${AM_SERIAL_SCRIPTS_ROOT_PATH}
	python3 am_serial_fc.py --flash_type Config --file ${abspath ${PROGRAM_BIN_STREAM}} --port ${AM_SERIAL_PORT}
	$(ECHO_FOOTER)
