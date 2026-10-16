/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   image_histo_monitor
    Description     :
***************************************************************************************************/

`undef TXN_NAME
`define TXN_NAME image_hc_out_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// *************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
  `uvm_object_utils(`TXN_NAME)

  // localparam integer HISTO_SZ = HISTO_SIZE;
  localparam integer HISTO_SZ = 32;

  dut_if_proxy            dut_if_proxy_h;
  virtual image_hc_if     image_hc_vif;
  virtual histo_bram_if   histo_bram_0_vif;
  virtual histo_bram_if   histo_bram_1_vif;

  static integer n_frames = 0;
  integer frame_idx;
  integer frame [N_IMAGE_ROW][N_IMAGE_COL];
  integer histo [HISTO_SZ];
  integer histo_left_point, histo_right_point;



  extern function new (
    string name = `STR(`TXN_NAME),
    uvm_component parent = null);

  extern virtual  function vector_t       pack2vector ();
  extern virtual task catch_output ();
  extern virtual task monitor (input dutb_if_proxy_base dutb_if_proxy_h);
  extern virtual function bit do_compare (uvm_object rhs, uvm_comparer comparer);

endclass
// *************************************************************************************************


// *************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME), uvm_component parent = null);
  super.new(name, parent);
  frame_idx = -1;
  histo_left_point = -1;
  histo_right_point = -1;
  for (int i = 0; i < HISTO_SZ; i++) begin
    histo[i] = 0;
  end
endfunction


function vector_t `TXN_NAME::pack2vector();
  vector_t txn_packed;

  txn_packed = new[HISTO_SZ + 3];
  for (int i = 0; i < HISTO_SZ; i++) begin
    txn_packed[i] = histo[i];
  end
  txn_packed[HISTO_SZ] = histo_left_point;
  txn_packed[HISTO_SZ + 1] = histo_right_point;
  txn_packed[HISTO_SZ + 2] = frame_idx;
  return txn_packed;
endfunction


function bit `TXN_NAME::do_compare(uvm_object rhs, uvm_comparer comparer);
  bit ans;
  ans = super.do_compare(rhs, comparer);
  if (1 == ans) begin
    `uvm_txn_info_h("TXN", $sformatf("Image HC frame #%0d checked: Ok", frame_idx))
  end
  return ans;
endfunction


task `TXN_NAME::catch_output();
  if (0 == n_frames) begin
    @(posedge image_hc_vif.i_pixel_clk iff image_hc_vif.image_s_sens_img_frame_start);
    `uvm_txn_info_h("TXN", $sformatf("Image HC out txn # %0d recieved and ignored", n_frames - 1))
  end

  @(posedge image_hc_vif.i_pixel_clk iff image_hc_vif.image_s_sens_img_frame_start);
  n_frames++;
  `uvm_txn_info_h("TXN", $sformatf("Image HC out txn # %0d recieved", n_frames))

  if (image_hc_vif.histo_bank_sel) begin
    for (int i = 0; i < HISTO_SZ; i++) begin
      histo[i] = histo_bram_1_vif.memory[i];
    end
  end else begin
    for (int i = 0; i < HISTO_SZ; i++) begin
      histo[i] = histo_bram_0_vif.memory[i];
    end
  end
  histo_left_point = image_hc_vif.histo_left_point_i;
  histo_right_point = image_hc_vif.histo_right_point_i;

  frame_idx = n_frames;
endtask


task `TXN_NAME::monitor(input dutb_if_proxy_base dutb_if_proxy_h);
  `uvm_txn_info_d("TXN", "Run monitor")
  `ASSERT_TYPE_CAST(dut_if_proxy_h, dutb_if_proxy_h)
  image_hc_vif = dut_if_proxy_h.dut_image_hc_vif;
  histo_bram_0_vif = dut_if_proxy_h.histo_bram_0_vif;
  histo_bram_1_vif = dut_if_proxy_h.histo_bram_1_vif;
  wait (image_hc_vif.i_sys_rst_n) #0;
  catch_output();
endtask
// *************************************************************************************************
