/***************************************************************************************************
    Project         :   AM
    Date            :   June 2026
    Class           :   dut_test_image_hc
    Description     :
***************************************************************************************************/


`undef DUT_TEST_NAME
`define DUT_TEST_NAME dut_test_ffc

// ************************************************************************************************
class `DUT_TEST_NAME extends dut_test;
    `uvm_component_utils(`DUT_TEST_NAME)

    extern function       new(string name =  `STR(`DUT_TEST_NAME), uvm_component parent = null);
    extern function void  build_phase(uvm_phase phase);
    extern function void  start_of_simulation_phase(uvm_phase phase);
    extern task           run_phase(uvm_phase phase);
endclass
// *************************************************************************************************


// *************************************************************************************************
function `DUT_TEST_NAME::new(string name = `STR(`DUT_TEST_NAME), uvm_component parent = null);
  super.new(name, parent);
endfunction


function void `DUT_TEST_NAME::build_phase(uvm_phase phase);
  super.build_phase(phase);

  /* override customm txn */
  dutb_txn_base::type_id::set_inst_override(
    init_ips_txn_default::get_type(), `DUTB_AGNT(INIT_IPS_AGNT_IDX));

  dutb_txn_base::type_id::set_inst_override(
    ffc_req_txn::get_type(), `DUTB_AGNT(FFC_REQ_AGNT_IDX));

  /* configure agents */
  uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(FFC_REQ_AGNT_IDX), 1'b1);

endfunction


function void `DUT_TEST_NAME::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  this.env_h.agent_h[FFC_REQ_AGNT_IDX].driver_h.set_report_verbosity_level(UVM_DEBUG);
endfunction


task `DUT_TEST_NAME::run_phase(uvm_phase phase);
  dutb_txn_seq #(ffc_req_txn) ffc_req_seq_h = new("ffc_req_seq_h");

  phase.raise_objection(this, "dut_test started");
  fork
    run_base_test_seq();
    ffc_req_seq_h.start(env_h.agent_h[FFC_REQ_AGNT_IDX].driver_h.sqncr_h);
  join
  phase.drop_objection(this, "dut_test finished");
endtask
// *************************************************************************************************
