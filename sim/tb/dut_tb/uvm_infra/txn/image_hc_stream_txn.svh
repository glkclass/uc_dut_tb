/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   image_histo_monitor
    Description     :
***************************************************************************************************/

`undef TXN_NAME
`define TXN_NAME image_hc_stream_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// *************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
    `uvm_object_utils(`TXN_NAME)

    dut_if_proxy dut_if_h;
    virtual dut_if              dut_vif;
    virtual image_hc_stream_if     vif;


    static  integer n_row = 0;

    extern function                             new (string name = `STR(`TXN_NAME));
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        check_input ();

    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// *************************************************************************************************


// *************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME));
    super.new(name);
endfunction


function vector_t `TXN_NAME::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction

function void `TXN_NAME::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction


task `TXN_NAME::check_input();
    fork
        forever
            begin
                @(posedge vif.pixel_clk iff vif.frame_start);
                `uvm_debug($sformatf("Image HS frame recieved"))
            end

            begin
                @(posedge vif.pixel_clk iff vif.row_start );
                `uvm_debug_txn("Image HS line recieved")
            end
    join_any disable fork;

endtask


task `TXN_NAME::monitor(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    vif = dut_if_h.dut_vif.image_hc_stream_vif;

    wait (dut_vif.rst_n) #0;
    check_input();
endtask


function dutb_txn_base `TXN_NAME::gold();
    `TXN_NAME      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************
