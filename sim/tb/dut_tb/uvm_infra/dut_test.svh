/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   dut_test
    Description     :
******************************************************************************************************************************/

// DUT TB agents
enum {
    INIT_IPS = 0,
    INIT_DDR3,
    PROXY_BOARD_IMAGE,
    MIPI_CSI_AXIS,
    CORE_SYS,
    SNS_RD_DDR3,
    SNS_RD_COEFF,
    PROXY_BOARD_TRIGGER
} agnt;


// ****************************************************************************************************************************
class dut_test extends dutb_test_base #(.N_AGNT(agnt.num()), .N_SCB(1));
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

    // override UVM infra
    dutb_if_proxy_base::type_id::set_type_override(dut_if_proxy::get_type());


    dutb_txn_base::type_id::set_inst_override(init_ips_txn::get_type(), `DUTB_AGNT(INIT_IPS));
    dutb_txn_base::type_id::set_inst_override(init_ddr3_txn::get_type(), `DUTB_AGNT(INIT_DDR3));
    dutb_txn_base::type_id::set_inst_override(proxy_board_image_txn::get_type(), `DUTB_AGNT(PROXY_BOARD_IMAGE));
    dutb_txn_base::type_id::set_inst_override(mipi_csi_axis_txn::get_type(), `DUTB_AGNT(MIPI_CSI_AXIS));
    dutb_txn_base::type_id::set_inst_override(core_sys_txn::get_type(), `DUTB_AGNT(CORE_SYS));
    dutb_txn_base::type_id::set_inst_override(sns_rd_ddr3_txn::get_type(), `DUTB_AGNT(SNS_RD_DDR3));
    dutb_txn_base::type_id::set_inst_override(sns_rd_coeff_txn::get_type(), `DUTB_AGNT(SNS_RD_COEFF));
    dutb_txn_base::type_id::set_inst_override(proxy_board_trigger_txn::get_type(), `DUTB_AGNT(PROXY_BOARD_TRIGGER));

    factory.print();


    // Configure env

    // provide 'dut_vif' to dut_if_proxy
    if (!uvm_config_db #(virtual dut_if)::get(this, "", "dut_vif", dut_vif))
        `uvm_fatal("CFG_DB_ERROR", "Seems ttb doesn't provide 'dut_vif' via config db")
    else
        uvm_config_db #(virtual dut_if)::set(this, "env_h.dutb_if_h", "dut_vif", dut_vif);

    // configure agents
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(MIPI_CSI_AXIS), 1'b0);
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(SNS_RD_DDR3), 1'b0);
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_DRIVER(SNS_RD_COEFF), 1'b0);

    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_MONITOR(INIT_DDR3), 1'b0);
    uvm_config_db #(bit)::set(this, "env_h", `DUTB_AGNT_HAS_MONITOR(INIT_IPS), 1'b0);

    // subscribe scb to agents
    uvm_config_db #(int)::set(this, "env_h", "scb_h[0]_in_port[0]", PROXY_BOARD_IMAGE);
    uvm_config_db #(int)::set(this, "env_h", "scb_h[0]_in_port[1]", MIPI_CSI_AXIS);

    super.build_phase(phase);
endfunction


function void dut_test::start_of_simulation_phase(uvm_phase phase);
    uvm_top.print_topology();

    for (int i = 0; i < agnt.num(); i++)
        begin
            this.env_h.agent_h[i].set_report_verbosity_level_hier(UVM_DEBUG);
        end

    super.start_of_simulation_phase(phase);
endfunction


task dut_test::run_phase(uvm_phase phase);
    // proxy_board_test_seq seq_h = proxy_board_test_seq::type_id::create("seq_h");
    // dutb_txn_seq #(proxy_board_image_txn) seq_h = dutb_txn_seq #(proxy_board_image_txn)::type_id::create("seq_h", this);  // doesn't propagate type parameter ???

    dutb_txn_seq #(init_ips_txn) init_ips_seq_h = new("init_ips_seq_h");
    dutb_txn_seq #(init_ddr3_txn) init_ddr3_seq_h = new("init_ddr3_seq_h");
    dutb_txn_seq #(proxy_board_trigger_txn) pb_trigger_seq_h = new("pb_trigger_seq_h");
    dutb_txn_seq #(proxy_board_image_txn) pb_image_seq_h = new("pb_image_seq_h");
    dutb_txn_seq #(core_sys_txn) cs_seq_h = new("cs_seq_h");

    phase.raise_objection(this, "dut_test started");
    fork
        init_ips_seq_h.start(env_h.agent_h[INIT_IPS].driver_h.sqncr_h);
        init_ddr3_seq_h.start(env_h.agent_h[INIT_DDR3].driver_h.sqncr_h);
        pb_image_seq_h.start(env_h.agent_h[PROXY_BOARD_IMAGE].driver_h.sqncr_h);
        cs_seq_h.start(env_h.agent_h[CORE_SYS].driver_h.sqncr_h);
        pb_trigger_seq_h.start(env_h.agent_h[PROXY_BOARD_TRIGGER].driver_h.sqncr_h);
        // dutb_handler_h.wait_for_stop_test();
    join
    phase.drop_objection(this, "dut_test finished");
endtask
// ****************************************************************************************************************************
