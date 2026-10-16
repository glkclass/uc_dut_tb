/***************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Module          :   ttb
    Description     :
****************************************************************************************************/

`include "uvm_macros.svh"
import uvm_pkg::*;

//Provide access to top static funcs for UVM infra
import dut_tb_pkg::base_func_proxy;
class top_func_proxy extends base_func_proxy;
    task ddr3_memory_write(input int bank, row, col, data);
        `uvm_info_d("INF", "DDR3 memory write")
        ttb.u_ram.memory_write(bank, row, col, data);
    endtask
endclass
