/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Interface       :   dut_if
    Description     :
******************************************************************************************************************************/


import oct640_am_util_pkg::COEFF_A_W;
import oct640_am_util_pkg::COEFF_B_W;

import oct640_am_util_pkg::IMAGE_PIXEL_W;
import oct640_am_util_pkg::AXIS_DATA_W;

import oct640_am_util_pkg::RAM_DATA_W;

import oct640_am_util_pkg::DDR3_ROW_ADDR_W;
import oct640_am_util_pkg::DDR3_COL_W;
import oct640_am_util_pkg::BST_SIZE_W;
import oct640_am_util_pkg::BST_NUM_W;
import oct640_am_util_pkg::DDR3_DQ_W;

// ****************************************************************************************************************************
interface dut_if (
    input rst_n, ddr_initilaized, sys_clk );
    pb_if               pb_vif();
    axis_if             csi_vif();
    sm_core_rw_if       core_sys_rw_vif();
    sns_rd_ddr3_if      sns_rd_ddr3_vif();
    sns_rd_coeff_if     sns_rd_coeff_vif();
endinterface


interface sns_rd_coeff_if ();
    // coeff rd domain
    logic                                           row_start_sys_clk;
    logic                                           i_sensor_pixel_clk;
    logic                                           coeff_pixel_valid;
    logic   [9 - 1                      :   0]      coeff_ram_addr_b;   // 4k = 2 * 256 x 64
    logic   [4 * RAM_DATA_W - 1         :   0]      coeff_ram_data_b;   // 64
    logic   [2 * RAM_DATA_W - 1         :   0]      coeff_3_2;          // 32
    logic   [3 * RAM_DATA_W - 1         :   0]      coeff_2_1_0;        // 48
    logic   [RAM_DATA_W - 1             :   0]      coeff_0, coeff_1, coeff_2;

    logic   unsigned  [COEFF_A_W - 1      :   0]    coeff_a;
    logic   signed    [COEFF_B_W - 1      :   0]    coeff_b;


endinterface

interface sns_rd_ddr3_if ();
    // ddr3 sm core rd port for coeff reading
    logic                                               rd_coeff_req_rdreq;
    logic                                               rd_coeff_req_rdbusy;
    logic      [DDR3_ROW_ADDR_W - 1        : 0]         rd_coeff_req_row_base_addr;
    logic      [DDR3_COL_W - 4             : 0]         rd_coeff_req_bl8_offs;
    logic      [BST_SIZE_W - 1             : 0]         rd_coeff_req_burst_size;
    logic      [BST_NUM_W - 1              : 0]         rd_coeff_req_burst_num;

    logic                                               rd_coeff_bram_clk;
    logic                                               rd_coeff_bram_we;
    logic      [1 + DDR3_COL_W - 3          : 0]        rd_coeff_bram_addr;
    logic      [4 * DDR3_DQ_W - 1           : 0]        rd_coeff_bram_din;
endinterface


interface sm_core_rw_if ();
  logic [8:0]   bram_addr;
  logic         bram_clk;
  logic [63:0]  bram_din;
  logic [63:0]  bram_dout;
  logic         bram_en;
  logic         bram_we;
  logic [6:0]   req_bl8_offs;
  logic [2:0]   req_burst_num;
  logic [6:0]   req_burst_size;
  logic         req_rdreq;
  logic         req_rdbusy;
  logic [17:0]  req_row_base_addr;
  logic         req_wrreq;
  logic         req_wrbusy;
endinterface


interface pb_if ();
    // sensor image if
    logic [IMAGE_PIXEL_W - 1    :   0]  data;
    logic
        master_clk = 1'b0,
        pixel_clk = 1'b0,
        hsync = 1'b0,
        vsync = 1'b0,
        trigger_in = 1'b0,
        trigger_out = 1'b0;

    // spi configuration if
    logic
        sck,
        cs_n,
        mosi;
endinterface



interface axis_if ();
    // AXI Stream if (sys_clk)
    logic   [3 * 4 * AXIS_DATA_W - 1    :   0]          axis_tdata;
    logic   [2 - 1                      :   0]          axis_tdest;
    logic   [24 - 1                     :   0]          axis_tkeep;
    logic                                               axis_tlast;
    logic   [96 - 1                     :   0]          axis_tuser;
    logic                                               axis_tvalid;
    logic                                               axis_tready = 1'b0;
    //
    logic                                               axis_hsh;
    logic   [AXIS_DATA_W - 1    :   0]                  axis_tword[4];
    logic                                               axis_frame_start;
    logic   [6 - 1    :   0]                            mipi_csi_data_type;
    logic   [16 - 1    :   0]                           mipi_csi_frame_number;
    logic   [16 - 1    :   0]                           mipi_csi_row_number;
    logic   [16 - 1    :   0]                           mipi_csi_word_count;



    assign         axis_hsh = axis_tvalid & axis_tready;        // axis handshake

    assign         axis_tword[0] = axis_tdata[1 * AXIS_DATA_W - 1 : 0 * AXIS_DATA_W];
    assign         axis_tword[1] = axis_tdata[2 * AXIS_DATA_W - 1 : 1 * AXIS_DATA_W];
    assign         axis_tword[2] = axis_tdata[3 * AXIS_DATA_W - 1 : 2 * AXIS_DATA_W];
    assign         axis_tword[3] = axis_tdata[4 * AXIS_DATA_W - 1 : 3 * AXIS_DATA_W];

    assign         axis_frame_start         = axis_tuser[0];
    assign         mipi_csi_data_type       = axis_tuser[7  : 1];
    assign         mipi_csi_frame_number    = axis_tuser[31 : 16];
    assign         mipi_csi_row_number      = axis_tuser[47 : 32];
    assign         mipi_csi_word_count      = axis_tuser[63 : 48];



endinterface




// ****************************************************************************************************************************

