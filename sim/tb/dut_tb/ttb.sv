/******************************************************************************************************************************
    Project         :   CU
    Date            :   June 2026
    Module          :   ttb
    Description     :
******************************************************************************************************************************/

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "top_func_proxy.svh"


// ****************************************************************************************************************************
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
  wire                                        rst_n, ddr_initilaized, board_clk;

  wire                                        ddr3_reset_n;
  wire                                        ddr3_ck_p;
  wire                                        ddr3_ck_n;
  wire                                        ddr3_odt;
  wire                                        ddr3_cke;
  wire                                        ddr3_cs_n = 1'b0;
  wire                                        ddr3_ras_n;
  wire                                        ddr3_cas_n;
  wire                                        ddr3_we_n;
  wire    [DDR3_BANK_W - 1     : 0]           ddr3_ba;
  wire    [DDR3_ROW_W - 1      : 0]           ddr3_addr;
  wire    [DDR3_DM_W - 1       : 0]           ddr3_dm;
  wire    [DDR3_DM_W - 1       : 0]           ddr3_dqs_p;
  wire    [DDR3_DM_W - 1       : 0]           ddr3_dqs_n;
  wire    [DDR3_DQ_W - 1       : 0]           ddr3_dq;

  wire
      clk_store_sys_clk_out1, clk_store_sys_clk_out2, clk_store_sys_clk_out3, clk_store_sys_clk_out4,
      clk_store_sys_clk_out5, clk_store_sys_clk_out6, clk_store_sys_clk_out7, proxy_board_master_clk, clk_store_sys_locked;

  logic                               proxy_board_pixel_clk;
  logic                               proxy_board_sens_hsync;
  logic                               proxy_board_sens_vsync;
  logic [IMAGE_PIXEL_W - 1    :   0]           proxy_board_sens_pixel;
  logic                               proxy_board_sens_trigger;
  logic                               sensor_sck;
  logic                               sensor_cs_n;
  logic                               sensor_mosi;


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
      uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top", "dut_vif", dut_if_h);

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


  // sensor pb if
  assign proxy_board_pixel_clk                                =   dut_if_h.pb_vif.pixel_clk;
  assign proxy_board_sens_hsync                               =   dut_if_h.pb_vif.hsync;
  assign proxy_board_sens_vsync                               =   dut_if_h.pb_vif.vsync;
  assign proxy_board_sens_pixel                               =   dut_if_h.pb_vif.data;
  assign dut_if_h.pb_vif.master_clk                           =   proxy_board_master_clk;
  assign dut_if_h.pb_vif.trigger_out                          =   proxy_board_sens_trigger;

  // mipi csi axis if
  assign u_ipp.mipi_csi_axis_tready                           =   dut_if_h.csi_vif.axis_tready;
  assign dut_if_h.csi_vif.axis_tdata                          =   u_ipp.mipi_csi_axis_tdata;
  assign dut_if_h.csi_vif.axis_tdest                          =   u_ipp.mipi_csi_axis_tdest;
  assign dut_if_h.csi_vif.axis_tkeep                          =   u_ipp.mipi_csi_axis_tkeep;
  assign dut_if_h.csi_vif.axis_tlast                          =   u_ipp.mipi_csi_axis_tlast;
  assign dut_if_h.csi_vif.axis_tuser                          =   u_ipp.mipi_csi_axis_tuser;
  assign dut_if_h.csi_vif.axis_tvalid                         =   u_ipp.mipi_csi_axis_tvalid;

  // core sys rw if
  assign dut_if_h.core_sys_rw_vif.clk                         =   u_ipp.core_sys_rw_port_clk;
  assign u_ipp.core_sys_rw_port_rw_req                        =   dut_if_h.core_sys_rw_vif.rw_req;
  assign u_ipp.core_sys_rw_port_rw_mod                        =   dut_if_h.core_sys_rw_vif.rw_mod;
  assign u_ipp.core_sys_rw_port_row_base_addr                 =   dut_if_h.core_sys_rw_vif.row_base_addr;
  assign u_ipp.core_sys_rw_port_bl8_offs                      =   dut_if_h.core_sys_rw_vif.bl8_offs;
  assign u_ipp.core_sys_rw_port_burst_num                     =   dut_if_h.core_sys_rw_vif.burst_num;
  assign u_ipp.core_sys_rw_port_burst_size                    =   dut_if_h.core_sys_rw_vif.burst_size;
  assign dut_if_h.core_sys_rw_vif.rw_bsy                      =   u_ipp.core_sys_rw_port_rw_bsy;

  assign u_ipp.core_sys_rw_port_bram_dout                     =   dut_if_h.core_sys_rw_vif.bram_dout;
  assign dut_if_h.core_sys_rw_vif.bram_addr                   =   u_ipp.core_sys_rw_port_bram_addr;
  assign dut_if_h.core_sys_rw_vif.bram_din                    =   u_ipp.core_sys_rw_port_bram_din;
  assign dut_if_h.core_sys_rw_vif.bram_en                     =   u_ipp.core_sys_rw_port_bram_en;
  assign dut_if_h.core_sys_rw_vif.bram_we                     =   u_ipp.core_sys_rw_port_bram_we;


  // sns rd ddr3
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_clk                =   u_ipp.sens_streamer.inst.rd_coeff_clk;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_rw_req             =   u_ipp.sens_streamer.inst.rd_coeff_rw_req;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_rw_bsy             =   u_ipp.sens_streamer.inst.rd_coeff_rw_bsy;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_row_base_addr      =   u_ipp.sens_streamer.inst.rd_coeff_row_base_addr;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_bl8_offs           =   u_ipp.sens_streamer.inst.rd_coeff_bl8_offs;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_burst_size         =   u_ipp.sens_streamer.inst.rd_coeff_burst_size;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_burst_num          =   u_ipp.sens_streamer.inst.rd_coeff_burst_num;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_bram_we            =   u_ipp.sens_streamer.inst.rd_coeff_bram_we;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_bram_addr          =   u_ipp.sens_streamer.inst.rd_coeff_bram_addr;
  assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_bram_din           =   u_ipp.sens_streamer.inst.rd_coeff_bram_din;


  // sns rd coeff
  assign dut_if_h.sns_rd_coeff_vif.row_start_sys_clk          =   u_ipp.sens_streamer.inst.row_start              ;
  assign dut_if_h.sns_rd_coeff_vif.i_sensor_pixel_clk         =   u_ipp.sens_streamer.inst.i_sensor_pixel_clk     ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_pixel_valid          =   u_ipp.sens_streamer.inst.coeff_pixel_valid      ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_ram_addr_b           =   u_ipp.sens_streamer.inst.coeff_ram_addr_b       ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_ram_data_b           =   u_ipp.sens_streamer.inst.coeff_ram_data_b       ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_3_2                  =   u_ipp.sens_streamer.inst.coeff_3_2              ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_2_1_0                =   u_ipp.sens_streamer.inst.coeff_2_1_0            ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_0                    =   u_ipp.sens_streamer.inst.coeff_0                ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_1                    =   u_ipp.sens_streamer.inst.coeff_1                ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_2                    =   u_ipp.sens_streamer.inst.coeff_2                ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_a                    =   u_ipp.sens_streamer.inst.coeff_a                ;
  assign dut_if_h.sns_rd_coeff_vif.coeff_b                    =   u_ipp.sens_streamer.inst.coeff_b                ;


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
  .bba(),
  .coeff_table_ddr3_base_addr(dut_if_h.sys_vif.coeff_table_ddr3_base_addr),
  .core_sys_rw_port_clk(),
  .core_sys_rw_port_bram_addr(),
  .core_sys_rw_port_bram_din(),
  .core_sys_rw_port_bram_dout(),
  .core_sys_rw_port_bram_en(),
  .core_sys_rw_port_bram_we(),
  .core_sys_rw_port_row_base_addr(),
  .core_sys_rw_port_bl8_offs(),
  .core_sys_rw_port_burst_num(),
  .core_sys_rw_port_burst_size(),
  .core_sys_rw_port_rw_req(),
  .core_sys_rw_port_rw_mod(),
  .core_sys_rw_port_rw_bsy(),
  .ips_mipi_csi_phy_rst(),
  .dbg_probe_mc_in_0(),
  .dbg_probe_mc_in_2(),
  .ddr3_addr(ddr3_addr),
  .ddr3_ba(ddr3_ba),
  .ddr3_cas_n(ddr3_cas_n),
  .ddr3_ck_n(ddr3_ck_n),
  .ddr3_ck_p(ddr3_ck_p),
  .ddr3_cke(ddr3_cke),
  .ddr3_cs_n(ddr3_cs_n),
  .ddr3_dm(ddr3_dm),
  .ddr3_dq(ddr3_dq),
  .ddr3_dqs_n(ddr3_dqs_n),
  .ddr3_dqs_p(ddr3_dqs_p),
  .ddr3_odt(ddr3_odt),
  .ddr3_ras_n(ddr3_ras_n),
  .ddr3_reset_n(ddr3_reset_n),
  .ddr3_we_n(ddr3_we_n),
  .ddr_270_clk(clk_store_sys_clk_out5),
  .ddr_clk(clk_store_sys_clk_out4),
  .fr30_clk(clk_store_sys_clk_out6),
  .fr60_clk(clk_store_sys_clk_out7),
  .ips(dut_if_h.sys_vif.ips),
  .ipst(),
  .mipi_csi_axis_tdata(),
  .mipi_csi_axis_tdest(),
  .mipi_csi_axis_tkeep(),
  .mipi_csi_axis_tlast(),
  .mipi_csi_axis_tready(),
  .mipi_csi_axis_tuser(),
  .mipi_csi_axis_tvalid(),
  .o_led(),
  .pb_master_clk(proxy_board_master_clk),
  .proxy_board_pixel_clk(proxy_board_pixel_clk),
  .proxy_board_sens_hsync(proxy_board_sens_hsync),
  .proxy_board_sens_pixel(proxy_board_sens_pixel),
  .proxy_board_sens_trigger(proxy_board_sens_trigger),
  .proxy_board_sens_vsync(proxy_board_sens_vsync),
  .ref_clk(clk_store_sys_clk_out1),
  .sens_img_frame_number(),
  .sys_135_clk(clk_store_sys_clk_out3),
  .sys_clk(clk_store_sys_clk_out2),
  .sys_rst_n(rst_n),
  .trigger(dut_if_h.pb_vif.trigger_in)
);


wire ddr3_ck_p_1 = ddr3_ck_p;
`ifdef HANDLE_GATE_SIM_BUG
  wire ddr3_ck_n_1 = ~ddr3_ck_n;
`else
  wire ddr3_ck_n_1 = ddr3_ck_n;
`endif

  ddr3 u_ram (
    .rst_n                      (ddr3_reset_n),
    .ck                         (ddr3_ck_p_1),
    .ck_n                       (ddr3_ck_n_1),
    .odt                        (ddr3_odt),
    .cke                        (ddr3_cke),
    .cs_n                       (ddr3_cs_n),
    .ras_n                      (ddr3_ras_n),
    .cas_n                      (ddr3_cas_n),
    .we_n                       (ddr3_we_n),
    .ba                         (ddr3_ba),
    .addr                       (ddr3_addr[14 - 1 : 0]),
    .dm_tdqs                    (ddr3_dm),
    .dqs                        (ddr3_dqs_p),
    .dqs_n                      (ddr3_dqs_n),
    .dq                         (ddr3_dq)
  );

endmodule
// ****************************************************************************************************************************
