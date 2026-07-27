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
  dutb_txn_seq #(ffc_req_txn) ffc_req_seq_h = new("ffc_req_seq_h");

  phase.raise_objection(this, "dut_test started");
  fork
    run_base_test_seq();
    ffc_req_seq_h.start(env_h.agent_h[FFC_REQ].driver_h.sqncr_h);
  join
  phase.drop_objection(this, "dut_test finished");
endtask
// ****************************************************************************************************************************
