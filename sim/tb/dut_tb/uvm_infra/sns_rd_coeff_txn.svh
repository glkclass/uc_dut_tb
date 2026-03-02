/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   sns_rd_coeff_txn
    Description     :
******************************************************************************************************************************/


// ****************************************************************************************************************************
class sns_rd_coeff_txn extends dutb_txn_base;
    `uvm_object_utils(sns_rd_coeff_txn)

    dut_if_proxy dut_if_h;
    virtual dut_if              dut_vif;
    virtual sns_rd_coeff_if     vif;


    static  integer n_row = 0;

    extern function                             new (string name = "sns_rd_coeff_txn");
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        check_rd_coeff ();

    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function sns_rd_coeff_txn::new(string name = "sns_rd_coeff_txn");
    super.new(name);
endfunction


function vector_t sns_rd_coeff_txn::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction

function void sns_rd_coeff_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction


task sns_rd_coeff_txn::check_rd_coeff();
    fork
        forever
            begin
                @(posedge vif.i_sensor_pixel_clk iff vif.coeff_pixel_valid);
                `uvm_debug_txn($sformatf("sns rd coeff: 0x%016X %d %d", vif.coeff_ram_data_b, vif.coeff_a, vif.coeff_b))
            end

            begin
                @(posedge vif.row_start_sys_clk);
                `uvm_debug_txn("sns row start")
            end
    join_any disable fork;

endtask


task sns_rd_coeff_txn::monitor(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    vif = dut_if_h.dut_vif.sns_rd_coeff_vif;

    wait (dut_vif.rst_n) #0;
    check_rd_coeff();
endtask


function dutb_txn_base sns_rd_coeff_txn::gold();
    sns_rd_coeff_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************


























