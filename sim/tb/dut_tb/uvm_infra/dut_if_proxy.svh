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
    virtual image_hc_if     dut_image_hc_vif;
    virtual sns_rd_coeff_if sns_rd_coeff_vif;
    virtual sns_rd_ddr3_if  sns_rd_ddr3_vif;
    virtual sns_rd_ddr3_bram_if sns_rd_ddr3_bram_vif;
    virtual pb_if           pb_vif;
    virtual sys_if          sys_vif;
    virtual sm_core_rw_if   core_sys_rw_vif;
    virtual axis_if         axis_vif;
    virtual uvc_if          uvc_vif;
    virtual histo_bram_if   histo_bram_0_vif;
    virtual histo_bram_if   histo_bram_1_vif;
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

    // connect to DUT interfaces
    if (!uvm_config_db #(virtual image_hc_if)::get(this, "", "dut_image_hc_vif", dut_image_hc_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'image_hc_bind_if' from config db")

    if (!uvm_config_db #(virtual sns_rd_coeff_if)::get(this, "", "sns_rd_coeff_vif", sns_rd_coeff_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'sns_rd_coeff_bind_if' from config db")

    if (!uvm_config_db #(virtual sns_rd_ddr3_if)::get(this, "", "sns_rd_ddr3_vif", sns_rd_ddr3_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'sns_rd_ddr3_bind_if' from config db")

    if (!uvm_config_db #(virtual sns_rd_ddr3_bram_if)::get(this, "", "sns_rd_ddr3_bram_vif", sns_rd_ddr3_bram_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'sns_rd_ddr3_bram_bind_if' from config db")

    if (!uvm_config_db #(virtual pb_if)::get(this, "", "pb_vif", pb_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'pb_bind_if' from config db")

    if (!uvm_config_db #(virtual sys_if)::get(this, "", "sys_vif", sys_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'sys_bind_if' from config db")

    if (!uvm_config_db #(virtual sm_core_rw_if)::get(this, "", "core_sys_rw_vif", core_sys_rw_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'core_sys_rw_bind_if' from config db")

    if (!uvm_config_db #(virtual axis_if)::get(this, "", "axis_vif", axis_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'axis_bind_if' from config db")

    if (!uvm_config_db #(virtual uvc_if)::get(this, "", "uvc_vif", uvc_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'uvc_bind_if' from config db")

    if (!uvm_config_db #(virtual histo_bram_if)::get(this, "", "histo_bram_0_vif", histo_bram_0_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'monitor_memory_bind_if' from config db")

    if (!uvm_config_db #(virtual histo_bram_if)::get(this, "", "histo_bram_1_vif", histo_bram_1_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'monitor_memory_bind_if' from config db")

    if (!uvm_config_db #(virtual dut_if)::get(this, "", "dut_vif", dut_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get 'dut_vif' from config db")

    if (!uvm_config_db #(base_func_proxy)::get(this, "", "top_func_proxy", top_func_proxy))
        `uvm_fatal("CFG_DB", "Unable to get 'top_func_proxy' from config db")

endfunction
// ****************************************************************************************************************************
