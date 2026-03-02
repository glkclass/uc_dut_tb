/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Package         :   dut_tb_util_pkg;
    Description     :   Contains consts, typedefs, utils, ...
******************************************************************************************************************************/


// ****************************************************************************************************************************
package dut_tb_util_pkg;
    // `include "uvm_macros.svh"
    // `include "dutb_macros.svh"

    // import uvm_pkg::*;

    parameter time

        T_CLK_100MHZ_PERIOD     = 10ns,
        T_CLK_50MHZ_PERIOD      = 20ns,
        T_CLK_72_25MHZ_PERIOD   = 13468ps,
        T_CLK_27MHZ_PERIOD      = 37ns,
        T_RST_N_LEN             = 3us,
        T_TEST_LEN              = 1000us;


    typedef     logic[15:0]                                 t_pixel;

endpackage
// ****************************************************************************************************************************

