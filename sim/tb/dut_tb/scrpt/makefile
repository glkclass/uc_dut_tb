.ONESHELL:
SHELL=/bin/bash

-include env
export

-include user_env
export

LOG ?= $(TB_LOG)

build: dutb rtl_pkg glbl ip_cores rtl dut_tb elab_tb

run: run_tb view_tb


# rules
debug: clean
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
	@$(VLOG_BIN_TOOL) --incr --relax \
		$(VIVADO_TOOLS)/data/verilog/src/glbl.v # used by SelectIO primitives
	$(ECHO_FOOTER)


rtl_pkg:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@$(VLOG_BIN_TOOL) --incr --relax -sv \
		../$(RTL_PATH)/common/oct640_cu_util_pkg.sv
	$(ECHO_FOOTER)


rtl:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@$(VLOG_BIN_TOOL) --incr --relax -sv \
		-d DUT_TB \
		-d QUICK_INIT \
		-L dutb=$(DUTB_LIB_FOLDER) \
		../$(RTL_PATH)/core/ila_wrapper.v \
		../$(RTL_PATH)/core/pb_master_clk_mux.v \
		../$(RTL_PATH)/core/ips_demux.v \
		../$(RTL_PATH)/core/mipi_csi_axis_streamer.v \
		../$(RTL_PATH)/core/dead_pixel_masker.v \
		../$(RTL_PATH)/core/auto_offset_contrast_range_calculator.v \
		../$(RTL_PATH)/core/contrast_range_stretch_param_caclulator.v \
		../$(RTL_PATH)/core/contrast_range_stretcher.v \
		../$(RTL_PATH)/core/sens_trigger_generator.v \
		../$(RTL_PATH)/core/proxy_board_status_checker.v \
		../$(RTL_PATH)/core/sens_streamer.v \
		../$(RTL_PATH)/core/fake_proxy_board.v \
		../$(RTL_PATH)/core/dbg_probe_mux_wrapper.v \
		../$(RTL_PATH)/core/ddr3_proxy_rw_request_if.v \
		../$(RTL_PATH)/core/ddr3_sm_core/ddr3_sm_core.sv \
		../$(RTL_PATH)/core/ddr3_sm_core/ddr3_sm_core_request_handler.v \
		../$(RTL_PATH)/core/ddr3_sm_core/ddr3_sm_core_phy.v \
		../$(RTL_PATH)/core/ddr3_sm_core/ddr3_sm_core_frontend.v \
		../$(BD_GEN_PATH)/sim/oct640_cu.v
	$(ECHO_FOOTER)


rtl_impl_func:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@$(VLOG_BIN_TOOL) --incr --relax \
		$(RTL_IMPL_FUNC_V)
	$(ECHO_FOOTER)


rtl_impl_time:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@$(VLOG_BIN_TOOL) --incr --relax \
		$(RTL_IMPL_TIME_V)
	$(ECHO_FOOTER)


ip_cores:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@$(VHDL_BIN_TOOL) --incr --relax \
		../$(RTL_PATH)/ip/stretch_gain_divider/sim/stretch_gain_divider.vhd

	@$(VLOG_BIN_TOOL) --incr --relax \
		../$(RTL_PATH)/ip/bram_2x2K_16_64/sim/bram_2x2K_16_64.v \
		../$(RTL_PATH)/ip/bram_2x4K_64_64/sim/bram_2x4K_64_64.v \
		../$(RTL_PATH)/ip/bram_2x128B_64_2/sim/bram_2x128B_64_2.v \
		../$(RTL_PATH)/ip/bram_2x2K_16_64/simulation/blk_mem_gen_v8_4.v \
		../$(IP_BD_GEN_PATH)/oct640_cu_clk_store_sys_0/oct640_cu_clk_store_sys_0.v \
 		../$(IP_BD_GEN_PATH)/oct640_cu_clk_store_sys_0/oct640_cu_clk_store_sys_0_clk_wiz.v \
		../$(IP_BD_GEN_PATH)/oct640_cu_ddr3_sm_core_frontend_0/sim/oct640_cu_ddr3_sm_core_frontend_0.v \
		../$(IP_BD_GEN_PATH)/oct640_cu_ddr3_sm_core_request_handler_0/sim/oct640_cu_ddr3_sm_core_request_handler_0.v \
		../$(IP_BD_GEN_PATH)/oct640_cu_mipi_csi_axis_streamer_0/sim/oct640_cu_mipi_csi_axis_streamer_0.v \
		../$(IP_BD_GEN_PATH)/oct640_cu_sens_streamer_0/sim/oct640_cu_sens_streamer_0.v\
		../$(IP_BD_GEN_PATH)/oct640_cu_ips_demux_0/sim/oct640_cu_ips_demux_0.v\
		../$(IP_BD_GEN_PATH)/oct640_cu_pb_master_clk_mux_0/sim/oct640_cu_pb_master_clk_mux_0.v \
		../$(IP_BD_GEN_PATH)/oct640_cu_dbg_probe_mux_wrapper_0/sim/oct640_cu_dbg_probe_mux_wrapper_0.v


# 		$(RTL_PATH)/ip/dist_bram_2x128B_64_64/sim/dist_bram_2x128B_64_64.v
# 		$(RTL_PATH)/ip/dist_bram_2x128B_64_64/simulation/dist_mem_gen_v8_0.v

	$(ECHO_FOOTER)


dut_tb:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@$(VLOG_BIN_TOOL) --incr --relax -sv \
		-L UVM \
		-L dutb=$(DUTB_LIB_FOLDER) \
		-i ../$(DUTB_PATH)/src \
		-i ../$(RTL_PATH)/common \
		../$(DUT_TB_PATH)/dut_tb_util_pkg.sv \
		../$(DUT_TB_PATH)/dut_if.sv \
		../$(DUT_TB_PATH)/dut_tb_pkg.sv \
		../$(DUT_TB_PATH)/ddr3.v \
		../$(DUT_TB_PATH)/ttb.sv
	$(ECHO_FOOTER)


elab_tb:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@$(ELAB_BIN_TOOL) --incr --relax --mt 8 --debug typical --timescale 1ps/1ps \
		-L secureip \
		-L simprims_ver \
		-L dutb=$(DUTB_LIB_FOLDER) \
		ttb \
		glbl \
		--snapshot top_tb
	$(ECHO_FOOTER)


elab_tb_impl_func: rtl_impl_func dut_tb_impl
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@echo @$(ELAB_BIN_TOOL) --incr --relax --mt 8 --debug typical --timescale 1ps/1ps \
		-L secureip -L simprims_ver \
		ttb \
		glbl \
		--snapshot top_tb
	$(ECHO_FOOTER)


elab_tb_impl_time: rtl_impl_time dut_tb_impl
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@echo @$(ELAB_BIN_TOOL) --relax --mt 8 --debug typical --timescale 1ps/1ps \
		--maxdelay \
		--sdfmax ttb.u_ddr3_sm_core_top=$(RTL_IMPL_SDF) \
		--transport_int_delays --pulse_r 0 --pulse_int_r 0 --pulse_e 0 --pulse_int_e 0 \
		-L secureip -L simprims_ver \
		ttb \
		glbl \
		--snapshot top_tb
	$(ECHO_FOOTER)


run_tb: run.tcl
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@$(SIM_BIN_TOOL) top_tb \
		--testplusarg TOOLS=VIVADO \
		--testplusarg STORE_WAVE \
		--testplusarg UVM_VERBOSITY=UVM_HIGH \
		--testplusarg UVM_TESTNAME=dut_test \
		--testplusarg model_data+. \
		--runall \
		--t run.tcl
	$(ECHO_FOOTER)


view_tb:
	gtkwave $(BUILD_FOLDER)/wf.vcd am.gtkw &


view_tb_impl:
	gtkwave wf.vcd am_impl.gtkw &


run.tcl:
	@mkdir -p $(BUILD_FOLDER)
	@cd $(BUILD_FOLDER)
	@echo "" > $@
	@echo "run all" >> $@
	@echo "quit" >> $@


