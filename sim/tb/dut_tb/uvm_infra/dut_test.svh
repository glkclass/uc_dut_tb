/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   dut_test
    Description     :   Create dutb flat infrastructure: set of agents and scorebords
                        on the same level of hierarchy and connections between them.
                        Specific test behaviour should be defined in child classes.
***************************************************************************************************/


// *************************************************************************************************
class dut_test extends dutb_test_base #(.N_AGNT(agnt_idx.num()), .N_SCB(scb_idx.num()));
    `uvm_component_utils(dut_test)

    virtual dut_if              dut_vif;

    extern function             new(string name = "dut_test", uvm_component parent = null);
    extern function void        build_phase(uvm_phase phase);
    extern function void        start_of_simulation_phase(uvm_phase phase);
    extern task                 run_base_test_seq();

endclass
// *************************************************************************************************


// *************************************************************************************************
function dut_test::new(string name = "dut_test", uvm_component parent = null);
    super.new(name, parent);
endfunction


function void dut_test::build_phase(uvm_phase phase);
    uvm_factory factory = uvm_factory::get();

    // override dut_tb if
    dutb_if_proxy_base::type_id::set_type_override(dut_if_proxy::get_type());

    // override customm txn
    dutb_txn_base::type_id::set_inst_override(
      init_ips_txn::get_type(), `DUTB_AGNT(INIT_IPS_AGNT_IDX));
    dutb_txn_base::type_id::set_inst_override(
      init_ddr3_txn::get_type(), `DUTB_AGNT(INIT_DDR3_AGNT_IDX));
    dutb_txn_base::type_id::set_inst_override(
      proxy_board_image_txn::get_type(), `DUTB_AGNT(PROXY_BOARD_IMAGE_AGNT_IDX));
    dutb_txn_base::type_id::set_inst_override(
      core_sys_txn::get_type(), `DUTB_AGNT(CORE_SYS_AGNT_IDX));

    // factory.print();

    // configure agents
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(INIT_IPS_AGNT_IDX), 1'b1);
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(CORE_SYS_AGNT_IDX), 1'b1);
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(INIT_DDR3_AGNT_IDX), 1'b1);
    uvm_config_db #(bit)::set(
      this, "env_h", `DUTB_AGNT_HAS_DRIVER(PROXY_BOARD_IMAGE_AGNT_IDX), 1'b1);

    super.build_phase(phase);
endfunction


function void dut_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    uvm_top.print_topology();
endfunction

/*  These 'base' sequences always run so we put them into separate task.
The task should be called inside the top customized dut_test together with 'specific' sequences */
task dut_test::run_base_test_seq();
    dutb_txn_seq #(init_ips_txn) init_ips_seq_h = new("init_ips_seq_h");
    dutb_txn_seq #(init_ddr3_txn) init_ddr3_seq_h = new("init_ddr3_seq_h");
    dutb_txn_seq #(proxy_board_image_txn) pb_image_seq_h = new("pb_image_seq_h");
    dutb_txn_seq #(core_sys_txn) cs_seq_h = new("cs_seq_h");
    fork
        init_ips_seq_h.start(env_h.agent_h[INIT_IPS_AGNT_IDX].driver_h.sqncr_h);
        init_ddr3_seq_h.start(env_h.agent_h[INIT_DDR3_AGNT_IDX].driver_h.sqncr_h);
        pb_image_seq_h.start(env_h.agent_h[PROXY_BOARD_IMAGE_AGNT_IDX].driver_h.sqncr_h);
        cs_seq_h.start(env_h.agent_h[CORE_SYS_AGNT_IDX].driver_h.sqncr_h);
    join
endtask
// *************************************************************************************************
