set CREATE_TOP_BD_TCL create_top_bd.tcl
set CREATE_PROJECT_TCL create_vivado_project.tcl
set ELF_FILE $env(VIVADO_IMPORTS)/$env(VIVADO_PROJECT_ELF_NAME)

set TASKS { print_jtag_targets
            create_vivado_project
            update_vivado_project
            add_block_design
            customize_config_flash
            synth
            impl
            generate_impl_artefacts
            generate_platform
            generate_bitstream
            generate_aes_bitstream
            upload_fpga_vivado
            upload_config_flash_vivado
            program_aes_key_vivado
            debug
}


# Debug stuff
proc debug { args_list } {
    puts "Run debug task"
    set foo [lindex $args_list 2]
    puts $foo
}

# Print active hw targets
proc print_jtag_targets { args_list } {
    try {
        open_hw_manager
        connect_hw_server -allow_non_jtag
        set active_hw_targets [get_hw_targets]
        puts "active_hw_targets: $active_hw_targets"
        disconnect_hw_server [current_hw_server]
        close_hw_manager
    } on error {msg info} {
        puts "Failed.."
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


# Create block design and add it to project
proc customize_config_flash { args_list } {
    global env
    open_project $env(VIVADO_PROJECT)
    open_bd_design $env(VIVADO_PROJECT_TOP_BD)
    set config_flash_spi_interface [lindex $args_list 0]
    if {$config_flash_spi_interface == "X4"} {
        set_property CONFIG.C_SPI_MEMORY {2} [get_bd_cells core_sys/low_speed_ports/config_flash_spi]
        set_property CONFIG.C_SPI_MODE {2} [get_bd_cells core_sys/low_speed_ports/config_flash_spi]
        set_property CONFIG.C_FIFO_DEPTH {256} [get_bd_cells core_sys/low_speed_ports/config_flash_spi]
    } elseif {$config_flash_spi_interface == "X1"} {
        set_property CONFIG.C_SPI_MODE {0} [get_bd_cells core_sys/low_speed_ports/config_flash_spi]
        set_property CONFIG.C_FIFO_DEPTH {256} [get_bd_cells core_sys/low_speed_ports/config_flash_spi]
    }
    save_bd_design
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


# generate xsa platform file
proc generate_platform { args_list } {
    global env
    open_project $env(VIVADO_PROJECT)
    open_bd_design $env(VIVADO_PROJECT_TOP_BD)
    write_hw_platform -fixed -force -file $env(VIVADO_XSA_PLATFORM_FILE)
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


# Generate post-implementation artefacts (func and time netlists, sdf files, ..)
proc generate_impl_artefacts { args_list } {
    global env
    open_project $env(VIVADO_PROJECT)
    # loop on IP which are not BD cells
    foreach ip [get_ips -filter {IS_BD_CONTEXT != "Yes"}] {
        set ip_file_name [get_property IP_FILE $ip]
        reset_target all [get_files  $ip_file_name]
        export_ip_user_files -of_objects  [get_files  $ip_file_name] -sync -no_script -force -quiet
        generate_target all [get_files  $ip_file_name]
    }
    close_project
}


# generate encrtypted bitstreams
proc generate_aes_bitstream { args_list } {
    global env
    if {"x4" == $env(FLASH_SPI_INTERFACE)} {
      set SPI_INTERFACE "SPIx4"
    } elseif {"x1" == $env(FLASH_SPI_INTERFACE)} {
      set SPI_INTERFACE "SPIx1"
    } else {
      puts "ERROR | No flash SPI interface defined !"
      exit 1
    }

    set aes256_key 256'h$env(AES256_KEY)
    set hmac256_key 256'h$env(HMAC256_KEY)
    set startcbc128_key 128'h$env(STARTCBC128_KEY)

    open_project $env(VIVADO_PROJECT)
    open_run impl_1
    set_property BITSTREAM.ENCRYPTION.ENCRYPT YES [current_design]
    set_property BITSTREAM.ENCRYPTION.ENCRYPTKEYSELECT BBRAM [current_design]
    set_property BITSTREAM.ENCRYPTION.KEYFILE $env(AES_KEY_FILE) [current_design]
    # set_property BITSTREAM.ENCRYPTION.KEY0 $aes256_key [current_design]
    # set_property BITSTREAM.ENCRYPTION.HKEY $hmac256_key [current_design]
    # set_property BITSTREAM.ENCRYPTION.STARTCBC $startcbc128_key [current_design]
    program_hw_devices -help
    write_bitstream -force $env(VIVADO_BIT_STREAM)
    write_cfgmem  -format bin -size $env(VIVADO_BIN_STREAM_SIZE) -interface ${SPI_INTERFACE} -loadbit "up 0x00000000 $env(VIVADO_BIT_STREAM)" -checksum -force -file $env(VIVADO_BIN_STREAM)
    close_project
}


# generate bitstreams
proc generate_bitstream { args_list } {
    global env
    if {"x4" == $env(FLASH_SPI_INTERFACE)} {
      set SPI_INTERFACE "SPIx4"
    } elseif {"x1" == $env(FLASH_SPI_INTERFACE)} {
      set SPI_INTERFACE "SPIx1"
    } else {
      puts "ERROR | No flash SPI interface defined !"
      exit 1
    }

    open_project $env(VIVADO_PROJECT)
    open_run impl_1
    write_bitstream -force $env(VIVADO_BIT_STREAM)
    write_cfgmem  -format bin -size $env(VIVADO_BIN_STREAM_SIZE) -interface ${SPI_INTERFACE} -loadbit "up 0x00000000 $env(VIVADO_BIT_STREAM)" -checksum -force -file $env(VIVADO_BIN_STREAM)
    close_project
}


# program fpga
proc upload_fpga_vivado { args_list } {
    global env
    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    current_hw_device [get_hw_devices $env(FPGA_DEVICE)]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
    set_property PROBES.FILE {} [get_hw_devices $env(FPGA_DEVICE)]
    set_property FULL_PROBES.FILE {} [get_hw_devices $env(FPGA_DEVICE)]
    set_property PROGRAM.FILE $env(PROGRAM_BIT_STREAM) [get_hw_devices $env(FPGA_DEVICE)]
    program_hw_devices [get_hw_devices $env(FPGA_DEVICE)]
    refresh_hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
    close_hw_target
    disconnect_hw_server [current_hw_server]
    close_hw_manager
}


# program config flash
proc upload_config_flash_vivado { args_list } {
    global env

    # Check if specific jtag targets were applied
    set args_size [llength $args_list]
    if {$args_size > 0} {
        set JTAG_TARGETS $args_list
    } else {
        set JTAG_TARGETS {default}
    }


    try {
        foreach JTAG_TARGET $JTAG_TARGETS {
            puts $JTAG_TARGET
            open_hw_manager
            # connect_hw_server -allow_non_jtag
            connect_hw_server

            if {$args_size > 0} {
                open_hw_target $JTAG_TARGET
            } else {
                open_hw_target
            }

            current_hw_device [get_hw_devices $env(FPGA_DEVICE)]
            refresh_hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
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
            close_hw_target
            disconnect_hw_server [current_hw_server]
            set current_hw_servers [get_hw_servers]
            close_hw_manager
        }
    } on error {msg info} {
        puts "Failed.."
        puts $msg
        puts $info
        close_hw_manager
    }
}


# Program AES key to FPGA
proc program_aes_key_vivado { args_list } {
    global env
    open_hw_manager
    connect_hw_server -allow_non_jtag
    open_hw_target
    set_property PROGRAM.FILE $env(PROGRAM_BIT_STREAM) [get_hw_devices xc7a50t_0]
    current_hw_device [get_hw_devices $env(FPGA_DEVICE)]
    refresh_hw_device -update_hw_probes false [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
    set_property ENCRYPTION.FILE $env(AES_KEY_FILE) [get_property PROGRAM.HW_BITSTREAM [lindex [get_hw_devices] 0]]
    program_hw_devices -key {bbr} [lindex [get_hw_devices] 0]
    refresh_hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]

    # program EFUSE_CNTL:
        # [5] W_EN_B_Cntl=0
        # [4] R_EN_B_User=0
        # [3] R_EN_B_Key=1 - AES key readout disabled
        # [2] W_EN_B_Key_User=1 - AES key & USE_USER write disabled
        # [1] AES_Exclusive=0
        # [0] CFG_AES_Only=0 - program using non-cryped FPGA firmware is not forbidden

    # program_hw_devices -control_efuse {0C} [lindex [get_hw_devices] 0]

    refresh_hw_device [lindex [get_hw_devices $env(FPGA_DEVICE)] 0]
}


# main
# extarct name of task to execute
if {$argc > 0} {
    set task [lindex $argv 0]
    if {!($task in $TASKS)} {
        puts "ERROR | Unsupported task specified: <$task> !"
        exit 1
    } else {
        puts "INFO | Vivado task to execute: <$task>."
    }
} else {
    puts "ERROR | No tclargs with Vivado task specified !"
    exit 1
}

# extract list of args if exists
if {$argc > 1} {
    set args [lrange $argv 1 end]
} else {
    set args {}
}

$task $args
exit 0
