/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   image_histo_monitor
    Description     :
***************************************************************************************************/

`undef TXN_NAME
`define TXN_NAME image_histo_processor_in_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// *************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
    `uvm_object_utils(`TXN_NAME)

    dut_if_proxy                          dut_if_proxy_h;
    virtual image_histo_processor_if      dut_ihp_vif;

    static integer n_frames = 0;
    integer frame_idx;
    integer n_rows, n_cols;
    integer frame [N_IMAGE_ROW][N_IMAGE_COL];

    extern function new (
      string name = `STR(`TXN_NAME),
      uvm_component parent = null);

    extern virtual  function void           init_vif(input dutb_if_proxy_base dutb_if_proxy_h);;
    extern virtual  function vector_t       pack2vector ();
    extern virtual  task                    catch_input ();
    extern virtual  task                    monitor (input dutb_if_proxy_base dutb_if_proxy_h);
    extern virtual  function dutb_txn_base  gold ();

endclass
// *************************************************************************************************


// *************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME), uvm_component parent = null);
    super.new(name, parent);
    frame_idx = -1;
endfunction


function void `TXN_NAME::init_vif(input dutb_if_proxy_base dutb_if_proxy_h);;
  `uvm_txn_info_d("TXN", "Init virtual if")
  `ASSERT_TYPE_CAST(dut_if_proxy_h, dutb_if_proxy_h)
  dut_ihp_vif = dut_if_proxy_h.dut_ihp_vif;
endfunction


function vector_t `TXN_NAME::pack2vector();
    vector_t packed_txn;
    packed_txn = new[N_IMAGE_ROW * N_IMAGE_COL + 1];

    foreach (frame[row, col]) begin
      packed_txn[row * N_IMAGE_COL + col] = frame[row][col];
    end
    packed_txn [N_IMAGE_ROW * N_IMAGE_COL] = frame_idx;

    return packed_txn;
endfunction


/* we dont check frame consistency here */
task `TXN_NAME::catch_input();
  @(posedge dut_ihp_vif.i_pixel_clk iff dut_ihp_vif.image_s_sens_img_frame_start);
  n_frames++;
  frame_idx = n_frames;
  `uvm_txn_info_h("TXN", $sformatf("Image HC frame start # %0d recieved", frame_idx))
  n_cols = 0;
  n_rows = 0;

  foreach (frame[row, col]) begin
    frame[row][col] = 0;
  end

  repeat (N_IMAGE_ROW) begin
    @(posedge dut_ihp_vif.i_pixel_clk iff dut_ihp_vif.image_s_sens_img_row_start );
    `uvm_txn_info_f("TXN", $sformatf("Image HC row start #%0d.%0d recieved", frame_idx, n_rows))

    n_cols = 0;
    repeat (N_IMAGE_COL) begin
      @(posedge dut_ihp_vif.i_pixel_clk iff dut_ihp_vif.image_s_sens_img_bank_we );
      `ASSERT(n_rows < N_IMAGE_ROW, $sformatf("n_rows: %0d", n_rows));
      `ASSERT(n_cols < N_IMAGE_COL, $sformatf("n_cols: %0d", n_cols));
      frame[n_rows][n_cols] = dut_ihp_vif.image_s_sens_img_bank_din;
      n_cols++;
    end
    n_rows++;

  end
  `uvm_txn_info_h("TXN", $sformatf("Image HC frame #%0d has been recieved", frame_idx))

endtask


task `TXN_NAME::monitor(input dutb_if_proxy_base dutb_if_proxy_h);
    `uvm_txn_info_d("TXN", "Run monitor")
    this.init_vif(dutb_if_proxy_h);
    wait (dut_ihp_vif.i_sys_rst_n) #0;
    catch_input();
endtask


function dutb_txn_base `TXN_NAME::gold();
  image_histo_processor_out_txn      txn_gold;

  txn_gold = new();
  txn_gold.set_parent(this.parent);
  txn_gold.init_vif(dut_if_proxy_h);
  txn_gold.frame_idx = frame_idx;


  if (5 == frame_idx) begin
      `uvm_fatal("TXN", "Stop after 5 frames done")
  end

  /*  calculate histo   */
  foreach (frame[row, col]) begin
    integer pixel;
    pixel = (frame[row][col] >> 2) & 31;
    txn_gold.histo[pixel]++;
  end

  /*  calculate
      min/max histo value &
      histo_cdf &
      p_low, p_high   */
  txn_gold.calculate_histo_range();
  txn_gold.calculate_histo_cdf_p_cutoff();

  return txn_gold;
endfunction
// *************************************************************************************************
