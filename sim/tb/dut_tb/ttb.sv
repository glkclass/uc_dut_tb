/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Module          :   ttb
    Description     :
******************************************************************************************************************************/


// ****************************************************************************************************************************
module ttb;
    `include "uvm_macros.svh"
    `include "dut_tb_macros.svh"

    `include "../../../rtl/common/mc_const.vh"

    import uvm_pkg::*;

    import dut_tb_pkg::dut_test;

    import dutb_util_pkg::timeout_sim;

    import dut_tb_util_pkg::T_TEST_LEN;
    import dut_tb_util_pkg::T_CLK_72_25MHZ_PERIOD;
    import dut_tb_util_pkg::T_RST_N_LEN;

    import oct640_am_util_pkg::IMAGE_PIXEL_W;

    import oct640_am_util_pkg::DDR3_BANK_W;
    import oct640_am_util_pkg::DDR3_ROW_W;
    import oct640_am_util_pkg::DDR3_DQ_W;
    import oct640_am_util_pkg::DDR3_DM_W;


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

// wires
    logic                       proxy_board_pixel_clk;
    logic                       proxy_board_hsync;
    logic                       proxy_board_vsync;
    logic [IMAGE_PIXEL_W-1:0]   proxy_board_pixel;
    logic                       proxy_board_trigger;
    logic                       sensor_sck;
    logic                       sensor_cs_n;
    logic                       sensor_mosi;

    // init coeffs
    `INIT_DDR3(Init_0, $random, (`DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR / `DDR3_LINE_SIZE), 24);

    // init dead pixels mask
    `INIT_DDR3_DP_MASK(Init_1, $random, (`DDR3_DEAD_PIXEL_TABLE_BASE_ADDR / `DDR3_LINE_SIZE), 1);

    initial
        begin : l_main
            $timeformat(-9, 3, "ns", 8);
            `STORE_WAVE(ttb, "wf.vcd")

            // `ifdef PRINT_DEBUG_CONSTS
            //     `uvm_debug($sformatf("Param ZZZ: %d", xxx.yyy.ZZZ))
            // `endif

            // Provide DUT interfaces to UVM infra
            uvm_config_db #(virtual dut_if)::set(null, "uvm_test_top", "dut_vif", dut_if_h);
            fork
                run_test();
                timeout_sim(T_TEST_LEN, 10);
            join_any
        end


    wire rst_n, ddr_initilaized, clk_74_25_mhz;

    // global reset
    rst_n_gen #(.T_RST_N_LENGTH(T_RST_N_LEN))
    u_rst_gen (.rst_n(rst_n));


    // ddr3 quick init delay
    rst_n_gen #(.T_RST_N_LENGTH(100us))
    u_ddr3_init_delay (.rst_n(ddr_initilaized));


    clk_gen #(.T_CLK_PERIOD(T_CLK_72_25MHZ_PERIOD), .PHASE(0))
    u_clk_board (.clk(clk_74_25_mhz));


    dut_if  dut_if_h(           .rst_n(rst_n),
                                .ddr_initilaized(ddr_initilaized),
                                .sys_clk(clk_store_sys_clk_out2)

    );


    // Raw image output
    logic   [16 - 1      :   0]         ips;
    logic   [18 - 1     :   0]          coeff_table_ddr3_base_addr  = `DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR >> 11;

    assign ips = {dut_if_h.pb_vif.trigger_in, 15'd1};


    // sensor pb if
    assign proxy_board_pixel_clk                                =   dut_if_h.pb_vif.pixel_clk;
    assign proxy_board_hsync                                    =   dut_if_h.pb_vif.hsync;
    assign proxy_board_vsync                                    =   dut_if_h.pb_vif.vsync;
    assign proxy_board_pixel                                    =   dut_if_h.pb_vif.data;
    assign dut_if_h.pb_vif.master_clk                           =   proxy_board_master_clk;
    assign dut_if_h.pb_vif.trigger_out                          =   proxy_board_trigger;

    // mipi csi axis if
    assign u_ipp.mipi_csi_axis_tready                           =   dut_if_h.csi_vif.axis_tready;
    assign dut_if_h.csi_vif.axis_tdata                          =   u_ipp.mipi_csi_axis_tdata;
    assign dut_if_h.csi_vif.axis_tdest                          =   u_ipp.mipi_csi_axis_tdest;
    assign dut_if_h.csi_vif.axis_tkeep                          =   u_ipp.mipi_csi_axis_tkeep;
    assign dut_if_h.csi_vif.axis_tlast                          =   u_ipp.mipi_csi_axis_tlast;
    assign dut_if_h.csi_vif.axis_tuser                          =   u_ipp.mipi_csi_axis_tuser;
    assign dut_if_h.csi_vif.axis_tvalid                         =   u_ipp.mipi_csi_axis_tvalid;

    // core sys rw if
    assign u_ipp.core_sys_rw_port_req_rdreq                     =   dut_if_h.core_sys_rw_vif.req_rdreq;
    assign u_ipp.core_sys_rw_port_req_wrreq                     =   dut_if_h.core_sys_rw_vif.req_wrreq;
    assign u_ipp.core_sys_rw_port_req_row_base_addr             =   dut_if_h.core_sys_rw_vif.req_row_base_addr;
    assign u_ipp.core_sys_rw_port_req_bl8_offs                  =   dut_if_h.core_sys_rw_vif.req_bl8_offs;
    assign u_ipp.core_sys_rw_port_req_burst_num                 =   dut_if_h.core_sys_rw_vif.req_burst_num;
    assign u_ipp.core_sys_rw_port_req_burst_size                =   dut_if_h.core_sys_rw_vif.req_burst_size;
    assign dut_if_h.core_sys_rw_vif.req_rdbusy                  =   u_ipp.core_sys_rw_port_req_rdbusy;
    assign dut_if_h.core_sys_rw_vif.req_wrbusy                  =   u_ipp.core_sys_rw_port_req_wrbusy;

    assign u_ipp.core_sys_rw_port_bram_dout                     =   dut_if_h.core_sys_rw_vif.bram_dout;
    assign dut_if_h.core_sys_rw_vif.bram_addr                   =   u_ipp.core_sys_rw_port_bram_addr;
    assign dut_if_h.core_sys_rw_vif.bram_clk                    =   u_ipp.core_sys_rw_port_bram_clk;
    assign dut_if_h.core_sys_rw_vif.bram_din                    =   u_ipp.core_sys_rw_port_bram_din;
    assign dut_if_h.core_sys_rw_vif.bram_en                     =   u_ipp.core_sys_rw_port_bram_en;
    assign dut_if_h.core_sys_rw_vif.bram_we                     =   u_ipp.core_sys_rw_port_bram_we;


    // sns rd ddr3
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_req_rdreq          =   u_ipp.sens_streamer.inst.rd_coeff_req_rdreq;
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_req_rdbusy         =   u_ipp.sens_streamer.inst.rd_coeff_req_rdbusy;
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_req_row_base_addr  =   u_ipp.sens_streamer.inst.rd_coeff_req_row_base_addr;
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_req_bl8_offs       =   u_ipp.sens_streamer.inst.rd_coeff_req_bl8_offs;
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_req_burst_size     =   u_ipp.sens_streamer.inst.rd_coeff_req_burst_size;
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_req_burst_num      =   u_ipp.sens_streamer.inst.rd_coeff_req_burst_num;
    assign dut_if_h.sns_rd_ddr3_vif.rd_coeff_bram_clk           =   u_ipp.sens_streamer.inst.rd_coeff_bram_clk;
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


oct640_am_clk_store_sys_0 clk_store_sys
   (.clk_in1(clk_74_25_mhz),
    .clk_out1(clk_store_sys_clk_out1),
    .clk_out2(clk_store_sys_clk_out2),
    .clk_out3(clk_store_sys_clk_out3),
    .clk_out4(clk_store_sys_clk_out4),
    .clk_out5(clk_store_sys_clk_out5),
    .clk_out6(clk_store_sys_clk_out6),
    .clk_out7(clk_store_sys_clk_out7),
    .locked(clk_store_sys_locked));


image_processing_pipeline_imp_YUBQ36 u_ipp (
    .core_sys_rw_port_bram_addr                 (),
    .core_sys_rw_port_bram_clk                  (),
    .core_sys_rw_port_bram_din                  (),
    .core_sys_rw_port_bram_dout                 (),
    .core_sys_rw_port_bram_en                   (),
    .core_sys_rw_port_bram_we                   (),
    .core_sys_rw_port_req_bl8_offs              (),
    .core_sys_rw_port_req_burst_num             (),
    .core_sys_rw_port_req_burst_size            (),
    .core_sys_rw_port_req_rdreq                 (),
    .core_sys_rw_port_req_rdbusy                (),
    .core_sys_rw_port_req_row_base_addr         (),
    .core_sys_rw_port_req_wrreq                 (),
    .core_sys_rw_port_req_wrbusy                (),
    .ddr3_addr                                  (ddr3_addr                                  ),
    .ddr3_ba                                    (ddr3_ba                                    ),
    .ddr3_cas_n                                 (ddr3_cas_n                                 ),
    .ddr3_ck_n                                  (ddr3_ck_n                                  ),
    .ddr3_ck_p                                  (ddr3_ck_p                                  ),
    .ddr3_cke                                   (ddr3_cke                                   ),
    .ddr3_cs_n                                  (ddr3_cs_n                                  ),
    .ddr3_dm                                    (ddr3_dm                                    ),
    .ddr3_dq                                    (ddr3_dq                                    ),
    .ddr3_dqs_n                                 (ddr3_dqs_n                                 ),
    .ddr3_dqs_p                                 (ddr3_dqs_p                                 ),
    .ddr3_odt                                   (ddr3_odt                                   ),
    .ddr3_ras_n                                 (ddr3_ras_n                                 ),
    .ddr3_reset_n                               (ddr3_reset_n                               ),
    .ddr3_we_n                                  (ddr3_we_n                                  ),
    .ddr3_proxy_bram_mntr_addr                  (),
    .ddr3_proxy_bram_mntr_clk                   (),
    .ddr3_proxy_bram_mntr_din                   (),
    .ddr3_proxy_bram_mntr_dout                  (),
    .ddr3_proxy_bram_mntr_en                    (),
    .ddr3_proxy_bram_mntr_rst                   (),
    .ddr3_proxy_bram_mntr_we                    (),
    .ddr_270_clk                                (clk_store_sys_clk_out5                     ),
    .ddr_clk                                    (clk_store_sys_clk_out4                     ),
    .coeff_table_ddr3_base_addr                 (coeff_table_ddr3_base_addr                 ),
    .ips                                        (ips                                        ),
    .trigger                                    (dut_if_h.pb_vif.trigger_in                 ),
    .fr30_clk                                   (clk_store_sys_clk_out6                     ),
    .fr60_clk                                   (clk_store_sys_clk_out7                     ),
    .pb_master_clk                              (proxy_board_master_clk                     ),
    .mipi_csi_axis_tdata                        (),
    .mipi_csi_axis_tdest                        (),
    .mipi_csi_axis_tkeep                        (),
    .mipi_csi_axis_tlast                        (),
    .mipi_csi_axis_tready                       (),
    .mipi_csi_axis_tuser                        (),
    .mipi_csi_axis_tvalid                       (),
    .proxy_board_sens_hsync                     (proxy_board_hsync                          ),
    .proxy_board_sens_pixel                     (proxy_board_pixel                          ),
    .proxy_board_sens_trigger                   (proxy_board_trigger                        ),
    .proxy_board_sens_vsync                     (proxy_board_vsync                          ),
    .ref_clk                                    (clk_store_sys_clk_out1                     ),
    .sys_rst_n                                  (rst_n                                      ),
    .sensor_pixel_rst_n                         (rst_n                                      ),
    .proxy_board_pixel_clk                      (proxy_board_pixel_clk                      ),
    .sys_clk                                    (clk_store_sys_clk_out2                     ),
    .sys_135_clk                                (clk_store_sys_clk_out3                     )
);


wire ddr3_ck_p_1 = ddr3_ck_p;
`ifdef HANDLE_GATE_SIM_BUG
    wire ddr3_ck_n_1 = ~ddr3_ck_n;
`else
    wire ddr3_ck_n_1 = ddr3_ck_n;
`endif

    ddr3 u_ram
    (
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
