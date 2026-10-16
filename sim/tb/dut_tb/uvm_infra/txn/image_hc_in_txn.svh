/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   image_histo_monitor
    Description     :
***************************************************************************************************/

`undef TXN_NAME
`define TXN_NAME image_hc_in_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// *************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
    `uvm_object_utils(`TXN_NAME)

    dut_if_proxy              dut_if_proxy_h;
    virtual image_hc_if       image_hc_vif;

    static integer n_frames = 0;
    integer frame_idx;
    integer n_rows, n_cols;
    integer frame [N_IMAGE_ROW][N_IMAGE_COL];

    extern function new (
      string name = `STR(`TXN_NAME),
      uvm_component parent = null);

    extern virtual function vector_t pack2vector ();
    // extern virtual  function void           unpack4vector (vector_t packed_txn);
    extern virtual task catch_input ();
    extern virtual task monitor (input dutb_if_proxy_base dutb_if_proxy_h);
    extern virtual  function dutb_txn_base  gold ();

endclass
// *************************************************************************************************


// *************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME), uvm_component parent = null);
    super.new(name, parent);
    frame_idx = -1;
endfunction


function vector_t `TXN_NAME::pack2vector();
    vector_t packed_txn;
    packed_txn = new[N_IMAGE_ROW * N_IMAGE_COL + 1];

    for (int row = 0; row < N_IMAGE_ROW; row++) begin
      for (int col = 0; col < N_IMAGE_COL; col++) begin
        packed_txn[row * N_IMAGE_COL + col] = frame[row][col];
      end
    end
    packed_txn [N_IMAGE_ROW * N_IMAGE_COL] = frame_idx;
    return packed_txn;
endfunction

// function void `TXN_NAME::unpack4vector(vector_t packed_txn);
//     `ASSERT (packed_txn.size() > 0,
//             $sformatf("Wrong 'packed_txn' size: %0d", packed_txn.size()))
//     // bar = packed_txn[0];
// endfunction


/* we dont check frame consistency here */
task `TXN_NAME::catch_input();
  @(posedge image_hc_vif.i_pixel_clk iff image_hc_vif.image_s_sens_img_frame_start);
  n_frames++;
  frame_idx = n_frames;
  `uvm_txn_info_h("TXN", $sformatf("Image HC frame start # %0d recieved", frame_idx))
  n_cols = 0;
  n_rows = 0;

  foreach (frame[row, col]) begin
    frame[row][col] = 0;
  end

  repeat (N_IMAGE_ROW) begin
    @(posedge image_hc_vif.i_pixel_clk iff image_hc_vif.image_s_sens_img_row_start );
    `uvm_txn_info_f("TXN", $sformatf("Image HC row start #%0d.%0d recieved", frame_idx, n_rows))

    n_cols = 0;
    repeat (N_IMAGE_COL) begin
      @(posedge image_hc_vif.i_pixel_clk iff image_hc_vif.image_s_sens_img_bank_we );
      `ASSERT(n_rows < N_IMAGE_ROW, $sformatf("n_rows: %0d", n_rows));
      `ASSERT(n_cols < N_IMAGE_COL, $sformatf("n_cols: %0d", n_cols));
      frame[n_rows][n_cols] = image_hc_vif.image_s_sens_img_bank_din;
      n_cols++;
    end
    n_rows++;

  end
  `uvm_txn_info_h("TXN", $sformatf("Image HC frame #%0d has been recieved", frame_idx))

endtask


task `TXN_NAME::monitor(input dutb_if_proxy_base dutb_if_proxy_h);
    `uvm_txn_info_d("TXN", "Run monitor")
    `ASSERT_TYPE_CAST(dut_if_proxy_h, dutb_if_proxy_h)
    image_hc_vif = dut_if_proxy_h.dut_image_hc_vif;
    wait (image_hc_vif.i_sys_rst_n) #0;
    catch_input();
endtask


function dutb_txn_base `TXN_NAME::gold();
  image_hc_out_txn      txn_gold;
  integer pixel_min, pixel_max;

  txn_gold = new();
  txn_gold.frame_idx = frame_idx;

  if (5 == frame_idx) begin
      `uvm_fatal("TXN", "Stop after 5 frames done")
  end

  /*  calculate histo & range  */
  pixel_min = (frame[0][0] >> 2) & 31;
  pixel_max = (frame[0][0] >> 2) & 31;
  foreach (frame[row, col]) begin
    integer pixel;
    pixel = (frame[row][col] >> 2) & 31;

    pixel_min = (pixel_min < pixel) ? pixel_min : pixel;
    pixel_max = (pixel_max > pixel) ? pixel_max : pixel;

    // if (0 == pixel) begin
    //   `uvm_txn_info_f("TXN", $sformatf("Pixel 0: row: %d col: %d", row, col))
    // end

    txn_gold.histo[pixel]++;
    txn_gold.histo_left_point = pixel_min;
    txn_gold.histo_right_point = pixel_max;
  end

  return txn_gold;
endfunction
// *************************************************************************************************
