/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   dut_test_0
    Description     :
******************************************************************************************************************************/


// ****************************************************************************************************************************
class dut_test_0 extends dut_test;
    `uvm_component_utils(dut_test_0)

    extern function             new(string name = "dut_test_0", uvm_component parent = null);
    extern function void        build_phase(uvm_phase phase);
    extern function void        start_of_simulation_phase(uvm_phase phase);
    extern task                 run_phase(uvm_phase phase);
endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function dut_test_0::new(string name = "dut_test_0", uvm_component parent = null);
    super.new(name, parent);
endfunction


function void dut_test_0::build_phase(uvm_phase phase);
    super.build_phase(phase);
    dutb_txn_base::type_id::set_inst_override(init_ips_txn_default::get_type(), `DUTB_AGNT(INIT_IPS));
endfunction


function void dut_test_0::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction


task dut_test_0::run_phase(uvm_phase phase);
    // proxy_board_test_seq seq_h = proxy_board_test_seq::type_id::create("seq_h");
    // dutb_txn_seq #(proxy_board_image_txn) seq_h = dutb_txn_seq #(proxy_board_image_txn)::type_id::create("seq_h", this);  // doesn't propagate type parameter ???

    dutb_txn_seq #(init_ips_txn) init_ips_seq_h = new("init_ips_seq_h");
    dutb_txn_seq #(init_ddr3_txn) init_ddr3_seq_h = new("init_ddr3_seq_h");
    // dutb_txn_seq #(proxy_board_trigger_txn) pb_trigger_seq_h = new("pb_trigger_seq_h");
    dutb_txn_seq #(proxy_board_image_txn) pb_image_seq_h = new("pb_image_seq_h");
    dutb_txn_seq #(core_sys_txn) cs_seq_h = new("cs_seq_h");

    phase.raise_objection(this, "dut_test started");
    fork
        init_ips_seq_h.start(env_h.agent_h[INIT_IPS].driver_h.sqncr_h);
        init_ddr3_seq_h.start(env_h.agent_h[INIT_DDR3].driver_h.sqncr_h);
        pb_image_seq_h.start(env_h.agent_h[PROXY_BOARD_IMAGE].driver_h.sqncr_h);
        cs_seq_h.start(env_h.agent_h[CORE_SYS].driver_h.sqncr_h);
        // pb_trigger_seq_h.start(env_h.agent_h[PROXY_BOARD_TRIGGER].driver_h.sqncr_h);
        // dutb_handler_h.wait_for_stop_test();
    join
    phase.drop_objection(this, "dut_test finished");
endtask
// ****************************************************************************************************************************
