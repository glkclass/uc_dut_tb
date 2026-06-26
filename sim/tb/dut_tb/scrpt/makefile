.ONESHELL:
SHELL=/bin/bash

-include env
export

-include user_env
export

LOG ?= $(TB_LOG)

build_tb: dutb glbl ip_cores rtl dut_tb
elab_tb: build_tb elab
run_tb: elab_tb run


# rules
debug: view
	$(ECHO_HEADER)


clean:
	$(ECHO_HEADER)
	@echo "Cleanup.."
	rm -rf  $(BUILD_FOLDER)
	rm -rf  xsim.dir
	@cd $(DUTB_PATH)/scrpt
	@make clean
	$(ECHO_FOOTER)


dutb:
	@cd $(DUTB_PATH)/scrpt
	@make dutb


glbl:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	envsubst < ../glbl.opt > tmp.opt
	@$(VLOG_BIN_TOOL) -f tmp.opt
	$(ECHO_FOOTER)


ip_cores:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	envsubst < ../ip_vhdl.opt > tmp.opt
	@$(VHDL_BIN_TOOL) -f tmp.opt
	envsubst < ../ip_vlog.opt > tmp.opt
	@$(VLOG_BIN_TOOL) -f tmp.opt
	$(ECHO_FOOTER)


rtl:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	envsubst < ../rtl_v.opt > tmp.opt
	@$(VLOG_BIN_TOOL) -f tmp.opt
	envsubst < ../rtl_sv.opt > tmp.opt
	@$(VLOG_BIN_TOOL) -f tmp.opt
	$(ECHO_FOOTER)


dut_tb:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	envsubst < ../dut_tb.opt > tmp.opt
	@$(VLOG_BIN_TOOL) -f tmp.opt
	$(ECHO_FOOTER)


elab:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	envsubst < ../elab_tb.opt > tmp.opt
	@$(ELAB_BIN_TOOL) -f tmp.opt
	$(ECHO_FOOTER)


run: run.tcl
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	envsubst < ../run_tb.opt > tmp.opt
	@$(SIM_BIN_TOOL) -f tmp.opt
	$(ECHO_FOOTER)


view:
	gtkwave $(BUILD_FOLDER)/wf.vcd dut_tb.gtkw &


run.tcl:
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@echo "" > $@
	@echo "run all" >> $@
	@echo "quit" >> $@






# rtl_impl_func:
# 	$(ECHO_HEADER)
# 	$(SETUP_TOOLS)
# 	@$(VLOG_BIN_TOOL) --incr --relax \
# 		$(RTL_IMPL_FUNC_V)
# 	$(ECHO_FOOTER)


# rtl_impl_time:
# 	$(ECHO_HEADER)
# 	$(SETUP_TOOLS)
# 	@$(VLOG_BIN_TOOL) --incr --relax \
# 		$(RTL_IMPL_TIME_V)
# 	$(ECHO_FOOTER)


# elab_tb_impl_func: rtl_impl_func dut_tb_impl
# 	$(ECHO_HEADER)
# 	$(SETUP_TOOLS)
# 	@echo @$(ELAB_BIN_TOOL) --incr --relax --mt 8 --debug typical --timescale 1ps/1ps \
# 		-L secureip -L simprims_ver \
# 		ttb \
# 		glbl \
# 		--snapshot top_tb
# 	$(ECHO_FOOTER)


# elab_tb_impl_time: rtl_impl_time dut_tb_impl
# 	$(ECHO_HEADER)
# 	$(SETUP_TOOLS)
# 	@echo @$(ELAB_BIN_TOOL) --relax --mt 8 --debug typical --timescale 1ps/1ps \
# 		--maxdelay \
# 		--sdfmax ttb.u_ddr3_sm_core_top=$(RTL_IMPL_SDF) \
# 		--transport_int_delays --pulse_r 0 --pulse_int_r 0 --pulse_e 0 --pulse_int_e 0 \
# 		-L secureip -L simprims_ver \
# 		ttb \
# 		glbl \
# 		--snapshot top_tb
# 	$(ECHO_FOOTER)
