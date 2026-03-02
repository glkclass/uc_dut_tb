/******************************************************************************************************************************
    Project         :   AM
    Date            :   Sep 2025
    Package         :   dut_tb_pkg
    Description     :
******************************************************************************************************************************/


package dut_tb_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;


    `include "dutb_macros.svh"
    import dutb_util_pkg::*;
    import dutb_pkg::*;

    import oct640_am_util_pkg::*;

    `include "../../../rtl/common/mc_const.vh"

    // UVM infra
    `include "uvm_infra/dut_if_proxy.svh"
    `include "uvm_infra/sns_rd_coeff_txn.svh"
    `include "uvm_infra/sns_rd_ddr3_txn.svh"
    `include "uvm_infra/core_sys_txn.svh"
    `include "uvm_infra/proxy_board_image_txn.svh"
    `include "uvm_infra/proxy_board_trigger_txn.svh"
    `include "uvm_infra/mipi_csi_axis_txn.svh"
    // `include "uvm_infra/proxy_board_test_seq.svh"
    `include "uvm_infra/dut_test.svh"
endpackage




