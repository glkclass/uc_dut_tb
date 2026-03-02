.ONESHELL:
SHELL=/bin/bash

VIVADO_PATH=/tools/Xilinx/2025.1/Vivado
TOOLS_USED="tools: $(VIVADO_PATH)"

ECHO_HEADER=@echo -e "[INFO] Make $@\t\t$(TOOLS_USED)\t\tstart: $$(date +'%H:%M:%S')"
ECHO_FOOTER=@echo -e "[INFO] ..Finished\n"
SETUP_TOOLS=@source $(VIVADO_PATH)/settings64.sh


ifndef AM_PROJECT_PATH
	AM_PROJECT_PATH=../../../../../..
endif
PROJECT_ROOT_PATH=$(AM_PROJECT_PATH)/oct640_am_hw
DUTB_PATH=/home/anton.voloshchuk/design/dutb/
RTL_PATH=$(PROJECT_ROOT_PATH)/rtl
RTL_COMMON_PATH=$(RTL_PATH)/common
RTL_CORE_PATH=$(RTL_PATH)/core
# RTL_TOP_PATH=$(RTL_PATH)/top
RTL_IP_PATH=$(RTL_PATH)/ip

DUT_TB_PATH=$(PROJECT_ROOT_PATH)/sim/tb/dut_tb
VIVADO_PROJECT_PATH=${PROJECT_ROOT_PATH}/syn/vivado_project
# IP_GEN_PATH=${PROJECT_ROOT_PATH}/vivado_project.gen/sources_1/ip
BD_GEN_PATH=${VIVADO_PROJECT_PATH}/vivado_project.gen/sources_1/bd/oct640_am
IP_BD_GEN_PATH=${BD_GEN_PATH}/ip

IMPL_NETLIST_FUNC=$(PROJECT_ROOT_PATH)/vivado_project/vivado_project.sim/sim_1/impl/func/xsim/oct640_am_bf_top_func_impl.v
IMPL_NETLIST_TIME=$(PROJECT_ROOT_PATH)/vivado_project/vivado_project.sim/sim_1/impl/timing/xsim/oct640_am_bf_top_time_impl.v
IMPL_SDF_TIME=$(PROJECT_ROOT_PATH)/vivado_project/vivado_project.sim/sim_1/impl/timing/xsim/oct640_am_bf_top_time_impl.sdf


all: rtl dut_tb
	@echo "Make all"


dutb:
	@mkdir -p runs
	@cd runs
	@export DUTB_RUN_DIR=$(DUTB_PATH)/scrpt
	@make -f $(DUTB_PATH)/scrpt/makefile dutb


glbl:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p runs
	@cd runs
	@xvlog --incr --relax \
		$(VIVADO_PATH)/data/verilog/src/glbl.v # used by SelectIO primitives
	$(ECHO_FOOTER)


rtl_pkg:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p runs
	@cd runs
	@xvlog --incr --relax -sv \
		$(RTL_COMMON_PATH)/oct640_am_util_pkg.sv
	$(ECHO_FOOTER)


rtl: dutb rtl_pkg
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p runs
	@cd runs
	@xvlog --incr --relax -sv \
		-d DUT_TB \
		-d QUICK_INIT \
		$(RTL_CORE_PATH)/ila_wrapper.v \
		$(RTL_CORE_PATH)/pb_master_clk_mux.v \
		$(RTL_CORE_PATH)/ips_demux.v \
		$(RTL_CORE_PATH)/mipi_csi_axis_streamer.v \
		$(RTL_CORE_PATH)/dead_pixel_masker.v \
		$(RTL_CORE_PATH)/auto_offset_contrast_range_calculator.v \
		$(RTL_CORE_PATH)/contrast_range_stretch_param_caclulator.v \
		$(RTL_CORE_PATH)/contrast_range_stretcher.v \
		$(RTL_CORE_PATH)/sens_trigger.v \
		$(RTL_CORE_PATH)/sens_streamer.v \
		$(RTL_CORE_PATH)/ddr3_proxy_rw_request_if.v \
		$(RTL_CORE_PATH)/ddr3_sm_core/ddr3_sm_core.sv \
		$(RTL_CORE_PATH)/ddr3_sm_core/ddr3_sm_core_request_handler.v \
		$(RTL_CORE_PATH)/ddr3_sm_core/ddr3_sm_core_phy.v \
		$(RTL_CORE_PATH)/ddr3_sm_core/ddr3_sm_core_frontend.v \
		${BD_GEN_PATH}/sim/oct640_am.v
	$(ECHO_FOOTER)


rtl_impl_func:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@xvlog --incr --relax \
		$(RTL_IMPL_FUNC_V)
	$(ECHO_FOOTER)


rtl_impl_time:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@xvlog --incr --relax \
		$(RTL_IMPL_TIME_V)
	$(ECHO_FOOTER)


ip_cores:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p runs
	@cd runs
	@xvhdl --incr --relax \
		$(RTL_IP_PATH)/stretch_gain_divider/sim/stretch_gain_divider.vhd

	@xvlog --incr --relax \
		$(RTL_IP_PATH)/bram_2x2K_16_64/sim/bram_2x2K_16_64.v \
		$(RTL_IP_PATH)/bram_2x4K_64_64/sim/bram_2x4K_64_64.v \
		$(RTL_IP_PATH)/bram_2x128B_64_2/sim/bram_2x128B_64_2.v \
		$(RTL_IP_PATH)/bram_2x2K_16_64/simulation/blk_mem_gen_v8_4.v \
		$(IP_BD_GEN_PATH)/oct640_am_clk_store_sys_0/oct640_am_clk_store_sys_0.v \
		$(IP_BD_GEN_PATH)/oct640_am_clk_store_sys_0/oct640_am_clk_store_sys_0_clk_wiz.v \
		$(IP_BD_GEN_PATH)/oct640_am_ddr3_sm_core_frontend_0/sim/oct640_am_ddr3_sm_core_frontend_0.v \
		$(IP_BD_GEN_PATH)/oct640_am_ddr3_sm_core_request_handler_0/sim/oct640_am_ddr3_sm_core_request_handler_0.v \
		$(IP_BD_GEN_PATH)/oct640_am_mipi_csi_axis_streamer_0/sim/oct640_am_mipi_csi_axis_streamer_0.v \
		$(IP_BD_GEN_PATH)/oct640_am_sens_streamer_0/sim/oct640_am_sens_streamer_0.v\
		$(IP_BD_GEN_PATH)/oct640_am_ips_demux_0/sim/oct640_am_ips_demux_0.v\
		$(IP_BD_GEN_PATH)/oct640_am_pb_master_clk_mux_0/sim/oct640_am_pb_master_clk_mux_0.v

# 		$(RTL_IP_PATH)/dist_bram_2x128B_64_64/sim/dist_bram_2x128B_64_64.v
# 		$(RTL_IP_PATH)/dist_bram_2x128B_64_64/simulation/dist_mem_gen_v8_0.v

	$(ECHO_FOOTER)


dut_tb: dutb rtl_pkg
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p runs
	@cd runs
	@xvlog --incr --relax -sv \
		-L UVM \
		-i $(DUTB_PATH)/src \
		$(DUT_TB_PATH)/dut_tb_util_pkg.sv \
		$(DUT_TB_PATH)/dut_if.sv \
		$(DUT_TB_PATH)/dut_tb_pkg.sv \
		$(DUT_TB_PATH)/ddr3.v \
		$(DUT_TB_PATH)/ttb.sv
	$(ECHO_FOOTER)


elab_tb: glbl ip_cores rtl  dut_tb
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@mkdir -p runs
	@cd runs
	@xelab --incr --relax --mt 8 --debug typical --timescale 1ps/1ps \
		-L secureip -L simprims_ver \
		ttb \
		glbl \
		--snapshot top_tb
	$(ECHO_FOOTER)


elab_tb_impl_func: rtl_impl_func dut_tb_impl
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@echo @xelab --incr --relax --mt 8 --debug typical --timescale 1ps/1ps \
		-L secureip -L simprims_ver \
		ttb \
		glbl \
		--snapshot top_tb
	$(ECHO_FOOTER)


elab_tb_impl_time: rtl_impl_time dut_tb_impl
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@echo @xelab --relax --mt 8 --debug typical --timescale 1ps/1ps \
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
	@mkdir -p runs
	@cd runs
	@xsim top_tb \
		--testplusarg TOOLS=VIVADO \
		--testplusarg STORE_WAVE \
		--testplusarg UVM_VERBOSITY=UVM_HIGH \
		--testplusarg UVM_TESTNAME=dut_test \
		--testplusarg model_data+. \
		--runall \
		--t run.tcl
	$(ECHO_FOOTER)


view_tb:
	gtkwave runs/wf.vcd am.gtkw &


view_tb_impl:
	gtkwave wf.vcd am_impl.gtkw &


run.tcl:
	@mkdir -p runs
	@cd runs
	@echo "" > $@
	@echo "run all" >> $@
	@echo "quit" >> $@


clean:
	@echo "Cleanup.."
	rm -rf *.jou
	rm -rf *.log
	rm -rf *.pb
	rm -rf .Xil
	rm -rf xsim.dir
	rm -rf xsim.tcl
	rm -rf xsim.covdb
	rm -rf synth.tcl
	rm -rf impl.tcl
	rm -rf gen_gate_sim.tcl
	rm -rf run.tcl
	rm -rf *.vcd
	rm -rf *.wdb
	rm -rf ttb.*
	$(ECHO_FOOTER)


impl:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@ cd .. ; ./vivado_cli.sh -t run_impl
	$(ECHO_FOOTER)


impl_artefacts:
	$(ECHO_HEADER)
	$(SETUP_TOOLS)
	@cd .. ; ./vivado_cli.sh -t gen_impl_artefacts
	$(ECHO_FOOTER)
