/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   image_histo_monitor
    Description     :
***************************************************************************************************/

`undef TXN_NAME
`define TXN_NAME image_histo_processor_out_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// *************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
  `uvm_object_utils(`TXN_NAME)

  // localparam integer HISTO_SZ = HISTO_SIZE;
  localparam integer HISTO_SZ = 32;

  dut_if_proxy                      dut_if_proxy_h;
  virtual image_histo_processor_if  dut_ihp_vif;
  virtual histo_bram_if             histo_bram_0_vif;
  virtual histo_bram_if             histo_bram_1_vif;

  static integer n_frames = 0;
  integer frame_idx;
  integer histo [HISTO_SZ];
  integer histo_cdf [HISTO_SZ];
  integer histo_left_point, histo_right_point;
  integer histo_p_low, histo_p_high;
  integer histo_cdf_256k_ceiling_idx;


  extern function new (
    string name = `STR(`TXN_NAME),
    uvm_component parent = null);

  extern virtual  function void     init_vif(input dutb_if_proxy_base dutb_if_proxy_h);;
  extern virtual  function vector_t pack2vector ();
  extern virtual  task              catch_output ();
  extern virtual  task              monitor (input dutb_if_proxy_base dutb_if_proxy_h);
  extern virtual  function bit      do_compare (uvm_object rhs, uvm_comparer comparer);

  extern function void calculate_histo_range();
  extern function void calculate_histo_cdf_p_cutoff();

endclass
// *************************************************************************************************


// *************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME), uvm_component parent = null);
  super.new(name, parent);
  frame_idx = -1;
  histo_left_point = X32;
  histo_right_point = X32;
  histo_p_low = X32;
  histo_p_high = X32;
  for (int i = 0; i < HISTO_SZ; i++) begin
    histo[i] = 0;
    histo_cdf[i] = X32;
  end
endfunction


function void `TXN_NAME::init_vif(input dutb_if_proxy_base dutb_if_proxy_h);;
  `uvm_txn_info_d("TXN", "Init virtual if")
  `ASSERT_TYPE_CAST(dut_if_proxy_h, dutb_if_proxy_h)
  dut_ihp_vif = dut_if_proxy_h.dut_ihp_vif;
  histo_bram_0_vif = dut_if_proxy_h.histo_bram_0_vif;
  histo_bram_1_vif = dut_if_proxy_h.histo_bram_1_vif;
endfunction


function void `TXN_NAME::calculate_histo_range();
  histo_left_point = HISTO_SZ;
  foreach (histo[i]) begin
    if ( (histo_left_point >= i) && (0 != histo[i])) begin
      histo_left_point = i;
    end
    if (0 != histo[i]) begin
      histo_right_point = i;
    end
  end
endfunction


/**/
function void `TXN_NAME::calculate_histo_cdf_p_cutoff();
  integer histo_cdf_acc = 0;

  integer histo_cdf_low = dut_ihp_vif.histo_cutoff_val;
  integer histo_cdf_high = dut_ihp_vif.HISTO_CDF_MAX_VAL - dut_ihp_vif.histo_cutoff_val;

  /*  Calc cdf and 256K ceiling point*/
  foreach (histo[i]) begin
    histo_cdf_acc += histo[i];
    if (histo_cdf_acc >= dut_ihp_vif.CEILING_256K) begin
      histo_cdf_acc -= dut_ihp_vif.CEILING_256K;
      histo_cdf_256k_ceiling_idx = i;
    end
    histo_cdf[i] = histo_cdf_acc;
  end

  /* Calc p_low   */
  foreach (histo_cdf[i]) begin
    if (histo_cdf[i] > histo_cdf_low) begin
      histo_p_low = i;
      break;
    end
  end

  /* Calc p_high   */
  for (int i = HISTO_SZ - 1; i >= 0; i--) begin
    integer foo = (i >= histo_cdf_256k_ceiling_idx) ?
      histo_cdf[i] + dut_ihp_vif.CEILING_256K : histo_cdf[i];
    if (foo < histo_cdf_high) begin
      histo_p_high = i;
      break;
    end
  end

 // `uvm_txn_info_h("TXN", $sformatf("Debug: %0d %0d %0d %0d %0d %0d",
 //    histo_p_low, histo_p_high, histo_cdf_low, histo_cdf_high, histo_cdf_256k_ceiling_idx, dut_ihp_vif.CEILING_256K))

endfunction


function vector_t `TXN_NAME::pack2vector();
  vector_t txn_packed;
  integer idx = 0;
  txn_packed = new[2*HISTO_SZ + 6];

  // `uvm_txn_info_h("TXN", $sformatf("Debug: %0d", dut_ihp_vif.N_IMAGE_ROW))

  foreach (histo[i]) begin
    txn_packed[idx++] = histo[i];
  end

  foreach (histo_cdf[i]) begin
    txn_packed[idx++] = histo_cdf[i];
  end


  txn_packed[idx++] = histo_left_point;
  txn_packed[idx++] = histo_right_point;

  txn_packed[idx++] = histo_p_low;
  txn_packed[idx++] = histo_p_high;

  txn_packed[idx++] = histo_cdf_256k_ceiling_idx;

  txn_packed[idx++] = frame_idx;
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
    @(posedge dut_ihp_vif.i_pixel_clk iff dut_ihp_vif.image_s_sens_img_frame_start);
    `uvm_txn_info_h("TXN", $sformatf("Image HC out txn # %0d recieved and ignored", n_frames - 1))
  end

  @(posedge dut_ihp_vif.i_pixel_clk iff dut_ihp_vif.image_s_sens_img_frame_start);
  n_frames++;
  `uvm_txn_info_h("TXN", $sformatf("Image HC out txn # %0d recieved", n_frames))

  if (dut_ihp_vif.histo_bank_sel) begin
    for (int i = 0; i < HISTO_SZ; i++) begin
      histo[i] = histo_bram_1_vif.memory[i];
    end
  end else begin
    for (int i = 0; i < HISTO_SZ; i++) begin
      histo[i] = histo_bram_0_vif.memory[i];
    end
  end
  histo_left_point = dut_ihp_vif.histo_left_point_i;
  histo_right_point = dut_ihp_vif.histo_right_point_i;


  @(posedge dut_ihp_vif.i_pixel_clk iff dut_ihp_vif.histo_process_pr_state == dut_ihp_vif.HISTO_PROCESS_RESET_BANK_INIT_ST);

  if (dut_ihp_vif.histo_bank_sel) begin
    for (int i = 0; i < HISTO_SZ; i++) begin
      histo_cdf[i] = histo_bram_0_vif.memory[i];
    end
  end else begin
    for (int i = 0; i < HISTO_SZ; i++) begin
      histo_cdf[i] = histo_bram_1_vif.memory[i];
    end
  end

  histo_cdf_256k_ceiling_idx = dut_ihp_vif.histo_cdf_256k_ceiling_addr;
  histo_p_low = dut_ihp_vif.histo_p_low;
  histo_p_high = dut_ihp_vif.histo_p_high;

  frame_idx = n_frames;
endtask


task `TXN_NAME::monitor(input dutb_if_proxy_base dutb_if_proxy_h);
  `uvm_txn_info_d("TXN", "Run monitor")
  this.init_vif(dutb_if_proxy_h);
  wait (dut_ihp_vif.i_sys_rst_n) #0;
  catch_output();
endtask
// *************************************************************************************************
