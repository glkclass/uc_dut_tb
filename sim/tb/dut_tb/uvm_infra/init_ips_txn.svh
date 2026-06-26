/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   init_ips_txn
    Description     :   Init ips params
******************************************************************************************************************************/


`define TXN_NAME init_ips_txn
// ****************************************************************************************************************************
class `TXN_NAME
extends dutb_txn_base;
    `uvm_object_utils(`TXN_NAME)

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;
    virtual sys_if vif;

    extern function                             new (string name = `STR(`TXN_NAME));
    extern virtual  task                        drive (input dutb_if_proxy_base dutb_if);

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME));
    super.new(name);
endfunction


task `TXN_NAME::drive(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    vif = dut_if_h.dut_vif.sys_vif;

    vif.coeff_table_ddr3_base_addr = `DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR >> 11;

    vif.ips[`IPS_PP_TYPE_OFFS + `IPS_PP_TYPE_WIDTH - 1    :   `IPS_PP_TYPE_OFFS] = `IPS_PP_RAW_IMAGE;
    vif.ips[`IPS_FR_TYPE_OFFS] = `IPS_FR_30;
    vif.ips[`IPS_DEAD_PIXEL_MASK_DIS_OFFS] = 1'b1;
    vif.ips[`IPS_TRIGGER_DIS_OFFS] = 1'b1;
    vif.ips[`IPS_FLASHING_LED_DIS_OFFS] = 1'b0;
    vif.ips[`IPS_SOFT_TRIGGER_OFFS] = 1'b0;
    vif.ips[`IPS_MIPI_CSI_STREAM_DIS_OFFS] = 1'b0;

    wait(0);
endtask

// ****************************************************************************************************************************



