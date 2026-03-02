/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   proxy_board_image_txn
    Description     :   Proxy board -> am_top
******************************************************************************************************************************/


// ****************************************************************************************************************************
class proxy_board_image_txn
extends dutb_txn_base;
    `uvm_object_utils(proxy_board_image_txn)

    static bit coeff_init = 1'b0;

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;
    virtual pb_if pb_vif;

    int hsync_len, vsync_len, n_image_col;

    typedef logic     [IMAGE_PIXEL_W - 1  :   0]        t_pixel;
    rand    t_pixel                                     image[IMAGE_N_ROW][IMAGE_N_COL + BBL_NUM];



    constraint randomize_pixel_values_c {
        foreach (image[i,j])
            image[i][j] inside {[0 : (1 << 16) -1]};
    }

    extern function                             new (string name = "proxy_board_image_txn");
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        generate_pixel_clock ();
    extern virtual  task                        generate_image ();

    extern virtual  task                        drive (input dutb_if_proxy_base dutb_if);
    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function proxy_board_image_txn::new(string name = "proxy_board_image_txn");
    super.new(name);
    vsync_len = (BBL_MODE) ? VSYNC_LEN : VSYNC_LEN + BBL_NUM;
    hsync_len = vsync_len + 1;
    n_image_col = (BBL_MODE) ? IMAGE_N_COL + BBL_NUM : IMAGE_N_COL;
endfunction


function vector_t proxy_board_image_txn::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction


function void proxy_board_image_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction


task proxy_board_image_txn::generate_pixel_clock();
    forever
        begin
            @(posedge pb_vif.master_clk);
            @(posedge pb_vif.master_clk);
            pb_vif.pixel_clk = ~pb_vif.pixel_clk;
        end
endtask


task proxy_board_image_txn::generate_image();
    fork
        begin
            pb_vif.vsync = 1'b0;
            repeat(vsync_len)
                @(negedge pb_vif.pixel_clk);
            pb_vif.vsync = 1'b1;
        end

        begin
            pb_vif.data = 16'dx;

            for (int i = 0; i < IMAGE_N_ROW; i = i + 1)
                begin
                    pb_vif.hsync = 1'b0;
                    repeat(hsync_len)
                        @(negedge pb_vif.pixel_clk);
                    pb_vif.hsync = 1'b1;

                    for (int j = 0; j < n_image_col; j = j + 1)
                        begin
                            pb_vif.data = image[i][j];
                            @(negedge pb_vif.pixel_clk);
                        end
                end
        end
    join;

    pb_vif.vsync = 1'b0;
    pb_vif.hsync = 1'b0;

endtask


task proxy_board_image_txn::drive(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run driver")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    pb_vif = dut_if_h.dut_vif.pb_vif;



    pb_vif.vsync = 1'b0;
    pb_vif.hsync = 1'b0;
    pb_vif.data = 16'dx;

    fork
        generate_pixel_clock();
        begin
            wait (dut_vif.rst_n);
            if (1'b1 == pb_vif.trigger_out)
                begin
                    @(negedge pb_vif.trigger_out);
                    repeat (TRIGGER_FRAME_START_GAP)
                        @(posedge pb_vif.pixel_clk);
                end
            generate_image();
        end
    join_any disable fork;

endtask


task proxy_board_image_txn::monitor(input dutb_if_proxy_base dutb_if);
    // `uvm_debug("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    pb_vif = dut_if_h.dut_vif.pb_vif;

    wait (dut_vif.rst_n) #0;
    @(posedge pb_vif.vsync);
endtask


function dutb_txn_base proxy_board_image_txn::gold();
    proxy_board_image_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************


























