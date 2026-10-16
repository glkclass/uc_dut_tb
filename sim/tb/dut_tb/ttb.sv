/***************************************************************************************************
    Project         :   CU
    Date            :   June 2026
    Module          :   ttb
    Description     :
***************************************************************************************************/

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "dut_tb_macros.svh"
`include "top_func_proxy.svh"

`default_nettype none

// *************************************************************************************************
module ttb;
  import dut_tb_pkg::dut_test;

  import dutb_util_pkg::timeout_sim;

  import dut_tb_util_pkg::T_CLK_100MHZ_PERIOD;
  import dut_tb_util_pkg::T_RST_N_LEN;

  import oct640_cu_util_pkg::IMAGE_PIXEL_W;

  import oct640_cu_util_pkg::DDR3_BANK_W;
  import oct640_cu_util_pkg::DDR3_ROW_W;
  import oct640_cu_util_pkg::DDR3_DQ_W;
  import oct640_cu_util_pkg::DDR3_DM_W;


// wires
  wire
    rst_n, ddr_initilaized, board_clk;

  wire
      clk_store_sys_clk_out1,
      clk_store_sys_clk_out2,
      clk_store_sys_clk_out3,
      clk_store_sys_clk_out4,
      clk_store_sys_clk_out5,
      clk_store_sys_clk_out6,
      clk_store_sys_clk_out7,
      clk_store_sys_locked;

  logic                               sensor_sck;
  logic                               sensor_cs_n;
  logic                               sensor_mosi;

// main

  // Setup env and start
  initial begin
      int test_length_ns;
      // Provide access to ttb static funcs for UVM infra
      static top_func_proxy top_func_proxy = new();
      uvm_config_db #(base_func_proxy)::set(null, "*", "top_func_proxy", top_func_proxy);

      $timeformat(-9, 3, " ns", 13);
      `store_wave(ttb, "wf.vcd")

      test_length_ns = `get_arg_value("TEST_LENGTH_NS=%d", test_length_ns, 1ms);
      `uvm_info("TTB", $sformatf("Max test length: %0d ns", test_length_ns), UVM_HIGH)

      // Provide DUT interfaces to UVM infra
      uvm_config_db #(virtual image_hc_if)::set(
        null, "uvm_test_top.env_h*", "dut_image_hc_vif", `IMAGE_HC_PATH(image_hc_bind_if));
      uvm_config_db #(virtual sns_rd_coeff_if)::set(
        null, "uvm_test_top.env_h*", "sns_rd_coeff_vif", `SENS_STREAMER_PATH(sns_rd_coeff_bind_if));
      uvm_config_db #(virtual sns_rd_ddr3_if)::set(
        null, "uvm_test_top.env_h*", "sns_rd_ddr3_vif", `SENS_STREAMER_PATH(sns_rd_ddr3_bind_if));
      uvm_config_db #(virtual sns_rd_ddr3_bram_if)::set(
        null, "uvm_test_top.env_h*", "sns_rd_ddr3_bram_vif", `BANK_STORE_PATH(sns_rd_ddr3_bram_bind_if));
      uvm_config_db #(virtual pb_if)::set(
        null, "uvm_test_top.env_h*", "pb_vif", `IPP_PATH(pb_bind_if));
      uvm_config_db #(virtual sys_if)::set(
        null, "uvm_test_top.env_h*", "sys_vif", `IPP_PATH(sys_bind_if));
      uvm_config_db #(virtual sm_core_rw_if)::set(
        null, "uvm_test_top.env_h*", "core_sys_rw_vif", `IPP_PATH(core_sys_rw_bind_if));
      uvm_config_db #(virtual axis_if)::set(
        null, "uvm_test_top.env_h*", "axis_vif", `IPP_PATH(axis_bind_if));
      uvm_config_db #(virtual uvc_if)::set(
        null, "uvm_test_top.env_h*", "uvc_vif", `IPP_PATH(uvc_bind_if));
      uvm_config_db #(virtual histo_bram_if)::set(
        null, "uvm_test_top.env_h*", "histo_bram_0_vif", `HISTO_BRAM_PATH(0, histo_bram_bind_if));
      uvm_config_db #(virtual histo_bram_if)::set(
        null, "uvm_test_top.env_h*", "histo_bram_1_vif", `HISTO_BRAM_PATH(1, histo_bram_bind_if));

      uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top.env_h*", "dut_vif", dut_if_h);

      // Start test
      fork
          run_test();
          timeout_sim(test_length_ns * 1ns, 10);
     join_any
  end


  // global reset
  rst_n_gen #(.T_RST_N_LENGTH(T_RST_N_LEN))
  u_rst_gen (.rst_n(rst_n));


  // ddr3 quick init delay
  rst_n_gen #(.T_RST_N_LENGTH(100us))
  u_ddr3_init_delay (.rst_n(ddr_initilaized));

  // board clk
  clk_gen #(.T_CLK_PERIOD(T_CLK_100MHZ_PERIOD), .PHASE(0))
  u_clk_board (.clk(board_clk));


  // main dut_tb interface
  dut_if  dut_if_h(           .rst_n(rst_n),
                              .ddr_initilaized(ddr_initilaized),
                              .sys_clk(clk_store_sys_clk_out2)
  );

  // ddr3 bus
  ddr3_if ddr3_bus();


  bind image_histo_calculator image_hc_if image_hc_bind_if (.*);
  bind sens_streamer sns_rd_coeff_if sns_rd_coeff_bind_if (.*);
  bind sens_streamer sns_rd_ddr3_if sns_rd_ddr3_bind_if (.*);
  bind bank_store sns_rd_ddr3_bram_if sns_rd_ddr3_bram_bind_if (.*);
  bind image_processing_pipeline_imp_PQRLL2 pb_if pb_bind_if (.*);
  bind image_processing_pipeline_imp_PQRLL2 sys_if sys_bind_if (.*);
  bind image_processing_pipeline_imp_PQRLL2 sm_core_rw_if core_sys_rw_bind_if (.*);
  bind image_processing_pipeline_imp_PQRLL2 axis_if axis_bind_if (.*);
  bind image_processing_pipeline_imp_PQRLL2 uvc_if uvc_bind_if (.*);
  bind `HISTO_BRAM_UNIT(0) histo_bram_if histo_bram_bind_if(.*);
  bind `HISTO_BRAM_UNIT(1) histo_bram_if histo_bram_bind_if(.*);

  oct640_cu_clk_store_sys_0 clk_store_sys (
    .clk_in1(board_clk),
    .clk_out1(clk_store_sys_clk_out1),
    .clk_out2(clk_store_sys_clk_out2),
    .clk_out3(clk_store_sys_clk_out3),
    .clk_out4(clk_store_sys_clk_out4),
    .clk_out5(clk_store_sys_clk_out5),
    .clk_out6(clk_store_sys_clk_out6),
    .clk_out7(clk_store_sys_clk_out7),
    .locked(clk_store_sys_locked)
  );


  image_processing_pipeline_imp_PQRLL2 u_ipp (
    .sys_rst_n(rst_n),
    .ref_clk(clk_store_sys_clk_out1),
    .sys_clk(clk_store_sys_clk_out2),
    .sys_135_clk(clk_store_sys_clk_out3),
    .ddr_clk(clk_store_sys_clk_out4),
    .ddr_270_clk(clk_store_sys_clk_out5),
    .fr30_clk(clk_store_sys_clk_out6),
    .fr60_clk(clk_store_sys_clk_out7),

    .ddr3_addr(ddr3_bus.addr),
    .ddr3_ba(ddr3_bus.ba),
    .ddr3_cas_n(ddr3_bus.cas_n),
    .ddr3_ck_n(ddr3_bus.ck_n),
    .ddr3_ck_p(ddr3_bus.ck_p),
    .ddr3_cke(ddr3_bus.cke),
    .ddr3_cs_n(ddr3_bus.cs_n),
    .ddr3_dm(ddr3_bus.dm),
    .ddr3_dq(ddr3_bus.dq),
    .ddr3_dqs_n(ddr3_bus.dqs_n),
    .ddr3_dqs_p(ddr3_bus.dqs_p),
    .ddr3_odt(ddr3_bus.odt),
    .ddr3_ras_n(ddr3_bus.ras_n),
    .ddr3_reset_n(ddr3_bus.reset_n),
    .ddr3_we_n(ddr3_bus.we_n)
  );


  ddr3 u_ram (
    .rst_n    (ddr3_bus.reset_n),
    .ck       (ddr3_bus.ddr3_ck_p),
    .ck_n     (ddr3_bus.ddr3_ck_n),
    .odt      (ddr3_bus.odt),
    .cke      (ddr3_bus.cke),
    .cs_n     (ddr3_bus.cs_n),
    .ras_n    (ddr3_bus.ras_n),
    .cas_n    (ddr3_bus.cas_n),
    .we_n     (ddr3_bus.we_n),
    .ba       (ddr3_bus.ba),
    .addr     (ddr3_bus.addr[14 - 1 : 0]),
    .dm_tdqs  (ddr3_bus.dm),
    .dqs      (ddr3_bus.dqs_p),
    .dqs_n    (ddr3_bus.dqs_n),
    .dq       (ddr3_bus.dq)
  );


endmodule

`default_nettype wire
// *************************************************************************************************
