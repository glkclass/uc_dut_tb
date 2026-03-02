/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   dut_test
    Description     :
******************************************************************************************************************************/


// ****************************************************************************************************************************
class dut_test extends dutb_test_base #(.N_AGNT(6), .N_SCB(1));
    `uvm_component_utils(dut_test)

    virtual dut_if              dut_vif;

    extern function             new(string name = "dut_test", uvm_component parent = null);
    extern function void        build_phase(uvm_phase phase);
    extern function void        start_of_simulation_phase(uvm_phase phase);
    extern task                 run_phase(uvm_phase phase);
endclass

function dut_test::new(string name = "dut_test", uvm_component parent = null);
    super.new(name, parent);
endfunction
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function void dut_test::build_phase(uvm_phase phase);
    uvm_factory factory = uvm_factory::get();

    dutb_if_proxy_base::type_id::set_type_override(dut_if_proxy::get_type());

    dutb_txn_base::type_id::set_inst_override(proxy_board_image_txn::get_type(), "uvm_test_top.env_h.agent_h[0]*");
    dutb_txn_base::type_id::set_inst_override(mipi_csi_axis_txn::get_type(), "uvm_test_top.env_h.agent_h[1]*");
    dutb_txn_base::type_id::set_inst_override(core_sys_txn::get_type(), "uvm_test_top.env_h.agent_h[2]*");
    dutb_txn_base::type_id::set_inst_override(sns_rd_ddr3_txn::get_type(), "uvm_test_top.env_h.agent_h[3]*");
    dutb_txn_base::type_id::set_inst_override(sns_rd_coeff_txn::get_type(), "uvm_test_top.env_h.agent_h[4]*");
    dutb_txn_base::type_id::set_inst_override(proxy_board_trigger_txn::get_type(), "uvm_test_top.env_h.agent_h[5]*");

    factory.print();


    // Configure env
    // provide dut_if_proxy with dut_vif
    if (!uvm_config_db #(virtual dut_if)::get(this, "", "dut_vif", dut_vif))
        `uvm_fatal("CFG_DB_ERROR", "Unable to get \"dut_vif\" from config db")
    else
        uvm_config_db #(virtual dut_if)::set(this, "env_h.dutb_if_h", "dut_vif", dut_vif);

    // configure agents
    uvm_config_db #(bit)::set(this, "env_h", "agent_h[1]_has_driver", 1'b0);
    uvm_config_db #(bit)::set(this, "env_h", "agent_h[3]_has_driver", 1'b0);
    uvm_config_db #(bit)::set(this, "env_h", "agent_h[4]_has_driver", 1'b0);

    // configure connection between agents and subscribers
    uvm_config_db #(int)::set(this, "env_h", "scb_h[0]_in_port[0]", 0);
    uvm_config_db #(int)::set(this, "env_h", "scb_h[0]_in_port[1]", 1);

    super.build_phase(phase);
endfunction


function void dut_test::start_of_simulation_phase(uvm_phase phase);
    uvm_top.print_topology();

    this.env_h.agent_h[0].set_report_verbosity_level_hier(UVM_DEBUG);
    this.env_h.agent_h[1].set_report_verbosity_level_hier(UVM_DEBUG);
    this.env_h.agent_h[2].set_report_verbosity_level_hier(UVM_DEBUG);
    this.env_h.agent_h[3].set_report_verbosity_level_hier(UVM_DEBUG);
    this.env_h.agent_h[4].set_report_verbosity_level_hier(UVM_DEBUG);

    super.start_of_simulation_phase(phase);
endfunction



task dut_test::run_phase(uvm_phase phase);
    // proxy_board_test_seq seq_h = proxy_board_test_seq::type_id::create("seq_h");
    // dutb_txn_seq #(proxy_board_image_txn) seq_h = dutb_txn_seq #(proxy_board_image_txn)::type_id::create("seq_h", this);  // doesn't propagate type parameter ???
    dutb_txn_seq #(proxy_board_trigger_txn) pb_trigger_seq_h = new("pb_trigger_seq_h");
    dutb_txn_seq #(proxy_board_image_txn) pb_image_seq_h = new("pb_image_seq_h");
    dutb_txn_seq #(core_sys_txn) cs_seq_h = new("cs_seq_h");

    phase.raise_objection(this, "dut_test started");
    fork
        pb_image_seq_h.start(env_h.agent_h[0].driver_h.sqncr_h);
        cs_seq_h.start(env_h.agent_h[2].driver_h.sqncr_h);
        pb_trigger_seq_h.start(env_h.agent_h[5].driver_h.sqncr_h);
        // dutb_handler_h.wait_for_stop_test();
    join
    phase.drop_objection(this, "dut_test finished");
endtask
// ****************************************************************************************************************************
