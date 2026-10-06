/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025

    Class           :   pb_image_covergroup
    Description     :

    Class           :   pb_image_txn
    Description     :
******************************************************************************************************************************/


// ****************************************************************************************************************************
class axis_image_txn extends sensor_image_txn;
    `uvm_object_utils(axis_image_txn)

    static  shortint    image_counter = 0;

    extern function                             new                     (string name = "axis_image_txn");
    extern virtual  function dutb_txn_base      gold                    ();                                     // generate a gold output txn
    extern virtual  task                        monitor                 (input dutb_if_proxy_base dutb_if);     // read 'txn content' from interface
endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function axis_image_txn::new(string name = "axis_image_txn");
    super.new(name);
endfunction


function dutb_txn_base axis_image_txn::gold();
    axis_image_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction


task axis_image_txn::monitor(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    pb_vif =  dut_if_h.dut_vif.pb_vif;

    wait (dut_vif.rst_n) #0;   // wait for reset off

    @(posedge pb_vif.v_sync);
    image_counter++;
    `uvm_debug($sformatf("Received txn: %d", image_counter))
endtask

// ****************************************************************************************************************************
