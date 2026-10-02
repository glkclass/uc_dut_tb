
log_path=${LOG:-"vivado_cli.log"}
root_path=".."

# TODO: report_utilization

tasks=( "debug"
        "copy_bin_file"
        "create_vivado_project"
        "update_vivado_project"
        "synth"
        "generate_bitstream"
        "generate_aes_bitstream"
        "impl"
        "generate_impl_artefacts"
        "generate_platform"
        "upload_fpga_vivado"
        "upload_config_flash_vivado"
        "upload_n_config_flash_vivado"
        "program_aes_key_vivado"
        "upload_fpga_ofp_loader"
        "upload_config_flash_ofp_loader"
        "upload_settings_flash_ofp_loader"
        "upload_config_settings_flash_ofp_loader"
        "combine_config_settings_bin_files"
        "detect_jtag_targets" )

declare -A task_desc
task_desc[debug]="Debug"
task_desc[create_vivado_project]="Vivado. Create project."
task_desc[update_vivado_project]="Vivado. Update project: generate 2 tcl scripts used to create project and block design in future from scratch"
task_desc[synth]="Vivado. Run synthesis"
task_desc[generate_bitstream]="Vivado. Generate bitstreams: *.bit & *.bin"
task_desc[generate_aes_bitstream]="Vivado. Generate AES bitstreams: *.bit & *.bin"
task_desc[impl]="Vivado. Run implementation"
task_desc[generate_impl_artefacts]="Vivado. Generate post-implementation artefacts (func and time netlists, sdf files, ..)"
task_desc[generate_platform]="Vivado. Generate platform xsa file"
task_desc[upload_fpga_vivado]="Vivado. Upload fpga. Bit file: $PROGRAM_BIT_STREAM"
task_desc[upload_config_flash_vivado]="Vivado. Upload config flash. Bin file: $PROGRAM_BIN_STREAM"
task_desc[upload_n_config_flash_vivado]="Vivado. Upload N config flashes. Bin file: $PROGRAM_BIN_STREAM"
task_desc[program_aes_key_vivado]="Vivado. Program AES key. Key file: $PROGRAM_BIN_STREAM"
task_desc[upload_fpga_ofp_loader]="OpenFPGALoader. Upload fpga. Bit file: $PROGRAM_BIT_STREAM"
task_desc[upload_config_flash_ofp_loader]="OpenFPGALoader. Upload config flash. Bin file: $PROGRAM_BIN_STREAM"
task_desc[upload_settings_flash_ofp_loader]="OpenFPGALoader. Upload Settings flash. Bin file: $SETTINGS_FLASH_FIRMWARE_BIN"
task_desc[upload_config_settings_flash_ofp_loader]="OpenFPGALoader. Upload Config & Settings flashes. Bin file: $CONFIG_SETTINGS_FLASH_BIN"

task_is_legal=0



# parse args
while [ "$1" != "" ]; do
    PARAM=$1
    case $PARAM in
        -h | --help)
            echo "Usage: $0 -t | --task [${tasks[@]}]"
            exit 0
            ;;

        -t | --task)
            shift
            task="$1"
            ;;

        *)
            # This is the first non-option argument (the main file)
            break
            ;;
    esac
    shift # Move to the next argument
done


function main {
    # check task
    for task_i in "${tasks[@]}"; do
        if [[ "$task" == "$task_i" ]]; then
            task_is_legal=1
            break
        fi
    done

    if [[ $task_is_legal == 1 ]]; then
        echo "INFO | See console & $log_path, 1 and wait for finish.."
    else
        echo "ERROR | Unsupported task: <$task>!"
        echo "Usage: script_name -t | --task [${tasks[@]}]"
        exit 1
    fi

    echo "INFO | ${task_desc[$task]}"

    if [[ "$task" == "create_vivado_project" ]]; then
        $task
    elif [[ "$task" == "copy_bin_file" ]]; then
        $task
    elif [[ "$task" == "combine_config_settings_bin_files" ]]; then
        $task
    elif [[ "$task" == "upload_fpga_vivado" ]]; then
        $task
    elif [[ "$task" == "upload_config_flash_vivado" ]]; then
        $task
    elif [[ "$task" == "upload_n_config_flash_vivado" ]]; then
        $task
    elif [[ "$task" == "upload_fpga_ofp_loader" ]]; then
        $task
    elif [[ "$task" == "upload_config_flash_ofp_loader" ]]; then
        $task
    elif [[ "$task" == "upload_settings_flash_ofp_loader" ]]; then
        $task
    elif [[ "$task" == "detect_jtag_targets" ]]; then
        $task
    elif [[ "$task" == "debug" ]]; then
        $task
    else
        vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs $task &>> $log_path
        println
        check_log_errors
    fi
}


function check_log_errors {
    if [ -f "$log_path" ]; then
        ERROR_PATTERN="(^ERROR:)|(^FATAL:)"
        grep -En $ERROR_PATTERN $log_path
        n_errors=`grep -Ec $ERROR_PATTERN $log_path`
        if (( n_errors > 0 )); then
            echo "ERROR | .. Failed. Terminated due to ${n_errors} error(s). See log for details: ${log_path}, 1."
            exit 1
        else
            echo "INFO | .. Ok"
        fi
    else
        echo "WARNING | $log_path does not exist."
    fi
}


function println {
    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" &>> $log_path
}


function copy_bin_file {
    echo "INFO | Copy ${VIVADO_BIN_STREAM} to ${ARTEFACT_BIN_STREAM}"
    cp -r ${VIVADO_BIN_STREAM} ${ARTEFACT_BIN_STREAM}
    echo "INFO | Copy ${VIVADO_BIT_STREAM} to ${ARTEFACT_BIT_STREAM}"
    cp -r ${VIVADO_BIT_STREAM} ${ARTEFACT_BIT_STREAM}
}


function debug {
    echo "Define stuff!"
}


function create_vivado_project {
    # create rtl include and xdc configs
    if [[ $FLASH_SPI_INTERFACE == "x4" ]]; then
        echo "FLASH_SPI_INTERFACE=x4" > $FLASH_SPI_INTERFACE_ENV
        echo "\`define   FLASH_SPI_INTERFACE_X4" > $VIVADO_SPI_FLASH_TYPE_INCLUDE
        echo "set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]" > $VIVADO_SPI_FLASH_PROPERTY_XDC
    elif [[ $FLASH_SPI_INTERFACE == "x1" ]]; then
        echo "FLASH_SPI_INTERFACE=x1" > $FLASH_SPI_INTERFACE_ENV
        echo "\`define   FLASH_SPI_INTERFACE_X1" > $VIVADO_SPI_FLASH_TYPE_INCLUDE
        echo "set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]" > $VIVADO_SPI_FLASH_PROPERTY_XDC
    else
        echo "" > $VIVADO_SPI_FLASH_TYPE_INCLUDE
        echo "ERROR | .. Failed. Terminated. Wrong <FLASH_SPI_INTERFACE> env var value: $FLASH_SPI_INTERFACE"
        exit 1
    fi


    # create vivado project
    echo "INFO | Step 1 (create project) .."
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs create_vivado_project &>> $log_path
    println
    check_log_errors

    # create block design and add it to project
    echo "INFO | Step 2 (add block design) .."
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs add_block_design &>> $log_path
    println
    check_log_errors

    # customize config_flash
    echo "INFO | Customize config flash type: ${FLASH_SPI_INTERFACE} .."
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs customize_config_flash $FLASH_SPI_INTERFACE &>> $log_path
    println
    check_log_errors
}


function upload_fpga_vivado {
    [ ! -f $PROGRAM_BIT_STREAM ] && echo "ERROR | Can't find bit file: $PROGRAM_BIT_STREAM. Terminated!" && exit 1
    $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    check_log_errors
}


function upload_config_flash_vivado {
    [ ! -f $PROGRAM_BIN_STREAM ] && echo "ERROR | Can't find bin file: $PROGRAM_BIN_STREAM. Terminated!" && exit 1
    $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    check_log_errors
}

target_url="localhost:3121/xilinx_tcf/Digilent/"

# Detect active jtag targets
function detect_jtag_targets {
    echo "INFO | Detect active jtag targets .."
    active_targets_regex="active_hw_targets.*"
    target_regex="^${target_url}[0-9A-F]+"
    $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs print_jtag_targets &>> $log_path
    active_targets_line=$(grep -E $active_targets_regex $log_path)
    for target in $active_targets_line; do
        if [[ $target =~ $target_regex ]]; then
            echo "INFO | Jtag target detected: $target"
            targets+=($target)
        fi
    done
    n_targets=${#targets[@]}
    echo "INFO | Total number: $n_targets"
    echo "INFO | ..Done"
}


function upload_n_config_flash_vivado {
    [ ! -f $PROGRAM_BIN_STREAM ] && echo "ERROR | Can't find bin file: $PROGRAM_BIN_STREAM. Terminated!" && exit 1

    targets=()
    if [[ -n "$PROGRAM_JTAG_TARGET_ID" ]]; then
        # Apply jtag targets to program
        echo "INFO | Apply jtag targets using <PROGRAM_JTAG_TARGET_ID> env var setup"
        for target_id in ${PROGRAM_JTAG_TARGET_ID//:/ }; do
            echo "INFO | Jtag target applied: ${target_url}${target_id}"
            targets+=("${target_url}${target_id}")
        done
        n_targets=${#targets[@]}
        echo "INFO | Total number: $n_targets"
    else
        detect_jtag_targets
        echo "INFO | For now autodetect doesn't work together with programming due to 'multiple hw_server runs' issue"
        return
    fi

    # loop on applied jtag connections
    for target in ${targets[@]}; do
        echo "INFO | Programming. Bitstream: ${PROGRAM_BIN_STREAM}. Config flash: $FLASH_DEVICE. Jtag target: ${target}"
        $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs upload_config_flash_vivado ${target} &>> $log_path

        # polling hw_server process till is stopped
        echo "INFO | Wait for hw_server stop.."
        for ((i=0; i<=30; i++)); do
            if ! pgrep -f hw_server > /dev/null; then
                echo "INFO | ..hw_server stopped. Go to next target."
                break
            fi
            # echo "INFO | hw_server is still running.."
            sleep 2
        done

        # kill if still alive
        if HW_SERVER_PID=$(pgrep -f hw_server); then
            echo "WARNING | ..hw_server is still running. Terminating.."
            kill "$HW_SERVER_PID"
            sleep 1
            if kill -0 "$HW_SERVER_PID" 2>/dev/null; then
                kill -9 "$HW_SERVER_PID"
            fi
            echo "INFO | ..Done"
        fi
    done
    wait

    echo "INFO | $n_targets flash devices done. See log for details: $log_path."
    check_log_errors
    echo "INFO | Done"
}


function upload_fpga_ofp_loader {
    [ ! -f $PROGRAM_BIT_STREAM ] && echo "ERROR | Can't find bit file: $PROGRAM_BIT_STREAM. Terminated!" && exit 1
    openFPGALoader --cable digilent_hs3 --fpga-part $FPGA_DEVICE_FULL_NAME --verify --bitstream ${PROGRAM_BIT_STREAM}
}

function upload_config_flash_ofp_loader {
    [ ! -f $PROGRAM_BIN_STREAM ] && echo "ERROR | Can't find bit file: $PROGRAM_BIN_STREAM. Terminated!" && exit 1
    openFPGALoader --cable digilent_hs3 --fpga-part $FPGA_DEVICE_FULL_NAME --write-flash --verify --bitstream ${PROGRAM_BIN_STREAM}
}

function upload_settings_flash_ofp_loader {
    [ ! -f $SETTINGS_FLASH_FIRMWARE_BIN ] && echo "ERROR | Can't find bit file: $SETTINGS_FLASH_FIRMWARE_BIN. Terminated!" && exit 1
    openFPGALoader --cable digilent_hs3 --fpga-part $FPGA_DEVICE_FULL_NAME --write-flash --verify --offset 2097152 --bitstream ${SETTINGS_FLASH_FIRMWARE_BIN}
}

function upload_config_settings_flash_ofp_loader {
    combine_config_settings_bin_files
    [ ! -f $CONFIG_SETTINGS_FLASH_BIN ] && echo "ERROR | Can't find bit file: $CONFIG_SETTINGS_FLASH_BIN. Terminated!" && exit 1
    openFPGALoader --cable digilent_hs3 --fpga-part $FPGA_DEVICE_FULL_NAME --write-flash --verify --bitstream ${CONFIG_SETTINGS_FLASH_BIN}
}

function combine_config_settings_bin_files {
    [ ! -f $PROGRAM_BIN_STREAM ] && echo "ERROR | Can't find bit file: $PROGRAM_BIN_STREAM. Terminated!" && exit 1
    [ ! -f $SETTINGS_FLASH_FIRMWARE_BIN ] && echo "ERROR | Can't find bit file: $SETTINGS_FLASH_FIRMWARE_BIN. Terminated!" && exit 1
    dd if=$PROGRAM_BIN_STREAM ] of=$CONFIG_SETTINGS_FLASH_BIN conv=notrunc
    dd if=$SETTINGS_FLASH_FIRMWARE_BIN ] of=$CONFIG_SETTINGS_FLASH_BIN conv=notrunc seek=2048 bs=1k
}

main
