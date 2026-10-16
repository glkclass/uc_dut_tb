/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Interface       :   dut_if
    Description     :
***************************************************************************************************/

`include "dut_tb_macros.svh"

`default_nettype none

import oct640_cu_util_pkg::N_IMAGE_COL;
import oct640_cu_util_pkg::N_IMAGE_ROW;

import oct640_cu_util_pkg::N_IMAGE_COL_W;
import oct640_cu_util_pkg::N_IMAGE_ROW_W;


import oct640_cu_util_pkg::COEFF_A_W;
import oct640_cu_util_pkg::COEFF_B_W;

import oct640_cu_util_pkg::IMAGE_PIXEL_W;
import oct640_cu_util_pkg::AXIS_DATA_W;

import oct640_cu_util_pkg::RAM_DATA_W;

import oct640_cu_util_pkg::DDR3_ROW_ADDR_W;
import oct640_cu_util_pkg::DDR3_COL_W;
import oct640_cu_util_pkg::BST_SIZE_W;
import oct640_cu_util_pkg::BST_NUM_W;
import oct640_cu_util_pkg::DDR3_DQ_W;

// *************************************************************************************************
interface dut_if (
  input wire                  rst_n,
  input wire                  ddr_initilaized,
  input wire                  sys_clk
);
endinterface


interface image_hc_if #(
  parameter integer N_IMAGE_ROW_W = `IMAGE_HC_PATH(N_IMAGE_ROW_W),
  parameter integer N_IMAGE_COL_W = `IMAGE_HC_PATH(N_IMAGE_COL_W),
  parameter integer IMAGE_PIXEL_W = `IMAGE_HC_PATH(IMAGE_PIXEL_W),
  parameter integer HISTO_ADDR_W = `IMAGE_HC_PATH(HISTO_ADDR_W),
  parameter integer HISTO_ACC_W = `IMAGE_HC_PATH(HISTO_ACC_W),
  parameter integer HISTO_PROCESS_FSM_W = `IMAGE_HC_PATH(HISTO_PROCESS_FSM_W)
)(

  input wire                                  i_pixel_clk,
  input wire                                  i_sys_rst_n,
  input wire [16 - 1                 :   0]   image_s_sens_img_frame_number,
  input wire [N_IMAGE_ROW_W - 1      :   0]   image_s_sens_img_row_number,
  input wire                                  image_s_sens_img_frame_start,
  input wire                                  image_s_sens_img_row_start,
  input wire                                  image_s_sens_img_bank_en,
  input wire                                  image_s_sens_img_bank_we,
  input wire [N_IMAGE_COL_W - 1      :   0]   image_s_sens_img_bank_addr,
  input wire [IMAGE_PIXEL_W - 1      :   0]   image_s_sens_img_bank_din,

  input wire  [HISTO_ADDR_W - 1 : 0]          histo_left_point_i,
  input wire  [HISTO_ADDR_W - 1 : 0]          histo_right_point_i,
  input wire                                  histo_bank_sel,

  input wire                                  bank_0_we,
  input wire                                  bank_0_re,
  input wire [HISTO_ADDR_W - 1 : 0]           bank_0_addra,
  input wire [HISTO_ADDR_W - 1 : 0]           bank_0_addrb,
  input wire [HISTO_ACC_W - 1 : 0]            bank_0_dina,
  input wire [HISTO_ACC_W - 1 : 0]            bank_0_dout,

  input wire                                  bank_1_we,
  input wire                                  bank_1_re,
  input wire [HISTO_ADDR_W - 1 : 0]           bank_1_addra,
  input wire [HISTO_ADDR_W - 1 : 0]           bank_1_addrb,
  input wire [HISTO_ACC_W - 1 : 0]            bank_1_dina,
  input wire [HISTO_ACC_W - 1 : 0]            bank_1_dout,

  input wire [HISTO_PROCESS_FSM_W - 1 : 0]    histo_process_pr_state


);
endinterface


interface histo_bram_if #(
  parameter integer MEMORY_WIDTH = 18,
  parameter integer MEMORY_DEPTH = 16384
) (
  input wire [MEMORY_WIDTH - 1 : 0] memory [0 : MEMORY_DEPTH - 1]
);
endinterface


interface sns_rd_coeff_if #(
  parameter integer RAM_DATA_W = `SENS_STREAMER_PATH(RAM_DATA_W),
  parameter integer COEFF_A_W = `SENS_STREAMER_PATH(COEFF_A_W),
  parameter integer COEFF_B_W = `SENS_STREAMER_PATH(COEFF_B_W)
) (
  input wire i_sensor_pixel_clk,
  input wire row_start,
  input wire coeff_pixel_valid,
  input wire [9 - 1 : 0] coeff_bank_addr,
  input wire [4 * RAM_DATA_W - 1 : 0] coeff_ram_data_b,
  input wire [2 * RAM_DATA_W - 1 : 0] coeff_3_2,
  input wire [3 * RAM_DATA_W - 1 : 0] coeff_2_1_0,
  input wire [RAM_DATA_W - 1 : 0] coeff_0,
  input wire [RAM_DATA_W - 1 : 0] coeff_1,
  input wire [RAM_DATA_W - 1 : 0] coeff_2,
  input wire unsigned [COEFF_A_W - 1 : 0] coeff_a,
  input wire signed [COEFF_B_W - 1 : 0] coeff_b
);
endinterface

interface sns_rd_ddr3_if #(
  parameter integer DDR3_ROW_ADDR_W = `SENS_STREAMER_PATH(DDR3_ROW_ADDR_W),
  parameter integer DDR3_COL_W = `SENS_STREAMER_PATH(DDR3_COL_W),
  parameter integer BST_SIZE_W = `SENS_STREAMER_PATH(BST_SIZE_W),
  parameter integer BST_NUM_W = `SENS_STREAMER_PATH(BST_NUM_W),
  parameter integer DDR3_DQ_W = `SENS_STREAMER_PATH(DDR3_DQ_W)
) (
  input wire i_sys_clk,
  input wire rd_coeff_ddr3_m_smc_rw_req,
  input wire rd_coeff_ddr3_m_smc_rw_mod,
  input wire rd_coeff_ddr3_m_smc_rw_bsy,
  input wire [DDR3_ROW_ADDR_W - 1 : 0] rd_coeff_ddr3_m_smc_row_base_addr,
  input wire [DDR3_COL_W - 4 : 0] rd_coeff_ddr3_m_smc_bl8_offs,
  input wire [BST_SIZE_W - 1 : 0] rd_coeff_ddr3_m_smc_burst_size,
  input wire [BST_NUM_W - 1 : 0] rd_coeff_ddr3_m_smc_burst_num,
  input wire rd_coeff_ddr3_m_smc_bank_en,
  input wire [1 + DDR3_COL_W - 2 - 1 : 0] rd_coeff_ddr3_m_smc_bank_addr,
  input wire [4 * DDR3_DQ_W - 1 : 0] rd_coeff_ddr3_m_smc_bank_dout
);
endinterface


interface sns_rd_ddr3_bram_if #(
  parameter integer DDR3_COL_W = `SENS_STREAMER_PATH(DDR3_COL_W),
  parameter integer DDR3_DQ_W = `SENS_STREAMER_PATH(DDR3_DQ_W)
) (
  input wire i_sys_clk,
  input wire rd_coeff_ddr3_m_smc_bank_we,
  input wire [1 + DDR3_COL_W - 2 - 1 : 0] rd_coeff_ddr3_m_smc_bank_addr,
  input wire [4 * DDR3_DQ_W - 1 : 0] rd_coeff_ddr3_m_smc_bank_din
);
endinterface


interface sm_core_rw_if #(
  parameter integer BANK_ADDR_W = $bits(`IPP_PATH(core_sys_rw_port_smc_bank_addr)),
  parameter integer BANK_DATA_W = $bits(`IPP_PATH(core_sys_rw_port_smc_bank_din)),
  parameter integer BL8_OFFS_W = $bits(`IPP_PATH(core_sys_rw_port_smc_bl8_offs)),
  parameter integer BURST_NUM_W = $bits(`IPP_PATH(core_sys_rw_port_smc_burst_num)),
  parameter integer BURST_SIZE_W = $bits(`IPP_PATH(core_sys_rw_port_smc_burst_size)),
  parameter integer ROW_BASE_ADDR_W = $bits(`IPP_PATH(core_sys_rw_port_smc_row_base_addr))
) (
  output logic [BANK_ADDR_W - 1 : 0] core_sys_rw_port_smc_bank_addr,
  output logic [BANK_DATA_W - 1 : 0] core_sys_rw_port_smc_bank_din,
  input wire [BANK_DATA_W - 1 : 0] core_sys_rw_port_smc_bank_dout,
  input wire core_sys_rw_port_smc_bank_en,
  input wire core_sys_rw_port_smc_bank_we,
  output logic [BL8_OFFS_W - 1 : 0] core_sys_rw_port_smc_bl8_offs,
  output logic [BURST_NUM_W - 1 : 0] core_sys_rw_port_smc_burst_num,
  output logic [BURST_SIZE_W - 1 : 0] core_sys_rw_port_smc_burst_size,
  output logic [ROW_BASE_ADDR_W - 1 : 0] core_sys_rw_port_smc_row_base_addr,
  input wire core_sys_rw_port_smc_rw_bsy,
  output logic core_sys_rw_port_smc_rw_mod,
  output logic core_sys_rw_port_smc_rw_req
);
endinterface


interface pb_if #(
  parameter integer IMAGE_PIXEL_W = $bits(`IPP_PATH(proxy_board_sens_pixel))
) (
  output  logic proxy_board_pixel_clk,
  output  logic proxy_board_sens_hsync,
  output  logic [IMAGE_PIXEL_W - 1 : 0] proxy_board_sens_pixel,
  output  logic proxy_board_sens_vsync,
  output  logic trigger,
  input   wire  pb_master_clk,
  input   wire  proxy_board_sens_trigger
);
endinterface


interface sys_if #(
  parameter integer IPS_W = $bits(`IPP_PATH(ips)),
  parameter integer IPST_W = $bits(`IPP_PATH(ipst)),
  parameter integer COEFF_TABLE_DDR3_BASE_ADDR_W = $bits(`IPP_PATH(coeff_table_ddr3_base_addr))
) (
  output logic [IPS_W - 1 : 0] ips = '0,
  output logic [COEFF_TABLE_DDR3_BASE_ADDR_W - 1 : 0] coeff_table_ddr3_base_addr = '0,
  input wire [IPST_W - 1 : 0] ipst,
  input wire ips_mipi_csi_phy_rst
);
endinterface


interface axis_if #(
  parameter integer TDATA_W = $bits(`IPP_PATH(mipi_csi_axis_tdata)),
  parameter integer TDEST_W = $bits(`IPP_PATH(mipi_csi_axis_tdest)),
  parameter integer TKEEP_W = $bits(`IPP_PATH(mipi_csi_axis_tkeep)),
  parameter integer TUSER_W = $bits(`IPP_PATH(mipi_csi_axis_tuser))
) (
  input wire [TDATA_W - 1 : 0] mipi_csi_axis_tdata,
  input wire [TDEST_W - 1 : 0] mipi_csi_axis_tdest,
  input wire [TKEEP_W - 1 : 0] mipi_csi_axis_tkeep,
  input wire mipi_csi_axis_tlast,
  output logic mipi_csi_axis_tready = 1'b0,
  input wire [TUSER_W - 1 : 0] mipi_csi_axis_tuser,
  input wire mipi_csi_axis_tvalid
);

  logic                                               axis_hsh;
  logic   [TDATA_W / 4 - 1    :   0]                  axis_tword[4];
  logic                                               axis_frame_start;
  logic   [6 - 1    :   0]                            mipi_csi_data_type;
  logic   [16 - 1    :   0]                           mipi_csi_frame_number;
  logic   [16 - 1    :   0]                           mipi_csi_row_number;
  logic   [16 - 1    :   0]                           mipi_csi_word_count;


  assign axis_hsh = mipi_csi_axis_tvalid & mipi_csi_axis_tready;        // axis handshake

  assign axis_tword[0] = mipi_csi_axis_tdata[1 * (TDATA_W / 4) - 1 : 0 * (TDATA_W / 4)];
  assign axis_tword[1] = mipi_csi_axis_tdata[2 * (TDATA_W / 4) - 1 : 1 * (TDATA_W / 4)];
  assign axis_tword[2] = mipi_csi_axis_tdata[3 * (TDATA_W / 4) - 1 : 2 * (TDATA_W / 4)];
  assign axis_tword[3] = mipi_csi_axis_tdata[4 * (TDATA_W / 4) - 1 : 3 * (TDATA_W / 4)];

  assign axis_frame_start         = mipi_csi_axis_tuser[0];
  assign mipi_csi_data_type       = mipi_csi_axis_tuser[7  : 1];
  assign mipi_csi_frame_number    = mipi_csi_axis_tuser[31 : 16];
  assign mipi_csi_row_number      = mipi_csi_axis_tuser[47 : 32];
  assign mipi_csi_word_count      = mipi_csi_axis_tuser[63 : 48];
endinterface


interface uvc_if #(
  parameter integer TDATA_W = $bits(`IPP_PATH(uvc_axis_tdata)),
  parameter integer TDEST_W = $bits(`IPP_PATH(uvc_axis_tdest)),
  parameter integer TKEEP_W = $bits(`IPP_PATH(uvc_axis_tkeep)),
  parameter integer TUSER_W = $bits(`IPP_PATH(uvc_axis_tuser))
) (
  input wire [TDATA_W - 1 : 0] uvc_axis_tdata,
  input wire [TDEST_W - 1 : 0] uvc_axis_tdest,
  input wire [TKEEP_W - 1 : 0] uvc_axis_tkeep,
  input wire uvc_axis_tlast,
  output logic uvc_axis_tready = 1'b0,
  input wire [TUSER_W - 1 : 0] uvc_axis_tuser,
  input wire uvc_axis_tvalid
);
endinterface


interface ddr3_if #(
  parameter integer ADDR_W = $bits(`IPP_PATH(ddr3_addr)),
  parameter integer BANK_W = $bits(`IPP_PATH(ddr3_ba)),
  parameter integer DM_W = $bits(`IPP_PATH(ddr3_dm)),
  parameter integer DQS_W = $bits(`IPP_PATH(ddr3_dqs_p)),
  parameter integer DQ_W = $bits(`IPP_PATH(ddr3_dq))
);
  wire reset_n;
  wire ck_p;
  wire ck_n;
  wire odt;
  wire cke;
  wire cs_n;
  wire ras_n;
  wire cas_n;
  wire we_n;
  wire [BANK_W - 1 : 0] ba;
  wire [ADDR_W - 1 : 0] addr;
  wire [DM_W - 1 : 0] dm;
  tri [DQS_W - 1 : 0] dqs_p;
  tri [DQS_W - 1 : 0] dqs_n;
  tri [DQ_W - 1 : 0] dq;


  wire ddr3_ck_p = ddr3_bus.ck_p;
`ifdef HANDLE_GATE_SIM_BUG
  wire ddr3_ck_n = ~ddr3_bus.ck_n;
`else
  wire ddr3_ck_n = ddr3_bus.ck_n;
`endif
endinterface

`default_nettype wire

// *************************************************************************************************
