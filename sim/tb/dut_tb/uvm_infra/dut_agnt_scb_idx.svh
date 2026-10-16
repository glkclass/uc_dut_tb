/***************************************************************************************************
    Project         :   AM
    Date            :   June 2026
    Description     :
***************************************************************************************************/


// *************************************************************************************************
// DUTB agents & scb idx
//
`default_nettype none

enum integer {
    INIT_IPS_AGNT_IDX = 0,
    FFC_REQ_AGNT_IDX,
    INIT_DDR3_AGNT_IDX,
    PROXY_BOARD_IMAGE_AGNT_IDX,
    MIPI_CSI_AXIS_AGNT_IDX,
    CORE_SYS_AGNT_IDX,
    SNS_RD_DDR3_AGNT_IDX,
    SNS_RD_COEFF_AGNT_IDX,
    PROXY_BOARD_TRIGGER_AGNT_IDX,
    IMAGE_HC_IN_AGNT_IDX,
    IMAGE_HC_OUT_AGNT_IDX
} agnt_idx;

enum integer {
    PROXY_BOARD_IMAGE_SCB_IDX = 0,
    IMAGE_HC_SCB_IDX
} scb_idx;

`default_nettype wire
// *************************************************************************************************
