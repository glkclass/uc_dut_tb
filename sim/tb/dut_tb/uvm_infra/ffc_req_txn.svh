/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2026
    Class           :   ffc_req_txn
    Description     :   Applies ffc request usigng ips appropriate bit.
******************************************************************************************************************************/

`undef TXN_NAME
`define TXN_NAME ffc_req_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// ****************************************************************************************************************************
class `TXN_NAME extends init_ips_txn;
    `uvm_object_utils(`TXN_NAME)

    bit ffc_req;

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

    #1ms
    @(posedge dut_vif.sys_clk);
    vif.ips[`IPS_FFC_REQ_OFFS] = 1'b1;
    repeat (16) @(posedge dut_vif.sys_clk);
    vif.ips[`IPS_FFC_REQ_OFFS] = 1'b0;

    wait(0);
endtask
// ****************************************************************************************************************************



