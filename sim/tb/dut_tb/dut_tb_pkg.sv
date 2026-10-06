/**************************************************************************************************
    Project         :   AM
    Date            :   Sep 2025
    Package         :   dut_tb_pkg
    Description     :
**************************************************************************************************/


package dut_tb_pkg;
`include "uvm_macros.svh"
`include "dutb_macros.svh"
`include "dut_tb_macros.svh"

import uvm_pkg::*;
import dutb_util_pkg::*;
import dutb_pkg::*;
import oct640_cu_util_pkg::*;

`include "mc_const.vh"

// UVM infra
`include "uvm_infra/base_func_proxy.svh"
`include "uvm_infra/dut_if_proxy.svh"

// txn
`include "uvm_infra/txn/init_ips_txn.svh"
`include "uvm_infra/txn/ffc_req_txn.svh"
`include "uvm_infra/txn/init_ddr3_txn.svh"
`include "uvm_infra/txn/sns_rd_coeff_txn.svh"
`include "uvm_infra/txn/sns_rd_ddr3_txn.svh"
`include "uvm_infra/txn/core_sys_txn.svh"
`include "uvm_infra/txn/proxy_board_image_txn.svh"
`include "uvm_infra/txn/proxy_board_trigger_txn.svh"
`include "uvm_infra/txn/mipi_csi_axis_txn.svh"
`include "uvm_infra/txn/image_hc_stream_txn.svh"
// `include "uvm_infra/proxy_board_test_seq.svh"
`include "uvm_infra/dut_agent_idx.svh"
`include "uvm_infra/dut_test.svh"
`include "uvm_infra/dut_test_0.svh"
endpackage
