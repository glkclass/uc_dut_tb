/******************************************************************************************************************************
    Project         :   AM
    Date            :   June 2026
    Class           :   init_ips_txn
    Description     :   Inits ips params (all or some of them).
                        May be used:
                            1. Once at startup to init set of ips config params
                            using default params or runtime $value$plusargs values.
                            2. During the test to apply sequence at the given ips pins (like a ffc request or change pp_mode).
******************************************************************************************************************************/


`define TXN_NAME init_ips_txn
`define TXN_NAME_PREFIX(prefix) `TXN_NAME``prefix
// ****************************************************************************************************************************
class `TXN_NAME extends dutb_txn_base;
    `uvm_object_utils(`TXN_NAME)

    int fps, pp_mode, mipi_csi_stream_en, mipi_csi_data_format,
        uvc_stream_en, trigger_en, dpm_en, led_en, soft_trigger, ffc_req;

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
    fps = `get_arg_value("OCT_FPS=%d", fps, `IPS_FPS_30);
    pp_mode = `get_arg_value("OCT_PP_MODE=%d", pp_mode, `IPS_PP_RAW_IMAGE);
    mipi_csi_stream_en = `get_arg_value("OCT_MIPI_CSI_STREAM_EN=%d", mipi_csi_stream_en, 1'b1);
    mipi_csi_data_format = `get_arg_value("OCT_MIPI_CSI_DATA_FORMAT=%d", mipi_csi_data_format, `RAW16_BE);
    uvc_stream_en = `get_arg_value("OCT_UVC_STREAM_EN=%d", uvc_stream_en, 1'b1);
    trigger_en = `get_arg_value("OCT_TRIGGER_EN=%d", trigger_en, 1'b1);
    dpm_en = `get_arg_value("OCT_DPM=%d", dpm_en, 1'b1);
    led_en = 1'b0;
    soft_trigger = 1'b0;
    ffc_req = 1'b0;
endfunction


task `TXN_NAME::drive(input dutb_if_proxy_base dutb_if);
    `ASSERT_TYPE_CAST(dut_if_h, dutb_if)
    dut_vif = dut_if_h.dut_vif;
    vif = dut_if_h.dut_vif.sys_vif;

    vif.coeff_table_ddr3_base_addr = `DDR3_MEMORY_CYCLIC_COEFF_TABLE_BASE_ADDR >> 11;

    vif.ips[`IPS_FPS_OFFS] = (60 == fps) ? `IPS_FPS_60 : `IPS_FPS_30;
    vif.ips[`IPS_MIPI_CSI_PP_MODE_OFFS + `IPS_MIPI_CSI_UVC_PP_MODE_WIDTH - 1    :   `IPS_MIPI_CSI_PP_MODE_OFFS] = pp_mode;
    vif.ips[`IPS_MIPI_CSI_STREAM_EN_OFFS] = mipi_csi_stream_en;

    vif.ips[`IPS_MIPI_CSI_DATA_FORMAT_OFFS + `IPS_MIPI_CSI_UVC_DATA_FORMAT_WIDTH - 1    :   `IPS_MIPI_CSI_DATA_FORMAT_OFFS] =
        mipi_csi_data_format;

    vif.ips[`IPS_UVC_STREAM_EN_OFFS] = uvc_stream_en;
    vif.ips[`IPS_TRIGGER_EN_OFFS] = trigger_en;
    vif.ips[`IPS_DPM_EN_OFFS] = dpm_en;
    vif.ips[`IPS_LED_EN_OFFS] = led_en;
    vif.ips[`IPS_SOFT_TRIGGER_OFFS] = soft_trigger;
    vif.ips[`IPS_FFC_REQ_OFFS] = ffc_req;

    wait(0);
endtask

typedef init_ips_txn                        init_ips_txn_default;
// ****************************************************************************************************************************



