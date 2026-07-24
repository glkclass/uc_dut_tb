/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2025
    Class           :   init_ips_txn
    Description     :   Init ips params. Works one once at startup to init set of config params
                        using defaults or runtime $value$plusargs values.
******************************************************************************************************************************/


`define TXN_NAME init_ips_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// ****************************************************************************************************************************
class `TXN_NAME #(parameter integer FPS = `IPS_FPS_30,
                                    PP_MODE = `IPS_PP_RAW_IMAGE,
                                    MIPI_CSI_STREAM_EN = 1'b1,
                                    MIPI_CSI_DATA_FORMAT = `RAW16_BE,
                                    UVC_STREAM_EN = 1'b1,
                                    TRIGGER_EN = 1'b1,
                                    DPM_EN = 1'b1,
                                    LED_EN = 1'b1,
                                    SOFT_TRIGGER = 1'b0) extends dutb_txn_base;

    `uvm_object_param_utils(`TXN_NAME #(FPS,
                                        PP_MODE,
                                        MIPI_CSI_STREAM_EN,
                                        MIPI_CSI_DATA_FORMAT,
                                        UVC_STREAM_EN,
                                        TRIGGER_EN,
                                        DPM_EN,
                                        LED_EN,
                                        SOFT_TRIGGER))

    int fps, pp_mode, mipi_csi_stream_en, mipi_csi_data_format,
        uvc_stream_en, trigger_en, dpm_en;

    dut_if_proxy dut_if_h;
    virtual dut_if dut_vif;
    virtual sys_if vif;

    extern function                             new (string name = `STR(`TXN_NAME));
    extern virtual  task                        drive (input dutb_if_proxy_base dutb_if);

endclass
// ****************************************************************************************************************************


// ****************************************************************************************************************************
function `TXN_NAME::new(string name = `STR(`TXN_NAME));
    super.new(name);

    // Get runtime config
    fps = `get_arg_value("OCT_FPS=%d", fps, FPS);
    pp_mode = `get_arg_value("OCT_PP_MODE=%d", pp_mode, PP_MODE);
    mipi_csi_stream_en = `get_arg_value("OCT_MIPI_CSI_STREAM_EN=%d", mipi_csi_stream_en, MIPI_CSI_STREAM_EN);
    mipi_csi_data_format = `get_arg_value("OCT_MIPI_CSI_DATA_FORMAT=%d", mipi_csi_data_format, MIPI_CSI_DATA_FORMAT);
    uvc_stream_en = `get_arg_value("OCT_UVC_STREAM_EN=%d", uvc_stream_en, UVC_STREAM_EN);
    trigger_en = `get_arg_value("OCT_TRIGGER_EN=%d", trigger_en, TRIGGER_EN);
    dpm_en = `get_arg_value("OCT_DPM=%d", dpm_en, DPM_EN);
endfunction


task `TXN_NAME::drive(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    vif = dut_if_h.dut_vif.sys_vif;

    vif.coeff_table_ddr3_base_addr = `DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR >> 11;

    vif.ips[`IPS_FPS_OFFS] = (60 == fps) ? `IPS_FPS_60 : `IPS_FPS_30;
    vif.ips[`IPS_MIPI_CSI_PP_MODE_OFFS + `IPS_MIPI_CSI_UVC_PP_MODE_WIDTH - 1    :   `IPS_MIPI_CSI_PP_MODE_OFFS] = pp_mode;
    vif.ips[`IPS_MIPI_CSI_STREAM_EN_OFFS] = mipi_csi_stream_en;
    vif.ips[`IPS_MIPI_CSI_DATA_FORMAT_OFFS + `IPS_MIPI_CSI_UVC_DATA_FORMAT_WIDTH - 1    :   `IPS_MIPI_CSI_DATA_FORMAT_OFFS] = mipi_csi_data_format;
    vif.ips[`IPS_UVC_STREAM_EN_OFFS] = uvc_stream_en;
    vif.ips[`IPS_TRIGGER_EN_OFFS] = trigger_en;
    vif.ips[`IPS_DPM_EN_OFFS] = dpm_en;
    vif.ips[`IPS_LED_EN_OFFS] = LED_EN;
    vif.ips[`IPS_SOFT_TRIGGER_OFFS] = SOFT_TRIGGER;

    wait(0);
endtask

typedef init_ips_txn #()                    init_ips_txn_default;
typedef init_ips_txn #(.FPS(`IPS_FPS_60))   init_ips_txn_fps60;
// ****************************************************************************************************************************



