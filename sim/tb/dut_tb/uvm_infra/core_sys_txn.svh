/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   core_sys_txn
    Description     :   Core sys <-> ddr3_sm_core
******************************************************************************************************************************/


// ****************************************************************************************************************************
class core_sys_txn extends dutb_txn_base;
    `uvm_object_utils(core_sys_txn)

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;
    virtual sm_core_rw_if cs_vif;

    localparam integer      DDR3_ROW_SIZE   =   256;  // 256 x 64 = 1024 x 16

    static  integer n_row = 0;

    rand    logic   [4 * RAM_DATA_W - 1         : 0]        ddr3_row[DDR3_ROW_SIZE];



    constraint randomize_ddr3_row_c {
        foreach (ddr3_row[i])
            ddr3_row[i] inside {[0 : 255]};
    }

    extern function                             new (string name = "core_sys_txn");
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        generate_wr_request ();
    extern virtual  task                        provide_bram_response ();

    extern virtual  task                        drive (input dutb_if_proxy_base dutb_if);
    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function core_sys_txn::new(string name = "core_sys_txn");
    super.new(name);
endfunction


function vector_t core_sys_txn::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction

function void core_sys_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction


task core_sys_txn::generate_wr_request();

    if (n_row < 16)
        begin
            @(posedge dut_vif.sys_clk);
            cs_vif.req_row_base_addr = `DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR / `DDR3_LINE_SIZE + 2 * n_row;
            n_row++;
            `uvm_debug_txn($sformatf("core sys wrreq for addr: %d", cs_vif.req_row_base_addr))

            cs_vif.req_bl8_offs = 0;
            cs_vif.req_burst_num = 0;
            cs_vif.req_burst_size = 31;
            cs_vif.req_wrreq = 1'b0;
            @(posedge dut_vif.sys_clk);
            cs_vif.req_wrreq = 1'b1;
            repeat(16)
                @(posedge dut_vif.sys_clk);
            cs_vif.req_wrreq = 1'b0;
        end
    forever @(posedge dut_vif.sys_clk);
endtask


task core_sys_txn::provide_bram_response();
    int i;
    shortint coeffs[128 * 3 + 128];

    @(posedge dut_vif.sys_clk iff cs_vif.req_wrreq);

    for (i = 0; i < 128; i++)
        begin
            logic [26 - 1 : 0] coeff_a;
            logic [22 - 1 : 0] coeff_b;
            logic [48 - 1 : 0] coeff_a_b;

            coeff_a = 128 * cs_vif.req_row_base_addr + 2 * i;
            coeff_b = 128 * cs_vif.req_row_base_addr + 2 * i + 1;
            coeff_a_b = {coeff_b, coeff_a};

            coeffs[3 * i] = coeff_a_b[15 : 0];
            coeffs[3 * i + 1] = coeff_a_b[31 : 16];
            coeffs[3 * i + 2] = coeff_a_b[47 : 32];

            `uvm_debug_txn($sformatf("provide_bram_response: %d 0x%08X 0x%08X 0x%04X 0x%04X 0x%04X", i, coeff_a, coeff_b, coeffs[3 * i], coeffs[3 * i + 1], coeffs[3 * i + 2]))
        end


    i = 0;
    forever
        begin
            @(posedge dut_vif.sys_clk iff cs_vif.bram_en);
            cs_vif.bram_dout = {coeffs[4 * i + 3], coeffs[4 * i + 2], coeffs[4 * i + 1], coeffs[4 * i]};
            `uvm_debug_txn($sformatf("provide_bram_response: %d 0x%016X", i, cs_vif.bram_dout))
            i++;
        end
endtask


task core_sys_txn::drive(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run driver")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    cs_vif = dut_if_h.dut_vif.core_sys_rw_vif;

    wait (dut_vif.ddr_initilaized) #0;

    cs_vif.req_wrreq = 1'b0;
    cs_vif.req_rdreq = 1'b0;

    fork
        generate_wr_request();
        provide_bram_response();
        begin
            @(negedge dut_vif.sys_clk iff cs_vif.req_wrbusy);
            // `uvm_debug($sformatf("core sys wrrsp for addr: %d", cs_vif.req_start_row_addr))
            #10us;
        end
    join_any disable fork;

endtask


task core_sys_txn::monitor(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    cs_vif = dut_if_h.dut_vif.core_sys_rw_vif;

    wait (dut_vif.rst_n) #0;
    @(posedge cs_vif.req_wrreq);
endtask


function dutb_txn_base core_sys_txn::gold();
    core_sys_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************


























