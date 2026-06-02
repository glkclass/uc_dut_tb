
log_path=${LOG:-"vivado_cli.log"}
root_path=".."

# TODO: report_utilization

TASKS=("debug" "git_clean" "create_vivado_project" "update_vivado_project" "refresh_project" "synth" "impl" "generate_platform" "generate_impl_artefacts" "generate_bitstream" "copy_bin_file" "load_fpga" "program_flash" "program_n_flash")
task_is_legal=0


while [ "$1" != "" ]; do
    PARAM=$1
    case $PARAM in
        -h | --help)
            echo "Usage: $0 -t | --task [${TASKS[@]}]"
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

for task_i in "${TASKS[@]}"; do
    if [[ "$task" == "$task_i" ]]; then
        task_is_legal=1
        break # Stop looping immediately upon finding a match
    fi
done



if [[ $task_is_legal == 1 ]]; then
    echo "INFO | See $log_path, 1 and wait for finish.."
else
    echo "ERROR | Unsupported task: <$task>!"
    echo "Usage: script_name -t | --task [${TASKS[@]}]"
    exit 1
fi


function check_log_errors {
    ERROR_PATTERN="(^ERROR:)|(^FATAL:)"

    grep -En $ERROR_PATTERN $log_path
    n_errors=`grep -Ec $ERROR_PATTERN $log_path`

    if (( n_errors > 0 )); then
        echo "ERROR | ..Failed. Terminated due to ${n_errors} error(s). See log for details: ${log_path}, 1."
        exit 1
    else
        echo "INFO | ..Ok"
    fi
}


function extract_version {
    version_src_path="${root_path%/}/rtl/common/fpga_firmware_commit_hash.vh"
    dotnet_gitversion=$(dotnet-gitversion)
    echo $dotnet_gitversion

    pattern='.*\"Major\"\: ([0-9]+),.*'
    if [[ "$dotnet_gitversion" =~ $pattern ]]; then
        major=${BASH_REMATCH[1]}
    else
        major=255
    fi

    pattern='.*\"Minor\"\: ([0-9]+),.*'
    if [[ "$dotnet_gitversion" =~ $pattern ]]; then
        minor=${BASH_REMATCH[1]}
    else
        minor=255
    fi

    pattern='.*\"Patch\"\: ([0-9]+),.*'
    if [[ "$dotnet_gitversion" =~ $pattern ]]; then
        patch=${BASH_REMATCH[1]}
    else
        patch=255
    fi

    pattern='.*\"InformationalVersion\"\: \"(\S+)\",.*'
    if [[ "$dotnet_gitversion" =~ $pattern ]]; then
        informational_version=${BASH_REMATCH[1]}
    else
        informational_version=XXX
    fi

    echo $major
    echo $minor
    echo $patch
    echo $informational_version
}


function println {
    echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" &>> $log_path
}


function debug {
    # debug tcl
    # vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} arg1 2 &>> $log_path
    check_log_errors
}


function create_vivado_project {
    # all 'version' manipulations are performed in microcode part (software)
    # extract_version

    # create vivado project
    echo "INFO | Vivado. Create project: step 1.."
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs create_vivado_project &>> $log_path
    println
    check_log_errors

    # generate block design and add it to project
    echo "INFO | Vivado. Create project: step 2 (add block design).."
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs add_block_design &>> $log_path
    println
    check_log_errors
}


function update_vivado_project {
    echo "INFO | Vivado. Update project: generate 2 tcl scripts used to create project in future from scratch"
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    println
    check_log_errors
}


function generate_platform {
    echo "INFO | Vivado. Generate platform xsa file.."
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    println
    check_log_errors
}


function synth {
    echo "INFO | Vivado. Run synthesis"
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    println
    check_log_errors
}


function impl {
    echo "INFO | Vivado. Run implementation"
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    println
    check_log_errors
}


function generate_impl_artefacts {
    echo "INFO | Vivado. Generate post-implementation artefacts (func and time netlists, sdf file)"
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    println
    check_log_errors
}


function generate_bitstream {
    echo "INFO | Vivado. Generate bitstreams: *.bit & *.bin"
    vivado -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    println
    check_log_errors
}


function copy_bin_file {
    echo "INFO | Copy ${VIVADO_BIN_STREAM} to $ART_BIN_FOLDER"
    cp -r ${VIVADO_BIN_STREAM} ${ART_BIN_FOLDER}

}


function load_fpga {
    echo "INFO | Vivado. Load fpga. Bit file: $VIVADO_BIT_STREAM"
    $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    check_log_errors
}


function program_flash {
    echo "INFO | Vivado. Program config flash. Bin file: $PROGRAM_BIN_STREAM"
    [ ! -f $PROGRAM_BIN_STREAM ] && echo "ERROR | Can't find bin file: $PROGRAM_BIN_STREAM. Terminated!" && exit 1
    $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs ${FUNCNAME[0]} &>> $log_path
    check_log_errors
}


function program_n_flash {
    echo "INFO | Vivado. Program N config flashes. Bin file: $PROGRAM_BIN_STREAM"
    [ ! -f $PROGRAM_BIN_STREAM ] && echo "ERROR | Can't find bin file: $PROGRAM_BIN_STREAM. Terminated!" && exit 1
    # Detect active jtag connections
    echo "INFO | Detect active targets .."
    $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs print_hw_targets &>> $log_path
    active_targets_regex="active_hw_targets.*"
    target_regex="^localhost:3121/xilinx_tcf/Digilent/[0-9A-F]+"
    active_targets_line=$(grep -E $active_targets_regex $log_path)
    echo "INFO | ..Done"
    # echo $active_targets_line

    # loop on active jtag connections
    n_targets=0
    for target in $active_targets_line; do
        if [[ $target =~ $target_regex ]]; then
            echo "INFO | Programming. Bitstream: ${PROGRAM_BIN_STREAM}. Config flash: $FLASH_DEVICE. Jtag target: $target."
            $VIVADO_BIN_TOOL -nolog -nojournal -notrace -mode batch -source vivado_cli_task.tcl -tclargs program_flash $target &>> $log_path &
            ((n_targets++))
        fi
    done
    wait

    if [[ $n_targets != 0 ]]; then
        echo "INFO | $n_targets flash devices done. See log for details: $log_path."
    else
        echo "ERROR | No active connections detected!"
    fi

    check_log_errors
}


function git_clean {
    echo "INFO | Cleanup"
    (
    cd ${root_path%/}
    git clean -qfxd
    )
}


# execute requested task
$task
# exit 0
