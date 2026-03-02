/******************************************************************************************************************************
    Project         :   dutb
    Creation Date   :   Dec 2015
    Description     :   Contain dutb macros used.
******************************************************************************************************************************/


// ****************************************************************************************************************************
`ifndef DUT_TB_MACRO_SVH
`define DUT_TB_MACRO_SVH

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

`endif


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


// ****************************************************************************************************************************

