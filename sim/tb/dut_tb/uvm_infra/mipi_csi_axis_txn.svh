/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   proxy_board_txn
    Description     :   mipi_csi_axis_streamer <-> soc mipi_csi_tx
******************************************************************************************************************************/

// ****************************************************************************************************************************
class mipi_csi_axis_txn extends dutb_txn_base;
    `uvm_object_utils(mipi_csi_axis_txn)

    localparam integer      N_IGNORED_FRAMES = 1;

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;
    virtual axis_if csi_vif;


    typedef logic     [IMAGE_PIXEL_W - 1  :   0]    t_pixel;
    u_shortint                                      frame_number;
    t_pixel                                         image[IMAGE_N_ROW][IMAGE_N_COL];

    static u_shortint                               frame_idx = 16'd0;

    extern function                             new (string name = "mipi_csi_axis_txn");
    extern virtual  function vector_t           pack2vector ();
    extern virtual  function void               unpack4vector (vector_t packed_txn);

    extern virtual  task                        generate_axis_tready ();
    extern virtual  task                        recieve_image ();

    extern virtual  task                        monitor (input dutb_if_proxy_base dutb_if);
    extern virtual  function dutb_txn_base      gold ();

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function mipi_csi_axis_txn::new(string name = "mipi_csi_axis_txn");
    super.new(name);
endfunction


function vector_t mipi_csi_axis_txn::pack2vector();
    vector_t foo;
    foo = new[0];
    return foo;
endfunction


function void mipi_csi_axis_txn::unpack4vector(vector_t packed_txn);
    `ASSERT (packed_txn.size() > 0,
            $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
    // bar = packed_txn[0];
endfunction


task mipi_csi_axis_txn::generate_axis_tready();
    forever
        begin
            int foo;
            @(posedge dut_vif.sys_clk);
            foo = $urandom_range(1);
            // csi_vif.axis_tready = foo[0] & csi_vif.axis_tvalid;
            csi_vif.axis_tready = foo[0];
        end
endtask


task mipi_csi_axis_txn::recieve_image();
    bit frame_recieved = 1'b0;
    int n_image_row, n_image_col;
    int n_image_row_d;


    n_image_col = 0;
    n_image_row_d = -1;
    frame_number = 16'd0;

    while (~frame_recieved)
        begin
            @(posedge dut_vif.sys_clk);

            if (csi_vif.axis_hsh)
                begin
                    frame_idx = (csi_vif.axis_frame_start) ? frame_idx + 1 : frame_idx;

                    if (frame_idx > N_IGNORED_FRAMES)  // ignore startup out-of-spec frames
                        begin
                            if (csi_vif.axis_frame_start)
                                begin
                                    `uvm_debug_txn($sformatf("frame_start %d", csi_vif.axis_frame_start));

                                    assert (1 == csi_vif.mipi_csi_row_number) else `uvm_fatal("MNTR", $sformatf("mipi_csi_row_number = %d", csi_vif.mipi_csi_row_number));
                                    assert (0 == n_image_col) else `uvm_fatal("MNTR", $sformatf("Image col = %d", n_image_col));
                                    frame_number = csi_vif.mipi_csi_frame_number;
                                end

                            n_image_row = csi_vif.mipi_csi_row_number - 1;
                            assert(n_image_row < IMAGE_N_ROW) else `uvm_fatal("MNTR", $sformatf("Image row = %d", n_image_row));
                            assert(n_image_col < IMAGE_N_COL) else `uvm_fatal("MNTR", $sformatf("Image col = %d", n_image_col));
                            assert(n_image_row == n_image_row_d + 1) else `uvm_fatal("MNTR", $sformatf("Image row previous, current = %d, %d", n_image_row_d, n_image_row));
                            `uvm_debug_txn($sformatf("Image row/col/data = %02d / %02d / 0x%04h / 0x%04h / 0x%04h / 0x%04h", n_image_row, n_image_col, csi_vif.axis_tword[0], csi_vif.axis_tword[1], csi_vif.axis_tword[2], csi_vif.axis_tword[3]));
                            for (int i = 0; i < 4; i++) image[n_image_row][n_image_col + i] = csi_vif.axis_tword[i];
                            n_image_col += 4;

                            if (csi_vif.axis_tlast)
                                begin
                                    `uvm_debug_txn($sformatf("axis_tlast %d", csi_vif.axis_tlast));
                                    assert (IMAGE_N_COL== n_image_col) else `uvm_fatal("MNTR", $sformatf("Image col = %d", n_image_col));
                                    n_image_col = 0;
                                    frame_recieved = ((IMAGE_N_ROW - 1) == n_image_row) ? 1'b1: 1'b0;
                                    n_image_row_d = n_image_row;  // remember last row number
                                end

                        end
                end
        end
endtask


task mipi_csi_axis_txn::monitor(input dutb_if_proxy_base dutb_if);
    u_shortint frame_number_d;
    // `uvm_debug("Run monitor")
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    csi_vif = dut_if_h.dut_vif.csi_vif;

    wait (dut_vif.rst_n) #0;

    frame_number_d = frame_number;
    fork
        generate_axis_tready();
        recieve_image();
    join_any disable fork;

    assert (frame_number_d + 1 == frame_number || frame_idx <= N_IGNORED_FRAMES + 1) else `uvm_fatal("MNTR", $sformatf("Frame number /_d %d / %d", frame_number, frame_number_d));
    `uvm_info("MNTR", $sformatf("MIPI CSI axis frame # %0d received.", frame_number), UVM_HIGH)
endtask


function dutb_txn_base mipi_csi_axis_txn::gold();
    mipi_csi_axis_txn      dout_txn;
    dout_txn = new();
    return dout_txn;
endfunction
// ****************************************************************************************************************************

