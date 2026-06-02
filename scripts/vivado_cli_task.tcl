set CREATE_TOP_BD_TCL create_top_bd.tcl
set CREATE_PROJECT_TCL create_vivado_project.tcl
set ELF_FILE $env(VIVADO_IMPORTS)/$env(VIVADO_PROJECT_ELF_NAME)

set TASKS {print_hw_targets create_vivado_project update_vivado_project add_block_design synth impl generate_platform generate_bitstream load_fpga program_flash debug}


# Debug stuff
proc debug { args_list } {
    puts "Run debug task"
    set foo [lindex $args_list 2]
    puts $foo
}

# Print active hw targets
proc print_hw_targets { args_list } {
    try {
        open_hw_manager
        connect_hw_server -allow_non_jtag
        set active_hw_targets [get_hw_targets]
        puts "active_hw_targets: $active_hw_targets"
    } on error {msg info} {
        puts $msg
        puts $info
        puts active_hw_targets
    }
}


# Create project using script generated in advance
proc create_vivado_project { args_list } {
    global CREATE_PROJECT_TCL
    source $CREATE_PROJECT_TCL
}


# Create block design and add it to project
proc add_block_design { args_list } {
    global env CREATE_TOP_BD_TCL
    open_project $env(VIVADO_PROJECT)
    source $CREATE_TOP_BD_TCL
}


# Update Vivado project:
# Save last project update to 2 tcl scripts will be used to generate the project in future from scratch
proc update_vivado_project { args_list } {
    global env CREATE_TOP_BD_TCL CREATE_PROJECT_TCL ELF_FILE

    open_project $env(VIVADO_PROJECT)
    remove_files  ${ELF_FILE}
    remove_files  -fileset sim_1 ${ELF_FILE}


    # generate scripts to recreate bd in future from scratch
    open_bd_design $env(VIVADO_PROJECT_TOP_BD)
    validate_bd_design
    write_bd_tcl -include_layout -force $CREATE_TOP_BD_TCL
    remove_files $env(VIVADO_PROJECT_TOP_BD)

    # remove checkpoints if exist
    set checkpoint_file_list [glob -nocomplain $env(VIVADO_PROJECT_CHECKPOINT_PATTERN)]
    if {[llength $checkpoint_file_list] > 0} {
        puts "INFO | Remove checkpoints '$checkpoint_file_list'."
        remove_files  -fileset utils_1 $checkpoint_file_list
    }
    # generate script to create Vivado project in future from scratch
    write_project_tcl -no_copy_sources -target_proj_dir $env(VIVADO_PROJECT_FOLDER) -force $CREATE_PROJECT_TCL
}


# refresh rtl changes
proc refresh_opened_project {} {
    # global VIVADO_PROJECT PROJECT_TOP_BD
    # open_project $VIVADO_PROJECT
    # open_bd_design $PROJECT_TOP_BD

    update_compile_order -fileset sources_1
    # set_property source_mgmt_mode All [current_project]

    foreach cell [get_bd_cells -hierarchical ] {
        set comp_name [get_property CONFIG.Component_Name $cell]
        set vlnv [get_property VLNV $cell]
        set fields [split $vlnv ":"]
        set type [lindex $fields 1]
        # set name    [lindex $fields 2]
        # set ver    [lindex $fields 3]
        # puts $comp_name
        # puts $vlnv
        # puts $type
        # puts $name
        # puts $ver
        if {$type == "module_ref"} {
            update_module_reference $comp_name
        }
    }
    validate_bd_design
}


# Add elf file to project and associate it to apropriate targets
proc add_elf_file {} {
    global env ELF_FILE

    add_files -norecurse ${ELF_FILE}
    set_property SCOPED_TO_REF $env(VIVADO_DESIGN_NAME) [get_files -all -of_objects [get_fileset sources_1] ${ELF_FILE}]
    set_property SCOPED_TO_CELLS $env(VIVADO_DESIGN_CORE) [get_files -all -of_objects [get_fileset sources_1] ${ELF_FILE}]

    add_files -fileset sim_1 -norecurse ${ELF_FILE}
    set_property SCOPED_TO_REF $env(VIVADO_DESIGN_NAME) [get_files -all -of_objects [get_fileset sim_1] ${ELF_FILE}]
    set_property SCOPED_TO_CELLS $env(VIVADO_DESIGN_CORE) [get_files -all -of_objects [get_fileset sim_1] ${ELF_FILE}]
    set_property used_in_simulation true [get_files -of_objects [get_filesets sources_1] ${ELF_FILE}]
}


# generate xsa platform file
proc generate_platform { args_list } {
    global env
    open_project $env(VIVADO_PROJECT)
    open_bd_design $env(VIVADO_PROJECT_TOP_BD)
    write_hw_platform -fixed -force -file $env(VIVADO_XSA_PLATFORM_FILE)
    close_project
}


# run synthesis
proc synth { args_list } {
    global env

    open_project $env(VIVADO_PROJECT)
    open_bd_design $env(VIVADO_PROJECT_TOP_BD)
    refresh_opened_project

    reset_run synth_1
    launch_runs synth_1 -jobs $env(N_JOBS)
    wait_on_run synth_1

    close_project
}


# run implementation
proc impl { args_list } {
    global env

    open_project $env(VIVADO_PROJECT)
    open_bd_design $env(VIVADO_PROJECT_TOP_BD)
    add_elf_file
    # refresh_opened_project

    # open_run synth_1

    reset_run impl_1
    launch_runs impl_1 -jobs $env(N_JOBS)
    wait_on_run impl_1

    close_project
}


# generate bitstreams
proc generate_bitstream { args_list } {
    global env
    open_project $env(VIVADO_PROJECT)
    open_run impl_1
    write_bitstream -force $env(VIVADO_BIT_STREAM)
    write_cfgmem  -format bin -size $env(VIVADO_BIN_STREAM_SIZE) -interface $env(FLASH_SPI_INTERFACE) -loadbit "up 0x00000000 $env(VIVADO_BIT_STREAM)" -checksum -force -file $env(VIVADO_BIN_STREAM)
    close_project
}


# program fpga
proc load_fpga { args_list } {
    global env

    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    current_hw_device [get_hw_devices $env(FPGA_DEVICE)]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
    set_property PROBES.FILE {} [get_hw_devices $env(FPGA_DEVICE)]
    set_property FULL_PROBES.FILE {} [get_hw_devices $env(FPGA_DEVICE)]
    set_property PROGRAM.FILE $env(VIVADO_BIT_STREAM) [get_hw_devices $env(FPGA_DEVICE)]
    program_hw_devices [get_hw_devices $env(FPGA_DEVICE)]
    refresh_hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
}


# program config flash
proc program_flash { args_list } {
    global env

    try {
        open_hw_manager
        connect_hw_server -allow_non_jtag

        set args_size [llength $args_list]
        if {$args_size > 1} {
            set JTAG_TARGET [lindex $args_list 1]
            open_hw_target $JTAG_TARGET
        } else {
            open_hw_target
        }

        current_hw_device [get_hw_devices $env(FPGA_DEVICE)]
        refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
        create_hw_cfgmem -hw_device [get_hw_devices $env(FPGA_DEVICE)] -mem_dev [lindex [get_cfgmem_parts $env(FLASH_DEVICE)] 0]
        set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.FILES [list $env(PROGRAM_BIN_STREAM) ] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.PRM_FILE {} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        create_hw_bitstream -hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0] [get_property PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
        program_hw_devices [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
        refresh_hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
        program_hw_cfgmem -hw_cfgmem [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]]
    } on error {msg info} {
        puts $msg
    }

}


if {$argc > 0} {
    set task [lindex $argv 0]

    if {!($task in $TASKS)} {
        puts "ERROR | Unsupported task specified: <$task> !"
        exit 1
    } else {
        puts "INFO | Vivado task to execute: <$task>."
    }
} else {
    puts "ERROR | No tclargs with Vivado task specified!"
    exit 1
}


$task $argv
exit 0
