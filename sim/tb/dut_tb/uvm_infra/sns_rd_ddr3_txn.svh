/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   sns_rd_ddr3_txn
    Description     :
******************************************************************************************************************************/


// ****************************************************************************************************************************
class sns_rd_ddr3_txn extends dutb_txn_base;
    `uvm_object_utils(sns_rd_ddr3_txn)

    dut_if_proxy dut_if_h;
    virtual dut_if          dut_vif;
    virtual sns_rd_ddr3_if  vif;

    localparam integer      DDR3_ROW_SIZE   =   256;  // 256 x 64 = 1024 x 16

    static  integer n_row = 0;

    logic   [4 * RAM_DATA_W - 1         : 0]        ddr3_packet[2 * DDR3_ROW_SIZE];

    extern function                             new (string name = "sns_rd_ddr3_txn");
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        check_rd_ddr3_txn ();

    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function sns_rd_ddr3_txn::new(string name = "sns_rd_ddr3_txn");
    super.new(name);
endfunction


function vector_t sns_rd_ddr3_txn::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction

function void sns_rd_ddr3_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction


task sns_rd_ddr3_txn::check_rd_ddr3_txn();
    @(posedge vif.rd_coeff_req_rdreq);
    `uvm_debug_txn($sformatf("verbosity_level: %d", verbosity_level))
    `uvm_debug_txn($sformatf("rdreq for addr: %d", vif.rd_coeff_req_row_base_addr))
    fork
        forever
            begin
                @(posedge vif.rd_coeff_bram_clk iff vif.rd_coeff_bram_we);
                `uvm_debug_txn($sformatf("rd addr & data: %d 0x%016X", vif.rd_coeff_req_row_base_addr, vif.rd_coeff_bram_din))
            end

        @(negedge vif.rd_coeff_req_rdbusy)
        `uvm_debug_txn($sformatf("rdbusy for addr: %d", vif.rd_coeff_req_row_base_addr))
    join_any disable fork;

endtask


task sns_rd_ddr3_txn::monitor(input dutb_if_proxy_base dutb_if);
    // `uvm_debug_txn("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    vif = dut_if_h.dut_vif.sns_rd_ddr3_vif;

    wait (dut_vif.rst_n) #0;
    check_rd_ddr3_txn();
endtask


function dutb_txn_base sns_rd_ddr3_txn::gold();
    sns_rd_ddr3_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************


























