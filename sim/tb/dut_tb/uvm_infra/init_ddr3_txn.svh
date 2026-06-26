/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2026
    Class           :   init_ddr3_txn
    Description     :   Write data directly to DDR3 ram using DDR3 ram model tools
******************************************************************************************************************************/


`undef TXN_NAME
`define TXN_NAME init_ddr3_txn
// ****************************************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
    `uvm_object_utils(`TXN_NAME)

    dut_if_proxy dut_if_h;
    extern function                         new (string name = `STR(`TXN_NAME));
    extern virtual  task                    drive                   (input dutb_if_proxy_base dutb_if);
    // extern virtual  task                    monitor                 (input dutb_if_proxy_base dutb_if);
endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************

function `TXN_NAME::new(string name = `STR(`TXN_NAME));
    super.new(name);
endfunction


task `TXN_NAME::drive(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)

    `uvm_debug("Init DDR3 ram")
    dut_if_h.top_func_proxy.ddr3_memory_write(0,0,0,0);

    // // init coeffs
    // `INIT_DDR3(Init_0, $random, (`DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR / `DDR3_LINE_SIZE), 24);

    // // init dead pixels mask
    // `INIT_DDR3_DP_MASK(Init_1, $random, (`DDR3_DEAD_PIXEL_TABLE_BASE_ADDR / `DDR3_LINE_SIZE), 1);


    wait(0);
endtask
// ****************************************************************************************************************************



`define     INIT_DDR3(name, rnd_func, row_start, row_number) \
    initial\
        begin\
            bit [8 * 16 - 1    : 0]     bl8;\
            for (int row = row_start; row < (row_start + row_number); row = row + 1)\
                begin\
                    for (int col = 0; col < 1024; col = col + 8)\
                        begin\
                            bl8 = {16'(rnd_func``()), 16'(rnd_func``()), 16'(rnd_func``()), 16'(rnd_func``()), 16'(rnd_func``()), 16'(rnd_func``()), 16'(rnd_func``()), 16'(rnd_func``())};\
                            // memory_write (bank, row, col, data);\
                            // `uvm_debug($sformatf("%s row_col_val: %04d_%04d_0x%032X", `"name`", row, col, bl8))\
                            u_ram.memory_write(0, row, col, bl8);\
                        end\
                end\
        end



`define     INIT_DDR3_DP_MASK(name, rnd_func, row_start, row_number) \
    initial\
        begin\
            bit [8 * 16 - 1    : 0]     bl8, bl8_0, bl8_1, bl8_2, bl8_3, bl8_4;\
            bl8_0 = {16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000};\
            bl8_1 = {16'h8000, 16'h0000, 16'h0000, 16'h0001, 16'h0000, 16'h000F, 16'h0033, 16'h0009};\
            bl8_2 = {16'hC000, 16'h0000, 16'h0000, 16'h0003, 16'h0000, 16'h0000, 16'h0000, 16'h0003};\
            bl8_3 = {16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0005, 16'h0005};\
            bl8_4 = {16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0000, 16'h0003, 16'h0003};\
            for (int row = row_start; row < (row_start + row_number); row = row + 1)\
                begin\
                    for (int col = 0; col < 1024; col = col + 8)\
                        begin\
                            if (0 == col)\
                                begin\
                                    bl8 = bl8_1;\
                                end\
                            else if (64 == col)\
                                begin\
                                    bl8 = bl8_2;\
                                end\
                            else if (128 == col)\
                                begin\
                                    bl8 = bl8_2;\
                                end\
                            else if (192 == col)\
                                begin\
                                    bl8 = bl8_3;\
                                end\
                            else if (256 == col)\
                                begin\
                                    bl8 = bl8_0;\
                                end\
                            else\
                                begin\
                                    bl8 = bl8_0;\
                                end\
                            // memory_write (bank, row, col, data);\
                            // `uvm_debug($sformatf("%s row_col_val: %04d_%04d_0x%032X", `"name`", row, col, bl8))\
                            u_ram.memory_write(0, row, col, bl8);\
                        end\
                end\
        end
