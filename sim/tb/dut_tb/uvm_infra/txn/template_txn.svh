/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   template_txn
    Description     :   Template
******************************************************************************************************************************/

// ****************************************************************************************************************************
class template_txn extends dutb_txn_base;
    `uvm_object_utils(template_txn)

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;

    rand    int             bar;

    constraint image_c {
        bar inside {[1 : 101]};
    }

    extern function                         new (string name = "template_txn");
    extern virtual  function vector_t       pack2vector ();
    extern virtual  function void           unpack4vector (vector_t packed_txn);
    extern virtual  task                    drive                   (input dutb_if_proxy_base dutb_if);
    extern virtual  task                    monitor                 (input dutb_if_proxy_base dutb_if);
endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function template_txn::new(string name = "template_txn");
    super.new(name);
endfunction


function vector_t template_txn::pack2vector();
    vector_t foo;
    foo = new[1];
    foo[0] = bar;
    return foo;
endfunction


function void template_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() == 1,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    bar = packed_txn[0];
endfunction


task template_txn::drive(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    wait (dut_vif.rst_n) #0;
    `uvm_debug("Run driver")
endtask


task template_txn::monitor(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;

    wait (dut_vif.rst_n) #0;
    `uvm_debug("Run monitor")
endtask
// ****************************************************************************************************************************
