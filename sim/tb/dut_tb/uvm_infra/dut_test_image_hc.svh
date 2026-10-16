/***************************************************************************************************
    Project         :   AM
    Date            :   June 2026
    Class           :   dut_test_image_hc
    Description     :
***************************************************************************************************/


`undef DUT_TEST_NAME
`define DUT_TEST_NAME dut_test_image_hc

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

  /* initialization */
  dutb_txn_base::type_id::set_inst_override(
    init_ips_txn_default::get_type(), `DUTB_AGNT(INIT_IPS_AGNT_IDX));

  /* image histo calculator input  */
  dutb_txn_base::type_id::set_inst_override(
    image_hc_in_txn::get_type(), `DUTB_AGNT(IMAGE_HC_IN_AGNT_IDX));

  /* image histo calculator output  */
  dutb_txn_base::type_id::set_inst_override(
    image_hc_out_txn::get_type(), `DUTB_AGNT(IMAGE_HC_OUT_AGNT_IDX));

  /* configure Image histo calculator agents as monitors */
  uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_MONITOR(IMAGE_HC_IN_AGNT_IDX), 1'b1);
  uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_MONITOR(IMAGE_HC_OUT_AGNT_IDX), 1'b1);

  /* subscribe scb to Image histo calculator agent.monitors */
  uvm_config_db #(int)::set(this, "env_h", `DUTB_SCB(IMAGE_HC_SCB_IDX, 0), IMAGE_HC_IN_AGNT_IDX);
  uvm_config_db #(int)::set(this, "env_h", `DUTB_SCB(IMAGE_HC_SCB_IDX, 1), IMAGE_HC_OUT_AGNT_IDX);
endfunction


function void `DUT_TEST_NAME::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  // Configure log
  this.env_h.agent_h[IMAGE_HC_IN_AGNT_IDX].monitor_h.set_report_verbosity_level(UVM_FULL);
  this.env_h.agent_h[IMAGE_HC_OUT_AGNT_IDX].monitor_h.set_report_verbosity_level(UVM_FULL);
  this.env_h.scb_h[IMAGE_HC_SCB_IDX].set_report_verbosity_level(UVM_FULL);
endfunction


task `DUT_TEST_NAME::run_phase(uvm_phase phase);
  phase.raise_objection(this, "dut_test started");
  run_base_test_seq();
  phase.drop_objection(this, "dut_test finished");
endtask
// *************************************************************************************************
