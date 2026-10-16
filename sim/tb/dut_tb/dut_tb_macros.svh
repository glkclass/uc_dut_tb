/***************************************************************************************************
    Project         :   dutb
    Date            :   June 2026
    Description     :   Contains dut_tb macros.
***************************************************************************************************/


// *************************************************************************************************
`ifndef DUT_TB_MACRO_SVH

`define IMAGE_HC_PATH(item) u_ipp.image_histo_calculator.inst.``item
`define SENS_STREAMER_PATH(item) u_ipp.sens_streamer.inst.``item
`define BANK_STORE_PATH(item) u_ipp.bank_store.inst.``item
`define IPP_PATH(item) u_ipp.``item

`define HISTO_BRAM_UNIT(idx) u_ipp.image_histo_calculator.inst.u_histo_bank_``idx``.inst.native_mem_module.blk_mem_gen_v8_4_11_inst
`define HISTO_BRAM_PATH(idx, item) `HISTO_BRAM_UNIT(idx)``.item


`define DUT_TB_MACRO_SVH
`endif

// *************************************************************************************************
