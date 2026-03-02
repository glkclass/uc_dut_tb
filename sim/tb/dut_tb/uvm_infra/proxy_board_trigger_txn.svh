/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   proxy_board_trigger_txn
    Description     :   Initiate proxy board frame sending
******************************************************************************************************************************/


// ****************************************************************************************************************************
class proxy_board_trigger_txn
extends dutb_txn_base;

    `uvm_object_utils(proxy_board_trigger_txn)

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;
    virtual pb_if pb_vif;

    rand int trigger_len;
    int trigger_gap;

    static int trigger_num = 0;
    static bit post_test_trigger_val = 1'b0;

    constraint randomize_trigger_len_c {
        trigger_len inside {15, 45};
    }

    extern function                             new (string name = "proxy_board_trigger_txn");
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        generate_trigger ();

    extern virtual  task                        drive (input dutb_if_proxy_base dutb_if);
    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function proxy_board_trigger_txn::new(string name = "proxy_board_trigger_txn");
    super.new(name);
    trigger_gap = (IMAGE_N_COL + 2 * VSYNC_LEN) * IMAGE_N_ROW + TRIGGER_FRAME_START_GAP;
endfunction


function vector_t proxy_board_trigger_txn::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction


function void proxy_board_trigger_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction



task proxy_board_trigger_txn::generate_trigger();

    `uvm_debug($sformatf("triger_num: %d, trigger_len: %d", trigger_num, trigger_len))

    if (0 == trigger_num)
        begin
            pb_vif.trigger_in = post_test_trigger_val;
            forever
                @(posedge pb_vif.pixel_clk);
        end
    else
        begin
            pb_vif.trigger_in = 1'b0;
            repeat (trigger_len)
                @(posedge pb_vif.pixel_clk);
            pb_vif.trigger_in = 1'b1;

            repeat (trigger_gap)
                @(posedge pb_vif.pixel_clk);

            trigger_num--;
        end
endtask


task proxy_board_trigger_txn::drive(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run driver")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    pb_vif = dut_if_h.dut_vif.pb_vif;
    pb_vif.trigger_in = 1'b1;

    wait (dut_vif.rst_n);
    wait (dut_vif.ddr_initilaized);
    generate_trigger();
endtask


task proxy_board_trigger_txn::monitor(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    pb_vif = dut_if_h.dut_vif.pb_vif;

    wait (dut_vif.rst_n) #0;
    @(negedge pb_vif.trigger_in);
endtask


function dutb_txn_base proxy_board_trigger_txn::gold();
    proxy_board_trigger_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************


























