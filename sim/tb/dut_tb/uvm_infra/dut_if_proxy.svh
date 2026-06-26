/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   dut_if_proxy
    Description     :   Used to provide spesific DUT interface to all uvm infra.
******************************************************************************************************************************/


// ****************************************************************************************************************************
class dut_if_proxy extends dutb_if_proxy_base;
    `uvm_component_utils (dut_if_proxy)

    virtual dut_if          dut_vif;
    base_func_proxy         top_func_proxy;

    extern function         new(string name = "dut_if_proxy", uvm_component parent=null);
    extern function void    build_phase(uvm_phase phase);
endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function dut_if_proxy::new(string name = "dut_if_proxy", uvm_component parent=null);
    super.new(name, parent);
endfunction


function void dut_if_proxy::build_phase(uvm_phase phase);
    super.build_phase(phase);
    // connect to DUT interface
    if (!uvm_config_db #(virtual dut_if)::get(this, "", "dut_vif", dut_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'dut_vif' from config db")

    if (!uvm_config_db #(base_func_proxy)::get(this, "", "top_func_proxy", top_func_proxy))
        `uvm_fatal("CFG_DB", "Unable to get 'top_func_proxy' from config db")

endfunction
// ****************************************************************************************************************************
