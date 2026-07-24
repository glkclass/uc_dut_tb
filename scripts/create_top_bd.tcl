
################################################################
# This is a generated script based on design: oct640_cu
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2025.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source oct640_cu_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# usb_uart, mipi_csi_axis_streamer, sens_streamer, ddr3_sm_core_frontend, ddr3_sm_core_request_handler, ips_demux, pb_master_clk_mux, dbg_probe_mux_wrapper, mipi_csi_axis_streamer, ffc_ddr3_streamer, ddr3_rw_proxy

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a50tcsg324-2
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name oct640_cu

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:util_ds_buf:2.2\
xilinx.com:inline_hdl:ilconstant:1.0\
xilinx.com:inline_hdl:ilvector_logic:1.0\
xilinx.com:ip:axi_crossbar:2.1\
xilinx.com:ip:axi_quad_spi:3.2\
xilinx.com:ip:axi_uart16550:2.0\
xilinx.com:ip:axi_iic:2.1\
xilinx.com:ip:xadc_wiz:3.3\
xilinx.com:inline_hdl:ilconcat:1.0\
xilinx.com:ip:mipi_csi2_tx_subsystem:2.2\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:axi_intc:4.1\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:lmb_v10:3.0\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
usb_uart\
mipi_csi_axis_streamer\
sens_streamer\
ddr3_sm_core_frontend\
ddr3_sm_core_request_handler\
ips_demux\
pb_master_clk_mux\
dbg_probe_mux_wrapper\
mipi_csi_axis_streamer\
ffc_ddr3_streamer\
ddr3_rw_proxy\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: mblaze_local_memory
proc create_hier_cell_mblaze_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_mblaze_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 D_LMB_M

  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 I_LMB_M


  # Create pins
  create_bd_pin -dir I LMB_Clk
  create_bd_pin -dir I SYS_Rst

  # Create instance: d_lmb, and set properties
  set d_lmb [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 d_lmb ]

  # Create instance: i_lmb, and set properties
  set i_lmb [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 i_lmb ]

  # Create instance: d_lmb_bram_if_cntlr, and set properties
  set d_lmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 d_lmb_bram_if_cntlr ]

  # Create instance: i_lmb_bram_if_cntlr, and set properties
  set i_lmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 i_lmb_bram_if_cntlr ]

  # Create instance: lbm_bram, and set properties
  set lbm_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lbm_bram ]
  set_property -dict [list \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
  ] $lbm_bram


  # Create interface connections
  connect_bd_intf_net -intf_net Conn [get_bd_intf_pins D_LMB_M] [get_bd_intf_pins d_lmb/LMB_M]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins I_LMB_M] [get_bd_intf_pins i_lmb/LMB_M]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins i_lmb/LMB_Sl_0] [get_bd_intf_pins i_lmb_bram_if_cntlr/SLMB]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins d_lmb_bram_if_cntlr/SLMB] [get_bd_intf_pins d_lmb/LMB_Sl_0]
  connect_bd_intf_net -intf_net d_lmb_bram_if_cntlr_0_BRAM_PORT [get_bd_intf_pins d_lmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lbm_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net i_lmb_bram_if_cntlr_0_BRAM_PORT [get_bd_intf_pins i_lmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lbm_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net LMB_Clk_1  [get_bd_pins LMB_Clk] \
  [get_bd_pins d_lmb/LMB_Clk] \
  [get_bd_pins i_lmb/LMB_Clk] \
  [get_bd_pins d_lmb_bram_if_cntlr/LMB_Clk] \
  [get_bd_pins i_lmb_bram_if_cntlr/LMB_Clk]
  connect_bd_net -net SYS_Rst_1  [get_bd_pins SYS_Rst] \
  [get_bd_pins d_lmb/SYS_Rst] \
  [get_bd_pins i_lmb/SYS_Rst] \
  [get_bd_pins i_lmb_bram_if_cntlr/LMB_Rst] \
  [get_bd_pins d_lmb_bram_if_cntlr/LMB_Rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: ddr3_proxy
proc create_hier_cell_ddr3_proxy { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_ddr3_proxy() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_bram_c

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_gpio_1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_gpio_0

  create_bd_intf_pin -mode Master -vlnv Oko:user:dsm_rw_rtl:1.0 ddr3_sm_core


  # Create pins
  create_bd_pin -dir I -type clk sys_clk
  create_bd_pin -dir I -type rst s_axi_aresetn

  # Create instance: ddr3_proxy_if, and set properties
  set ddr3_proxy_if [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 ddr3_proxy_if ]
  set_property -dict [list \
    CONFIG.PROTOCOL {AXI4LITE} \
    CONFIG.SINGLE_PORT_BRAM {1} \
  ] $ddr3_proxy_if


  # Create instance: ddr3_proxy_bram, and set properties
  set ddr3_proxy_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 ddr3_proxy_bram ]
  set_property -dict [list \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Use_RSTA_Pin {false} \
    CONFIG.Write_Depth_A {1024} \
    CONFIG.Write_Width_B {64} \
    CONFIG.use_bram_block {Stand_Alone} \
  ] $ddr3_proxy_bram


  # Create instance: ddr3_proxy_req_rsp, and set properties
  set ddr3_proxy_req_rsp [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 ddr3_proxy_req_rsp ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {2} \
    CONFIG.C_GPIO_WIDTH {2} \
    CONFIG.C_INTERRUPT_PRESENT {0} \
    CONFIG.C_IS_DUAL {1} \
  ] $ddr3_proxy_req_rsp


  # Create instance: ddr3_proxy_txn_info, and set properties
  set ddr3_proxy_txn_info [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 ddr3_proxy_txn_info ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_GPIO2_WIDTH {17} \
    CONFIG.C_GPIO_WIDTH {18} \
    CONFIG.C_IS_DUAL {1} \
  ] $ddr3_proxy_txn_info


  # Create instance: ddr3_rw_proxy, and set properties
  set block_name ddr3_rw_proxy
  set block_cell_name ddr3_rw_proxy
  if { [catch {set ddr3_rw_proxy [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ddr3_rw_proxy eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins ddr3_rw_proxy/ddr3_sm_core] [get_bd_intf_pins ddr3_sm_core]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins ddr3_proxy_req_rsp/S_AXI] [get_bd_intf_pins S_AXI_gpio_1]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins ddr3_proxy_txn_info/S_AXI] [get_bd_intf_pins S_AXI_gpio_0]
  connect_bd_intf_net -intf_net axi_crossbar_M08_AXI [get_bd_intf_pins S_AXI_bram_c] [get_bd_intf_pins ddr3_proxy_if/S_AXI]
  connect_bd_intf_net -intf_net ddr3_proxy_if_BRAM_PORTA [get_bd_intf_pins ddr3_proxy_if/BRAM_PORTA] [get_bd_intf_pins ddr3_rw_proxy/bram_c]
  connect_bd_intf_net -intf_net ddr3_rw_proxy_bram_a [get_bd_intf_pins ddr3_rw_proxy/bram_a] [get_bd_intf_pins ddr3_proxy_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net ddr3_rw_proxy_bram_b [get_bd_intf_pins ddr3_rw_proxy/bram_b] [get_bd_intf_pins ddr3_proxy_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SOC_reset_interconnect_aresetn  [get_bd_pins s_axi_aresetn] \
  [get_bd_pins ddr3_proxy_if/s_axi_aresetn] \
  [get_bd_pins ddr3_proxy_req_rsp/s_axi_aresetn] \
  [get_bd_pins ddr3_proxy_txn_info/s_axi_aresetn]
  connect_bd_net -net aclk_0_1  [get_bd_pins sys_clk] \
  [get_bd_pins ddr3_proxy_if/s_axi_aclk] \
  [get_bd_pins ddr3_proxy_req_rsp/s_axi_aclk] \
  [get_bd_pins ddr3_proxy_txn_info/s_axi_aclk]
  connect_bd_net -net ddr3_proxy_req_rsp_gpio_io_o  [get_bd_pins ddr3_proxy_req_rsp/gpio_io_o] \
  [get_bd_pins ddr3_rw_proxy/ddr3_proxy_req]
  connect_bd_net -net ddr3_proxy_txn_info_gpio2_io_o  [get_bd_pins ddr3_proxy_txn_info/gpio2_io_o] \
  [get_bd_pins ddr3_rw_proxy/ddr3_proxy_txn_info]
  connect_bd_net -net ddr3_proxy_txn_info_gpio_io_o  [get_bd_pins ddr3_proxy_txn_info/gpio_io_o] \
  [get_bd_pins ddr3_rw_proxy/ddr3_proxy_row_base_addr]
  connect_bd_net -net ddr3_rw_proxy_ddr3_proxy_bsy  [get_bd_pins ddr3_rw_proxy/ddr3_proxy_bsy] \
  [get_bd_pins ddr3_proxy_req_rsp/gpio2_io_i]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: core
proc create_hier_cell_core { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_core() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_MDM

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_intc

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DP


  # Create pins
  create_bd_pin -dir I sys_clk
  create_bd_pin -dir O -from 0 -to 0 -type rst interconnect_aresetn
  create_bd_pin -dir O -type intr mdm_intr
  create_bd_pin -dir I -from 1 -to 0 -type intr irq
  create_bd_pin -dir I dcm_locked
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn

  # Create instance: mdm, and set properties
  set mdm [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm ]
  set_property CONFIG.C_USE_UART {1} $mdm


  # Create instance: mblaze_core, and set properties
  set mblaze_core [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 mblaze_core ]
  set_property -dict [list \
    CONFIG.C_AREA_OPTIMIZED {1} \
    CONFIG.C_D_AXI {1} \
    CONFIG.C_ENABLE_CONVERSION {0} \
    CONFIG.C_USE_BARREL {1} \
    CONFIG.C_USE_DIV {1} \
    CONFIG.C_USE_HW_MUL {1} \
    CONFIG.C_USE_INTERRUPT {2} \
    CONFIG.C_USE_REORDER_INSTR {0} \
  ] $mblaze_core


  # Create instance: mblaze_irq_cntr, and set properties
  set mblaze_irq_cntr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 mblaze_irq_cntr ]
  set_property -dict [list \
    CONFIG.C_HAS_FAST {1} \
    CONFIG.C_HAS_ILR {1} \
    CONFIG.C_PROCESSOR_CLK_FREQ_MHZ {50.0} \
    CONFIG.C_S_AXI_ACLK_FREQ_MHZ {50.0} \
  ] $mblaze_irq_cntr


  # Create instance: soc_reset, and set properties
  set soc_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 soc_reset ]

  # Create instance: mblaze_local_memory
  create_hier_cell_mblaze_local_memory $hier_obj mblaze_local_memory

  # Create instance: ilconstant_1, and set properties
  set ilconstant_1 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins mblaze_core/M_AXI_DP] [get_bd_intf_pins M_AXI_DP]
  connect_bd_intf_net -intf_net S_AXI1_1 [get_bd_intf_pins S_AXI_MDM] [get_bd_intf_pins mdm/S_AXI]
  connect_bd_intf_net -intf_net axi_intc_interrupt [get_bd_intf_pins mblaze_core/INTERRUPT] [get_bd_intf_pins mblaze_irq_cntr/interrupt]
  connect_bd_intf_net -intf_net mdm_0_MBDEBUG_0 [get_bd_intf_pins mdm/MBDEBUG_0] [get_bd_intf_pins mblaze_core/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_DLMB [get_bd_intf_pins mblaze_core/DLMB] [get_bd_intf_pins mblaze_local_memory/D_LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ILMB [get_bd_intf_pins mblaze_core/ILMB] [get_bd_intf_pins mblaze_local_memory/I_LMB_M]
  connect_bd_intf_net -intf_net s_axi_1 [get_bd_intf_pins s_axi_intc] [get_bd_intf_pins mblaze_irq_cntr/s_axi]

  # Create port connections
  connect_bd_net -net SOC_reset_interconnect_aresetn  [get_bd_pins soc_reset/interconnect_aresetn] \
  [get_bd_pins interconnect_aresetn] \
  [get_bd_pins mblaze_irq_cntr/s_axi_aresetn] \
  [get_bd_pins mdm/S_AXI_ARESETN]
  connect_bd_net -net SOC_reset_peripheral_aresetn  [get_bd_pins soc_reset/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn]
  connect_bd_net -net clk_store_bd_clk_out2  [get_bd_pins sys_clk] \
  [get_bd_pins mblaze_local_memory/LMB_Clk] \
  [get_bd_pins mblaze_core/Clk] \
  [get_bd_pins mblaze_irq_cntr/s_axi_aclk] \
  [get_bd_pins soc_reset/slowest_sync_clk] \
  [get_bd_pins mdm/S_AXI_ACLK] \
  [get_bd_pins mblaze_irq_cntr/processor_clk]
  connect_bd_net -net dcm_locked_1  [get_bd_pins dcm_locked] \
  [get_bd_pins soc_reset/dcm_locked]
  connect_bd_net -net ilconstant_1_dout  [get_bd_pins ilconstant_1/dout] \
  [get_bd_pins soc_reset/ext_reset_in]
  connect_bd_net -net intr_1  [get_bd_pins irq] \
  [get_bd_pins mblaze_irq_cntr/intr]
  connect_bd_net -net mdm_0_Debug_SYS_Rst  [get_bd_pins mdm/Debug_SYS_Rst] \
  [get_bd_pins soc_reset/mb_debug_sys_rst]
  connect_bd_net -net mdm_0_Interrupt  [get_bd_pins mdm/Interrupt] \
  [get_bd_pins mdm_intr]
  connect_bd_net -net proc_sys_reset_0_mb_reset  [get_bd_pins soc_reset/mb_reset] \
  [get_bd_pins mblaze_local_memory/SYS_Rst] \
  [get_bd_pins mblaze_core/Reset] \
  [get_bd_pins mblaze_irq_cntr/processor_rst]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gpio
proc create_hier_cell_gpio { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_gpio() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI


  # Create pins
  create_bd_pin -dir I -type clk sys_clk
  create_bd_pin -dir I -type rst sys_aresetn
  create_bd_pin -dir I -from 25 -to 0 bba
  create_bd_pin -dir O -from 17 -to 0 coeff_table_ddr3_base_addr
  create_bd_pin -dir I -from 7 -to 0 ipst
  create_bd_pin -dir I -from 31 -to 0 image_frame_number
  create_bd_pin -dir I -from 31 -to 0 dbg_probe_0_mc_in
  create_bd_pin -dir I -from 31 -to 0 dbg_probe_1_mc_in
  create_bd_pin -dir O -from 31 -to 0 dbg_probe_0_mc_out
  create_bd_pin -dir O -from 31 -to 0 dbg_probe_1_mc_out
  create_bd_pin -dir O -from 31 -to 0 ips

  # Create instance: coeff_table_base_addr, and set properties
  set coeff_table_base_addr [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 coeff_table_base_addr ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {18} \
  ] $coeff_table_base_addr


  # Create instance: axi_crossbar, and set properties
  set axi_crossbar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar ]
  set_property CONFIG.NUM_MI {5} $axi_crossbar


  # Create instance: dbg_probe_mc_in, and set properties
  set dbg_probe_mc_in [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 dbg_probe_mc_in ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_IS_DUAL {1} \
  ] $dbg_probe_mc_in


  # Create instance: ips, and set properties
  set ips [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 ips ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO2_WIDTH {8} \
    CONFIG.C_GPIO_WIDTH {32} \
    CONFIG.C_INTERRUPT_PRESENT {0} \
    CONFIG.C_IS_DUAL {1} \
  ] $ips


  # Create instance: bba_ifn, and set properties
  set bba_ifn [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 bba_ifn ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {1} \
    CONFIG.C_ALL_INPUTS_2 {1} \
    CONFIG.C_GPIO_WIDTH {26} \
    CONFIG.C_IS_DUAL {1} \
  ] $bba_ifn


  # Create instance: dbg_probe_mc_out, and set properties
  set dbg_probe_mc_out [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 dbg_probe_mc_out ]
  set_property -dict [list \
    CONFIG.C_ALL_INPUTS {0} \
    CONFIG.C_ALL_INPUTS_2 {0} \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_ALL_OUTPUTS_2 {1} \
    CONFIG.C_IS_DUAL {1} \
  ] $dbg_probe_mc_out


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_1 [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_crossbar/S00_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_M00_AXI [get_bd_intf_pins axi_crossbar/M00_AXI] [get_bd_intf_pins dbg_probe_mc_in/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_M01_AXI [get_bd_intf_pins axi_crossbar/M01_AXI] [get_bd_intf_pins dbg_probe_mc_out/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_M02_AXI [get_bd_intf_pins axi_crossbar/M02_AXI] [get_bd_intf_pins coeff_table_base_addr/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_M03_AXI [get_bd_intf_pins axi_crossbar/M03_AXI] [get_bd_intf_pins bba_ifn/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_M04_AXI [get_bd_intf_pins ips/S_AXI] [get_bd_intf_pins axi_crossbar/M04_AXI]

  # Create port connections
  connect_bd_net -net bba_1  [get_bd_pins bba] \
  [get_bd_pins bba_ifn/gpio_io_i]
  connect_bd_net -net coeff_table_base_addr_gpio_io_o  [get_bd_pins coeff_table_base_addr/gpio_io_o] \
  [get_bd_pins coeff_table_ddr3_base_addr]
  connect_bd_net -net dbg_probe_mc_out_gpio2_io_o  [get_bd_pins dbg_probe_mc_out/gpio2_io_o] \
  [get_bd_pins dbg_probe_1_mc_out]
  connect_bd_net -net dbg_probe_mc_out_gpio_io_o  [get_bd_pins dbg_probe_mc_out/gpio_io_o] \
  [get_bd_pins dbg_probe_0_mc_out]
  connect_bd_net -net gpio2_io_i_0_1  [get_bd_pins image_frame_number] \
  [get_bd_pins bba_ifn/gpio2_io_i]
  connect_bd_net -net gpio2_io_i_0_2  [get_bd_pins dbg_probe_1_mc_in] \
  [get_bd_pins dbg_probe_mc_in/gpio2_io_i]
  connect_bd_net -net gpio_io_i_0_1  [get_bd_pins dbg_probe_0_mc_in] \
  [get_bd_pins dbg_probe_mc_in/gpio_io_i]
  connect_bd_net -net ips_gpio_io_o  [get_bd_pins ips/gpio_io_o] \
  [get_bd_pins ips]
  connect_bd_net -net ipst_1  [get_bd_pins ipst] \
  [get_bd_pins ips/gpio2_io_i]
  connect_bd_net -net s_axi_aresetn_1  [get_bd_pins sys_aresetn] \
  [get_bd_pins axi_crossbar/aresetn] \
  [get_bd_pins coeff_table_base_addr/s_axi_aresetn] \
  [get_bd_pins ips/s_axi_aresetn] \
  [get_bd_pins bba_ifn/s_axi_aresetn] \
  [get_bd_pins dbg_probe_mc_in/s_axi_aresetn] \
  [get_bd_pins dbg_probe_mc_out/s_axi_aresetn]
  connect_bd_net -net sys_clk_1  [get_bd_pins sys_clk] \
  [get_bd_pins axi_crossbar/aclk] \
  [get_bd_pins coeff_table_base_addr/s_axi_aclk] \
  [get_bd_pins dbg_probe_mc_in/s_axi_aclk] \
  [get_bd_pins bba_ifn/s_axi_aclk] \
  [get_bd_pins ips/s_axi_aclk] \
  [get_bd_pins dbg_probe_mc_out/s_axi_aclk]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: image_processing_pipeline
proc create_hier_cell_image_processing_pipeline { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_image_processing_pipeline() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv Oko:user:ddr3_rtl:1.0 ddr3

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 mipi_csi_axis

  create_bd_intf_pin -mode Slave -vlnv Oko:user:sens_rtl:1.0 proxy_board

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 uvc_axis

  create_bd_intf_pin -mode Slave -vlnv Oko:user:dsm_rw_rtl:1.0 core_sys_rw_port


  # Create pins
  create_bd_pin -dir I -type clk sys_135_clk
  create_bd_pin -dir I -type clk sys_clk
  create_bd_pin -dir I -type clk ddr_270_clk
  create_bd_pin -dir I -type clk ddr_clk
  create_bd_pin -dir I -type clk ref_clk
  create_bd_pin -dir I -type rst sys_rst_n
  create_bd_pin -dir I trigger
  create_bd_pin -dir I -from 17 -to 0 coeff_table_ddr3_base_addr
  create_bd_pin -dir I -type clk proxy_board_pixel_clk
  create_bd_pin -dir O -from 25 -to 0 bba
  create_bd_pin -dir O -from 7 -to 0 ipst
  create_bd_pin -dir O -type clk pb_master_clk
  create_bd_pin -dir I -type clk fr30_clk
  create_bd_pin -dir I -type clk fr60_clk
  create_bd_pin -dir O o_led
  create_bd_pin -dir O -type rst ips_mipi_csi_phy_rst
  create_bd_pin -dir O -from 31 -to 0 sens_img_frame_number
  create_bd_pin -dir O -from 31 -to 0 dbg_probe_mc_in_0
  create_bd_pin -dir O -from 31 -to 0 dbg_probe_mc_in_2
  create_bd_pin -dir I -from 0 -to 0 i_superviser
  create_bd_pin -dir I -from 31 -to 0 ips

  # Create instance: mipi_csi_axis_streamer, and set properties
  set block_name mipi_csi_axis_streamer
  set block_cell_name mipi_csi_axis_streamer
  if { [catch {set mipi_csi_axis_streamer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mipi_csi_axis_streamer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_sens_img:mipi_csi_axis} \
 ] [get_bd_pins /image_processing_pipeline/mipi_csi_axis_streamer/i_sys_clk]

  # Create instance: sens_streamer, and set properties
  set block_name sens_streamer
  set block_cell_name sens_streamer
  if { [catch {set sens_streamer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sens_streamer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.RAM_DATA_W {16} $sens_streamer


  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_sens} \
 ] [get_bd_pins /image_processing_pipeline/sens_streamer/i_sensor_pixel_clk]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {rd_coeff_req:user_sens_img} \
 ] [get_bd_pins /image_processing_pipeline/sens_streamer/i_sys_clk]

  # Create instance: ddr3_sm_core_frontend, and set properties
  set block_name ddr3_sm_core_frontend
  set block_cell_name ddr3_sm_core_frontend
  if { [catch {set ddr3_sm_core_frontend [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ddr3_sm_core_frontend eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {rd_port:wr_port:rd_port_bram:wr_port_bram} \
 ] [get_bd_pins /image_processing_pipeline/ddr3_sm_core_frontend/i_core_clk]

  # Create instance: ilconstant_0, and set properties
  set ilconstant_0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 ilconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $ilconstant_0


  # Create instance: ddr3_sm_core_request_handler, and set properties
  set block_name ddr3_sm_core_request_handler
  set block_cell_name ddr3_sm_core_request_handler
  if { [catch {set ddr3_sm_core_request_handler [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ddr3_sm_core_request_handler eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {sm_core_rd_port_bram:sm_core_wr_port_bram:ddr3_proxy_bram_mntr:core_sys_rw_port:rd_coeff_req:rd_coeff_bram:core_sys_rw_port_bram:sm_core_rd_port:sm_core_wr_port} \
 ] [get_bd_pins /image_processing_pipeline/ddr3_sm_core_request_handler/i_sys_clk]

  # Create instance: ipst_mux, and set properties
  set ipst_mux [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 ipst_mux ]
  set_property CONFIG.NUM_PORTS {8} $ipst_mux


  # Create instance: ips_demux, and set properties
  set block_name ips_demux
  set block_cell_name ips_demux
  if { [catch {set ips_demux [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ips_demux eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: pb_master_clk_mux, and set properties
  set block_name pb_master_clk_mux
  set block_cell_name pb_master_clk_mux
  if { [catch {set pb_master_clk_mux [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $pb_master_clk_mux eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: dbg_probe_mux_wrapper, and set properties
  set block_name dbg_probe_mux_wrapper
  set block_cell_name dbg_probe_mux_wrapper
  if { [catch {set dbg_probe_mux_wrapper [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dbg_probe_mux_wrapper eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: uvc_axis_streamer, and set properties
  set block_name mipi_csi_axis_streamer
  set block_cell_name uvc_axis_streamer
  if { [catch {set uvc_axis_streamer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $uvc_axis_streamer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {user_sens_img:mipi_csi_axis} \
 ] [get_bd_pins /image_processing_pipeline/uvc_axis_streamer/i_sys_clk]

  # Create instance: ffc_ddr3_streamer, and set properties
  set block_name ffc_ddr3_streamer
  set block_cell_name ffc_ddr3_streamer
  if { [catch {set ffc_ddr3_streamer [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ffc_ddr3_streamer eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins uvc_axis_streamer/mipi_csi_axis] [get_bd_intf_pins uvc_axis]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins ddr3_sm_core_request_handler/rw_port_0] [get_bd_intf_pins core_sys_rw_port]
  connect_bd_intf_net -intf_net ddr3_frontend_ddr3_0 [get_bd_intf_pins ddr3] [get_bd_intf_pins ddr3_sm_core_frontend/ddr3]
  connect_bd_intf_net -intf_net ddr3_sm_core_request_handler_sm_core_rw_port [get_bd_intf_pins ddr3_sm_core_request_handler/sm_core_rw_port] [get_bd_intf_pins ddr3_sm_core_frontend/rw_port]
  connect_bd_intf_net -intf_net ffc_ddr3_streamer_0_wr_img_frame [get_bd_intf_pins ffc_ddr3_streamer/wr_img_frame] [get_bd_intf_pins ddr3_sm_core_request_handler/wr_port_0]
  connect_bd_intf_net -intf_net image_processing_pipeline_mipi_csi_axis [get_bd_intf_pins mipi_csi_axis] [get_bd_intf_pins mipi_csi_axis_streamer/mipi_csi_axis]
  connect_bd_intf_net -intf_net proxy_board_1 [get_bd_intf_pins proxy_board] [get_bd_intf_pins sens_streamer/user_sens]
  connect_bd_intf_net -intf_net sens_streamer_ffc [get_bd_intf_pins sens_streamer/ffc] [get_bd_intf_pins ffc_ddr3_streamer/ffc]
  connect_bd_intf_net -intf_net sens_streamer_mipi_csi [get_bd_intf_pins mipi_csi_axis_streamer/user_sensor_image] [get_bd_intf_pins sens_streamer/mipi_csi]
  connect_bd_intf_net -intf_net sens_streamer_rd_coeff [get_bd_intf_pins sens_streamer/rd_coeff] [get_bd_intf_pins ddr3_sm_core_request_handler/rd_port_0]
  connect_bd_intf_net -intf_net sens_streamer_rd_dp_mask [get_bd_intf_pins sens_streamer/rd_dp_mask] [get_bd_intf_pins ddr3_sm_core_request_handler/rd_port_1]
  connect_bd_intf_net -intf_net sens_streamer_uvc [get_bd_intf_pins uvc_axis_streamer/user_sensor_image] [get_bd_intf_pins sens_streamer/uvc]

  # Create port connections
  connect_bd_net -net In2_0_1  [get_bd_pins i_superviser] \
  [get_bd_pins ipst_mux/In2]
  connect_bd_net -net clk_store_sys_clk_out1  [get_bd_pins ref_clk] \
  [get_bd_pins ddr3_sm_core_frontend/i_ref_clk]
  connect_bd_net -net clk_store_sys_clk_out2  [get_bd_pins sys_clk] \
  [get_bd_pins dbg_probe_mux_wrapper/clk] \
  [get_bd_pins ddr3_sm_core_frontend/i_core_clk] \
  [get_bd_pins ddr3_sm_core_request_handler/i_sys_clk] \
  [get_bd_pins ffc_ddr3_streamer/i_sys_clk] \
  [get_bd_pins mipi_csi_axis_streamer/i_sys_clk] \
  [get_bd_pins sens_streamer/i_sys_clk] \
  [get_bd_pins uvc_axis_streamer/i_sys_clk]
  connect_bd_net -net clk_store_sys_clk_out3  [get_bd_pins sys_135_clk] \
  [get_bd_pins ddr3_sm_core_frontend/i_core_135_clk]
  connect_bd_net -net clk_store_sys_clk_out4  [get_bd_pins ddr_clk] \
  [get_bd_pins ddr3_sm_core_frontend/i_ddr_clk]
  connect_bd_net -net clk_store_sys_clk_out5  [get_bd_pins ddr_270_clk] \
  [get_bd_pins ddr3_sm_core_frontend/i_ddr_270_clk]
  connect_bd_net -net core_sys_peripheral_aresetn  [get_bd_pins sys_rst_n] \
  [get_bd_pins ddr3_sm_core_frontend/i_rst_n] \
  [get_bd_pins ddr3_sm_core_request_handler/i_rst_n] \
  [get_bd_pins ffc_ddr3_streamer/i_sys_rst_n] \
  [get_bd_pins mipi_csi_axis_streamer/i_rst_n] \
  [get_bd_pins sens_streamer/i_sys_rst_n] \
  [get_bd_pins uvc_axis_streamer/i_rst_n]
  connect_bd_net -net dbg_probe_mux_wrapper_dbg_probe_mc_in_0  [get_bd_pins dbg_probe_mux_wrapper/dbg_probe_mc_in_0] \
  [get_bd_pins dbg_probe_mc_in_0]
  connect_bd_net -net dbg_probe_mux_wrapper_dbg_probe_mc_in_2  [get_bd_pins dbg_probe_mux_wrapper/dbg_probe_mc_in_2] \
  [get_bd_pins dbg_probe_mc_in_2]
  connect_bd_net -net i_fr30_clk_0_1  [get_bd_pins fr30_clk] \
  [get_bd_pins pb_master_clk_mux/i_fr30_clk]
  connect_bd_net -net i_fr60_clk_0_1  [get_bd_pins fr60_clk] \
  [get_bd_pins pb_master_clk_mux/i_fr60_clk]
  connect_bd_net -net i_ips_0_1  [get_bd_pins ips] \
  [get_bd_pins ips_demux/i_ips]
  connect_bd_net -net ilconstant_0_dout_1  [get_bd_pins ilconstant_0/dout] \
  [get_bd_pins ddr3_sm_core_frontend/i_power_down]
  connect_bd_net -net ilconstant_1_dout  [get_bd_pins coeff_table_ddr3_base_addr] \
  [get_bd_pins sens_streamer/i_coeff_table_row_base_addr]
  connect_bd_net -net ips_demux_o_ffc_start  [get_bd_pins ips_demux/o_ffc_start] \
  [get_bd_pins ffc_ddr3_streamer/i_ffc_start]
  connect_bd_net -net ips_demux_o_ips_dpm_en  [get_bd_pins ips_demux/o_ips_dpm_en] \
  [get_bd_pins sens_streamer/i_ips_dpm_en]
  connect_bd_net -net ips_demux_o_ips_fps  [get_bd_pins ips_demux/o_ips_fps] \
  [get_bd_pins pb_master_clk_mux/i_ips_fps]
  connect_bd_net -net ips_demux_o_ips_led_en  [get_bd_pins ips_demux/o_ips_led_en] \
  [get_bd_pins sens_streamer/i_activity_led_en]
  connect_bd_net -net ips_demux_o_ips_mipi_csi_data_format  [get_bd_pins ips_demux/o_ips_mipi_csi_data_format] \
  [get_bd_pins mipi_csi_axis_streamer/i_ips_mipi_csi_data_format]
  connect_bd_net -net ips_demux_o_ips_mipi_csi_driver_rst  [get_bd_pins ips_demux/o_ips_mipi_csi_phy_rst] \
  [get_bd_pins ips_mipi_csi_phy_rst]
  connect_bd_net -net ips_demux_o_ips_mipi_csi_ppm  [get_bd_pins ips_demux/o_ips_mipi_csi_ppm] \
  [get_bd_pins sens_streamer/i_ips_mipi_csi_ppm]
  connect_bd_net -net ips_demux_o_ips_mipi_csi_stream_en  [get_bd_pins ips_demux/o_ips_mipi_csi_stream_en] \
  [get_bd_pins mipi_csi_axis_streamer/i_enable]
  connect_bd_net -net ips_demux_o_ips_soft_trigger  [get_bd_pins ips_demux/o_ips_soft_trigger] \
  [get_bd_pins sens_streamer/i_soft_trigger]
  connect_bd_net -net ips_demux_o_ips_trigger_en  [get_bd_pins ips_demux/o_ips_trigger_en] \
  [get_bd_pins sens_streamer/i_ips_trigger_en]
  connect_bd_net -net ips_demux_o_ips_uvc_data_format  [get_bd_pins ips_demux/o_ips_uvc_data_format] \
  [get_bd_pins uvc_axis_streamer/i_ips_mipi_csi_data_format]
  connect_bd_net -net ips_demux_o_ips_uvc_ppm  [get_bd_pins ips_demux/o_ips_uvc_ppm] \
  [get_bd_pins sens_streamer/i_ips_uvc_ppm]
  connect_bd_net -net ips_demux_o_ips_uvc_stream_en  [get_bd_pins ips_demux/o_ips_uvc_stream_en] \
  [get_bd_pins uvc_axis_streamer/i_enable]
  connect_bd_net -net ipst_dout  [get_bd_pins ipst_mux/dout] \
  [get_bd_pins ipst]
  connect_bd_net -net pb_master_clk_mux_0_o_pb_master_clk  [get_bd_pins pb_master_clk_mux/o_pb_master_clk] \
  [get_bd_pins pb_master_clk] \
  [get_bd_pins sens_streamer/i_pb_master_clk]
  connect_bd_net -net proxy_board_pixel_clk_1  [get_bd_pins proxy_board_pixel_clk] \
  [get_bd_pins sens_streamer/i_sensor_pixel_clk]
  connect_bd_net -net sens_streamer_o_activity_led  [get_bd_pins sens_streamer/o_activity_led] \
  [get_bd_pins o_led]
  connect_bd_net -net sens_streamer_o_bbl_acc  [get_bd_pins sens_streamer/o_bbl_acc] \
  [get_bd_pins bba]
  connect_bd_net -net sens_streamer_o_dbg_probe_0  [get_bd_pins sens_streamer/o_dbg_probe_0] \
  [get_bd_pins dbg_probe_mux_wrapper/dbg_probe_rtl_out_0]
  connect_bd_net -net sens_streamer_o_dbg_probe_2  [get_bd_pins sens_streamer/o_dbg_probe_2] \
  [get_bd_pins dbg_probe_mux_wrapper/dbg_probe_rtl_out_2]
  connect_bd_net -net sens_streamer_o_sensor_pixel_clk_active  [get_bd_pins sens_streamer/o_sensor_pixel_clk_status] \
  [get_bd_pins ipst_mux/In0]
  connect_bd_net -net sens_streamer_o_trigger_active  [get_bd_pins sens_streamer/o_trigger_status] \
  [get_bd_pins ipst_mux/In1] \
  [get_bd_pins ipst_mux/In3] \
  [get_bd_pins ipst_mux/In4] \
  [get_bd_pins ipst_mux/In5] \
  [get_bd_pins ipst_mux/In6] \
  [get_bd_pins ipst_mux/In7]
  connect_bd_net -net sens_streamer_sens_img_frame_number  [get_bd_pins sens_streamer/o_sens_img_frame_number] \
  [get_bd_pins sens_img_frame_number]
  connect_bd_net -net trigger_1  [get_bd_pins trigger] \
  [get_bd_pins sens_streamer/i_hard_trigger]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: core_sys
proc create_hier_cell_core_sys { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_core_sys() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 config_flash_spi

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 uart

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 mipi_csi_iic

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_csi_phy

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 mipi_csi_s_axis

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 proxy_board_spi

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:bram_rtl:1.0 ddr3_proxy_rw_bram

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:startup_rtl:1.0 STARTUP_IO_S

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_1

  create_bd_intf_pin -mode Master -vlnv Oko:user:dsm_rw_rtl:1.0 ddr3_rw_port


  # Create pins
  create_bd_pin -dir I -type clk sys_clk
  create_bd_pin -dir I -type clk mipi_csi_dphy_clk_200M
  create_bd_pin -dir I dcm_locked
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir I -from 25 -to 0 bba
  create_bd_pin -dir O -from 17 -to 0 coeff_table_ddr3_base_addr_0
  create_bd_pin -dir I -from 7 -to 0 ipst
  create_bd_pin -dir I -from 0 -to 0 superviser
  create_bd_pin -dir I -from 31 -to 0 image_frame_number
  create_bd_pin -dir I -from 31 -to 0 dbg_probe_0_mc_in
  create_bd_pin -dir I -from 31 -to 0 dbg_probe_1_mc_in
  create_bd_pin -dir I -type clk s_axi_aclk_0
  create_bd_pin -dir I -type rst s_axi_aresetn_0
  create_bd_pin -dir O -from 31 -to 0 ips

  # Create instance: axi_crossbar, and set properties
  set axi_crossbar [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_crossbar:2.1 axi_crossbar ]
  set_property CONFIG.NUM_MI {12} $axi_crossbar


  # Create instance: config_flash_spi, and set properties
  set config_flash_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 config_flash_spi ]
  set_property -dict [list \
    CONFIG.C_FIFO_DEPTH {256} \
    CONFIG.C_SHARED_STARTUP {1} \
    CONFIG.C_SPI_MEMORY {2} \
    CONFIG.C_SPI_MODE {2} \
  ] $config_flash_spi


  # Create instance: uart, and set properties
  set uart [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 uart ]

  # Create instance: mipi_csi_iic, and set properties
  set mipi_csi_iic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.1 mipi_csi_iic ]

  # Create instance: xadc, and set properties
  set xadc [ create_bd_cell -type ip -vlnv xilinx.com:ip:xadc_wiz:3.3 xadc ]
  set_property -dict [list \
    CONFIG.ADC_CONVERSION_RATE {40} \
    CONFIG.AVERAGE_ENABLE_TEMPERATURE {false} \
    CONFIG.AVERAGE_ENABLE_VP_VN {false} \
    CONFIG.CHANNEL_AVERAGING {256} \
    CONFIG.CHANNEL_ENABLE_CALIBRATION {false} \
    CONFIG.CHANNEL_ENABLE_TEMPERATURE {false} \
    CONFIG.CHANNEL_ENABLE_VP_VN {false} \
    CONFIG.DCLK_FREQUENCY {76} \
    CONFIG.ENABLE_EXTERNAL_MUX {false} \
    CONFIG.ENABLE_TEMP_BUS {false} \
    CONFIG.EXTERNAL_MUX_CHANNEL {VP_VN} \
    CONFIG.OT_ALARM {false} \
    CONFIG.SEQUENCER_MODE {Off} \
    CONFIG.SINGLE_CHANNEL_ACQUISITION_TIME {false} \
    CONFIG.SINGLE_CHANNEL_SELECTION {TEMPERATURE} \
    CONFIG.USER_TEMP_ALARM {false} \
    CONFIG.VCCAUX_ALARM {false} \
    CONFIG.VCCINT_ALARM {false} \
    CONFIG.XADC_STARUP_SELECTION {single_channel} \
  ] $xadc


  # Create instance: irqs, and set properties
  set irqs [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconcat:1.0 irqs ]
  set_property CONFIG.NUM_PORTS {2} $irqs


  # Create instance: proxy_board_spi, and set properties
  set proxy_board_spi [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 proxy_board_spi ]
  set_property -dict [list \
    CONFIG.C_NUM_TRANSFER_BITS {16} \
    CONFIG.C_USE_STARTUP {0} \
    CONFIG.FIFO_INCLUDED {0} \
    CONFIG.Multiples16 {3} \
  ] $proxy_board_spi


  # Create instance: gpio
  create_hier_cell_gpio $hier_obj gpio

  # Create instance: core
  create_hier_cell_core $hier_obj core

  # Create instance: mipi_csi_tx, and set properties
  set mipi_csi_tx [ create_bd_cell -type ip -vlnv xilinx.com:ip:mipi_csi2_tx_subsystem:2.2 mipi_csi_tx ]
  set_property -dict [list \
    CONFIG.C_CSI_CRC_ENABLE {true} \
    CONFIG.C_CSI_EN_ACTIVELANES {true} \
    CONFIG.C_CSI_LANES {4} \
    CONFIG.C_CSI_LINE_BUFR_DEPTH {1024} \
    CONFIG.C_CSI_MAX_BPC {16} \
    CONFIG.C_CSI_PIXEL_MODE {4} \
    CONFIG.C_DPHY_EN_REG_IF {true} \
    CONFIG.C_EN_7S_LINERATE_CHECK {true} \
    CONFIG.C_EN_HS_OBUFTDS {true} \
    CONFIG.C_HS_LINE_RATE {200} \
    CONFIG.SupportLevel {1} \
  ] $mipi_csi_tx


  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.ADDR_WIDTH {13} \
 ] [get_bd_intf_pins /core_sys/mipi_csi_tx/s_axi]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {s_axi:s_axis} \
   CONFIG.ASSOCIATED_RESET {s_axis_aresetn} \
 ] [get_bd_pins /core_sys/mipi_csi_tx/s_axis_aclk]

  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] [get_bd_pins /core_sys/mipi_csi_tx/s_axis_aresetn]

  # Create instance: superviser_inv, and set properties
  set superviser_inv [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 superviser_inv ]
  set_property -dict [list \
    CONFIG.C_OPERATION {not} \
    CONFIG.C_SIZE {1} \
  ] $superviser_inv


  # Create instance: ddr3_proxy
  create_hier_cell_ddr3_proxy $hier_obj ddr3_proxy

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins config_flash_spi/STARTUP_IO_S] [get_bd_intf_pins STARTUP_IO_S]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins ddr3_proxy/ddr3_sm_core] [get_bd_intf_pins ddr3_rw_port]
  connect_bd_intf_net -intf_net axi_crossbar_0_M00_AXI [get_bd_intf_pins axi_crossbar/M00_AXI] [get_bd_intf_pins core/S_AXI_MDM]
  connect_bd_intf_net -intf_net axi_crossbar_0_M01_AXI [get_bd_intf_pins axi_crossbar/M01_AXI] [get_bd_intf_pins core/s_axi_intc]
  connect_bd_intf_net -intf_net axi_crossbar_0_M04_AXI [get_bd_intf_pins axi_crossbar/M04_AXI] [get_bd_intf_pins config_flash_spi/AXI_LITE]
  connect_bd_intf_net -intf_net axi_crossbar_0_M06_AXI [get_bd_intf_pins axi_crossbar/M06_AXI] [get_bd_intf_pins gpio/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M07_AXI [get_bd_intf_pins axi_crossbar/M07_AXI] [get_bd_intf_pins mipi_csi_iic/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_0_M09_AXI [get_bd_intf_pins axi_crossbar/M09_AXI] [get_bd_intf_pins proxy_board_spi/AXI_LITE]
  connect_bd_intf_net -intf_net axi_crossbar_M02_AXI [get_bd_intf_pins axi_crossbar/M02_AXI] [get_bd_intf_pins xadc/s_axi_lite]
  connect_bd_intf_net -intf_net axi_crossbar_M03_AXI [get_bd_intf_pins axi_crossbar/M03_AXI] [get_bd_intf_pins mipi_csi_tx/s_axi]
  connect_bd_intf_net -intf_net axi_crossbar_M05_AXI [get_bd_intf_pins axi_crossbar/M05_AXI] [get_bd_intf_pins uart/S_AXI]
  connect_bd_intf_net -intf_net axi_crossbar_M08_AXI [get_bd_intf_pins axi_crossbar/M08_AXI] [get_bd_intf_pins ddr3_proxy/S_AXI_bram_c]
  connect_bd_intf_net -intf_net axi_crossbar_M10_AXI [get_bd_intf_pins axi_crossbar/M10_AXI] [get_bd_intf_pins ddr3_proxy/S_AXI_gpio_1]
  connect_bd_intf_net -intf_net axi_crossbar_M11_AXI [get_bd_intf_pins axi_crossbar/M11_AXI] [get_bd_intf_pins ddr3_proxy/S_AXI_gpio_0]
  connect_bd_intf_net -intf_net core_M_AXI_DP [get_bd_intf_pins core/M_AXI_DP] [get_bd_intf_pins axi_crossbar/S00_AXI]
  connect_bd_intf_net -intf_net mipi_csi_s_axis_1 [get_bd_intf_pins mipi_csi_s_axis] [get_bd_intf_pins mipi_csi_tx/s_axis]
  connect_bd_intf_net -intf_net mipi_csi_tx_mipi_phy_if [get_bd_intf_pins mipi_csi_tx/mipi_phy_if] [get_bd_intf_pins mipi_csi_phy]
  connect_bd_intf_net -intf_net perith_iic_rtl_0 [get_bd_intf_pins mipi_csi_iic] [get_bd_intf_pins mipi_csi_iic/IIC]
  connect_bd_intf_net -intf_net perith_spi_rtl_0 [get_bd_intf_pins config_flash_spi] [get_bd_intf_pins config_flash_spi/SPI_0]
  connect_bd_intf_net -intf_net perith_spi_rtl_1 [get_bd_intf_pins proxy_board_spi] [get_bd_intf_pins proxy_board_spi/SPI_0]
  connect_bd_intf_net -intf_net perith_uart_rtl_0 [get_bd_intf_pins uart] [get_bd_intf_pins uart/UART]

  # Create port connections
  connect_bd_net -net SOC_reset_interconnect_aresetn  [get_bd_pins core/interconnect_aresetn] \
  [get_bd_pins xadc/s_axi_aresetn] \
  [get_bd_pins mipi_csi_iic/s_axi_aresetn] \
  [get_bd_pins proxy_board_spi/s_axi_aresetn] \
  [get_bd_pins config_flash_spi/s_axi_aresetn] \
  [get_bd_pins gpio/sys_aresetn] \
  [get_bd_pins uart/s_axi_aresetn] \
  [get_bd_pins axi_crossbar/aresetn] \
  [get_bd_pins mipi_csi_tx/s_axis_aresetn] \
  [get_bd_pins ddr3_proxy/s_axi_aresetn]
  connect_bd_net -net aclk_0_1  [get_bd_pins sys_clk] \
  [get_bd_pins config_flash_spi/s_axi_aclk] \
  [get_bd_pins mipi_csi_iic/s_axi_aclk] \
  [get_bd_pins proxy_board_spi/s_axi_aclk] \
  [get_bd_pins gpio/sys_clk] \
  [get_bd_pins uart/s_axi_aclk] \
  [get_bd_pins config_flash_spi/ext_spi_clk] \
  [get_bd_pins proxy_board_spi/ext_spi_clk] \
  [get_bd_pins xadc/s_axi_aclk] \
  [get_bd_pins core/sys_clk] \
  [get_bd_pins axi_crossbar/aclk] \
  [get_bd_pins mipi_csi_tx/s_axis_aclk] \
  [get_bd_pins ddr3_proxy/sys_clk]
  connect_bd_net -net bba_1  [get_bd_pins bba] \
  [get_bd_pins gpio/bba]
  connect_bd_net -net core_peripheral_aresetn  [get_bd_pins core/peripheral_aresetn] \
  [get_bd_pins peripheral_aresetn]
  connect_bd_net -net dcm_locked_1  [get_bd_pins dcm_locked] \
  [get_bd_pins core/dcm_locked]
  connect_bd_net -net gpio2_io_i_0_1  [get_bd_pins image_frame_number] \
  [get_bd_pins gpio/image_frame_number]
  connect_bd_net -net gpio2_io_i_0_2  [get_bd_pins dbg_probe_1_mc_in] \
  [get_bd_pins gpio/dbg_probe_1_mc_in]
  connect_bd_net -net gpio_coeff_table_ddr3_base_addr  [get_bd_pins gpio/coeff_table_ddr3_base_addr] \
  [get_bd_pins coeff_table_ddr3_base_addr_0]
  connect_bd_net -net gpio_gpio_io_o_0  [get_bd_pins gpio/ips] \
  [get_bd_pins ips]
  connect_bd_net -net gpio_io_i_0_1  [get_bd_pins dbg_probe_0_mc_in] \
  [get_bd_pins gpio/dbg_probe_0_mc_in]
  connect_bd_net -net ipst_1  [get_bd_pins ipst] \
  [get_bd_pins gpio/ipst]
  connect_bd_net -net irqs_dout  [get_bd_pins irqs/dout] \
  [get_bd_pins core/irq]
  connect_bd_net -net mipi_csi_dphy_clk_200M_1  [get_bd_pins mipi_csi_dphy_clk_200M] \
  [get_bd_pins mipi_csi_tx/dphy_clk_200M]
  connect_bd_net -net mipi_csi_iic_iic2intc_irpt  [get_bd_pins mipi_csi_iic/iic2intc_irpt] \
  [get_bd_pins irqs/In1]
  connect_bd_net -net superviser_1  [get_bd_pins superviser] \
  [get_bd_pins superviser_inv/Op1]
  connect_bd_net -net superviser_inv_Res  [get_bd_pins superviser_inv/Res] \
  [get_bd_pins irqs/In0]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set config_flash_spi [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 config_flash_spi ]

  set mipi_csi_phy [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:mipi_phy_rtl:1.0 mipi_csi_phy ]

  set mipi_csi_iic [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 mipi_csi_iic ]

  set proxy_board_spi [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:spi_rtl:1.0 proxy_board_spi ]

  set proxy_board [ create_bd_intf_port -mode Slave -vlnv Oko:user:sens_rtl:1.0 proxy_board ]

  set ddr3 [ create_bd_intf_port -mode Master -vlnv Oko:user:ddr3_rtl:1.0 ddr3 ]

  set ulpi [ create_bd_intf_port -mode Slave -vlnv Oko:user:ulpi_rtl:1.0 ulpi ]

  set S_AXI_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {16} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {50000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_0

  set S_AXI_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_1 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {16} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {50000000} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_CACHE {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_PROT {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4LITE} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_1


  # Create ports
  set i_board_clk_100 [ create_bd_port -dir I -type clk -freq_hz 100000000 i_board_clk_100 ]
  set proxy_board_pixel_clk [ create_bd_port -dir I -type clk -freq_hz 20000000 proxy_board_pixel_clk ]
  set trigger [ create_bd_port -dir I trigger ]
  set proxy_board_master_clk [ create_bd_port -dir O -type clk proxy_board_master_clk ]
  set i_superviser [ create_bd_port -dir I -type rst i_superviser ]
  set led [ create_bd_port -dir O -from 0 -to 0 led ]
  set o_mipi_csi_phy_rst_n [ create_bd_port -dir O -type rst o_mipi_csi_phy_rst_n ]
  set s_axi_aclk_0 [ create_bd_port -dir I -type clk -freq_hz 50000000 s_axi_aclk_0 ]
  set s_axi_aresetn_0 [ create_bd_port -dir I -type rst s_axi_aresetn_0 ]

  # Create instance: core_sys
  create_hier_cell_core_sys [current_bd_instance .] core_sys

  # Create instance: clk_store_sys, and set properties
  set clk_store_sys [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_store_sys ]
  set_property -dict [list \
    CONFIG.CLKIN1_JITTER_PS {100.0} \
    CONFIG.CLKOUT1_DRIVES {BUFGCE} \
    CONFIG.CLKOUT1_JITTER {96.573} \
    CONFIG.CLKOUT1_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.CLKOUT2_DRIVES {BUFGCE} \
    CONFIG.CLKOUT2_JITTER {125.063} \
    CONFIG.CLKOUT2_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {50.000} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_DRIVES {BUFGCE} \
    CONFIG.CLKOUT3_JITTER {125.063} \
    CONFIG.CLKOUT3_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {50.000} \
    CONFIG.CLKOUT3_REQUESTED_PHASE {135.000} \
    CONFIG.CLKOUT3_USED {true} \
    CONFIG.CLKOUT4_DRIVES {BUFGCE} \
    CONFIG.CLKOUT4_JITTER {109.471} \
    CONFIG.CLKOUT4_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT4_USED {true} \
    CONFIG.CLKOUT5_DRIVES {BUFGCE} \
    CONFIG.CLKOUT5_JITTER {109.471} \
    CONFIG.CLKOUT5_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT5_REQUESTED_PHASE {270.000} \
    CONFIG.CLKOUT5_USED {true} \
    CONFIG.CLKOUT6_DRIVES {BUFGCE} \
    CONFIG.CLKOUT6_JITTER {132.240} \
    CONFIG.CLKOUT6_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT6_REQUESTED_OUT_FREQ {38.2} \
    CONFIG.CLKOUT6_USED {true} \
    CONFIG.CLKOUT7_DRIVES {BUFGCE} \
    CONFIG.CLKOUT7_JITTER {114.944} \
    CONFIG.CLKOUT7_PHASE_ERROR {82.897} \
    CONFIG.CLKOUT7_REQUESTED_OUT_FREQ {76.4} \
    CONFIG.CLKOUT7_USED {true} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {13.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {10.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {6.500} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {26} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {26} \
    CONFIG.MMCM_CLKOUT2_PHASE {135.000} \
    CONFIG.MMCM_CLKOUT3_DIVIDE {13} \
    CONFIG.MMCM_CLKOUT4_DIVIDE {13} \
    CONFIG.MMCM_CLKOUT4_PHASE {270.000} \
    CONFIG.MMCM_CLKOUT5_DIVIDE {34} \
    CONFIG.MMCM_CLKOUT6_DIVIDE {17} \
    CONFIG.MMCM_DIVCLK_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {7} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {false} \
    CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
  ] $clk_store_sys


  # Create instance: image_processing_pipeline
  create_hier_cell_image_processing_pipeline [current_bd_instance .] image_processing_pipeline

  # Create instance: clk_buf, and set properties
  set clk_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.2 clk_buf ]
  set_property CONFIG.C_BUF_TYPE {BUFG} $clk_buf


  # Create instance: clk_dphy_200, and set properties
  set clk_dphy_200 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_dphy_200 ]
  set_property -dict [list \
    CONFIG.CLKOUT1_DRIVES {BUFGCE} \
    CONFIG.CLKOUT1_JITTER {120.598} \
    CONFIG.CLKOUT1_PHASE_ERROR {105.461} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {200.000} \
    CONFIG.CLKOUT2_DRIVES {BUFGCE} \
    CONFIG.CLKOUT2_JITTER {153.276} \
    CONFIG.CLKOUT2_PHASE_ERROR {105.461} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {60.000} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT3_DRIVES {BUFGCE} \
    CONFIG.CLKOUT3_JITTER {275.378} \
    CONFIG.CLKOUT3_PHASE_ERROR {132.063} \
    CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
    CONFIG.CLKOUT3_USED {false} \
    CONFIG.CLKOUT4_DRIVES {BUFGCE} \
    CONFIG.CLKOUT5_DRIVES {BUFGCE} \
    CONFIG.CLKOUT6_DRIVES {BUFGCE} \
    CONFIG.CLKOUT7_DRIVES {BUFGCE} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {9.000} \
    CONFIG.MMCM_CLKIN1_PERIOD {10.000} \
    CONFIG.MMCM_CLKIN2_PERIOD {10.000} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.500} \
    CONFIG.MMCM_CLKOUT1_DIVIDE {15} \
    CONFIG.MMCM_CLKOUT2_DIVIDE {1} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.SECONDARY_SOURCE {Single_ended_clock_capable_pin} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_PHASE_ALIGNMENT {false} \
    CONFIG.USE_RESET {false} \
    CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
  ] $clk_dphy_200


  # Create instance: ulpi_uart, and set properties
  set block_name usb_uart
  set block_cell_name ulpi_uart
  if { [catch {set ulpi_uart [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $ulpi_uart eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: b0, and set properties
  set b0 [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilconstant:1.0 b0 ]
  set_property CONFIG.CONST_VAL {0} $b0


  # Create instance: and_logic, and set properties
  set and_logic [ create_bd_cell -type inline_hdl -vlnv xilinx.com:inline_hdl:ilvector_logic:1.0 and_logic ]
  set_property CONFIG.C_SIZE {1} $and_logic


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_0_1 [get_bd_intf_ports S_AXI_0] [get_bd_intf_pins core_sys/S_AXI_0]
  connect_bd_intf_net -intf_net S_AXI_1_1 [get_bd_intf_ports S_AXI_1] [get_bd_intf_pins core_sys/S_AXI_1]
  connect_bd_intf_net -intf_net core_sys_ddr3_rw_port [get_bd_intf_pins core_sys/ddr3_rw_port] [get_bd_intf_pins image_processing_pipeline/core_sys_rw_port]
  connect_bd_intf_net -intf_net ddr3_frontend_ddr3_0 [get_bd_intf_ports ddr3] [get_bd_intf_pins image_processing_pipeline/ddr3]
  connect_bd_intf_net -intf_net image_processing_pipeline_mipi_csi_axis [get_bd_intf_pins image_processing_pipeline/mipi_csi_axis] [get_bd_intf_pins core_sys/mipi_csi_s_axis]
  connect_bd_intf_net -intf_net perith_iic_rtl_0 [get_bd_intf_ports mipi_csi_iic] [get_bd_intf_pins core_sys/mipi_csi_iic]
  connect_bd_intf_net -intf_net perith_mipi_phy_if [get_bd_intf_pins core_sys/mipi_csi_phy] [get_bd_intf_ports mipi_csi_phy]
  connect_bd_intf_net -intf_net perith_spi_rtl_0 [get_bd_intf_ports config_flash_spi] [get_bd_intf_pins core_sys/config_flash_spi]
  connect_bd_intf_net -intf_net perith_spi_rtl_1 [get_bd_intf_ports proxy_board_spi] [get_bd_intf_pins core_sys/proxy_board_spi]
  connect_bd_intf_net -intf_net ulpi_1 [get_bd_intf_ports ulpi] [get_bd_intf_pins ulpi_uart/user_ulpi]
  connect_bd_intf_net -intf_net user_sens_0_1 [get_bd_intf_ports proxy_board] [get_bd_intf_pins image_processing_pipeline/proxy_board]

  # Create port connections
  connect_bd_net -net b0_dout  [get_bd_pins b0/dout] \
  [get_bd_pins core_sys/STARTUP_IO_S_usrdonets] \
  [get_bd_ports led]
  connect_bd_net -net board_clk_74_25_1  [get_bd_ports i_board_clk_100] \
  [get_bd_pins clk_buf/BUFG_I]
  connect_bd_net -net board_rst_n_0_1  [get_bd_pins core_sys/peripheral_aresetn] \
  [get_bd_pins image_processing_pipeline/sys_rst_n]
  connect_bd_net -net clk_dphy_200_clk_out2  [get_bd_pins clk_dphy_200/clk_out2] \
  [get_bd_pins ulpi_uart/ulpi_60MHz_clk]
  connect_bd_net -net clk_dphy_200_locked  [get_bd_pins clk_dphy_200/locked] \
  [get_bd_pins and_logic/Op2]
  connect_bd_net -net clk_store_sys_clk_out1  [get_bd_pins clk_store_sys/clk_out1] \
  [get_bd_pins image_processing_pipeline/ref_clk]
  connect_bd_net -net clk_store_sys_clk_out2  [get_bd_pins clk_store_sys/clk_out2] \
  [get_bd_pins core_sys/sys_clk] \
  [get_bd_pins image_processing_pipeline/sys_clk]
  connect_bd_net -net clk_store_sys_clk_out3  [get_bd_pins clk_store_sys/clk_out3] \
  [get_bd_pins image_processing_pipeline/sys_135_clk]
  connect_bd_net -net clk_store_sys_clk_out4  [get_bd_pins clk_store_sys/clk_out4] \
  [get_bd_pins image_processing_pipeline/ddr_clk]
  connect_bd_net -net clk_store_sys_clk_out5  [get_bd_pins clk_store_sys/clk_out5] \
  [get_bd_pins image_processing_pipeline/ddr_270_clk]
  connect_bd_net -net clk_store_sys_clk_out6  [get_bd_pins clk_store_sys/clk_out6] \
  [get_bd_pins image_processing_pipeline/fr30_clk]
  connect_bd_net -net clk_store_sys_clk_out7  [get_bd_pins clk_store_sys/clk_out7] \
  [get_bd_pins image_processing_pipeline/fr60_clk]
  connect_bd_net -net clk_store_sys_locked  [get_bd_pins clk_store_sys/locked] \
  [get_bd_pins and_logic/Op1]
  connect_bd_net -net clk_wiz_0_clk_out1  [get_bd_pins clk_dphy_200/clk_out1] \
  [get_bd_pins core_sys/mipi_csi_dphy_clk_200M]
  connect_bd_net -net core_sys_coeff_table_ddr3_base_addr_0  [get_bd_pins core_sys/coeff_table_ddr3_base_addr_0] \
  [get_bd_pins image_processing_pipeline/coeff_table_ddr3_base_addr]
  connect_bd_net -net core_sys_ips  [get_bd_pins core_sys/ips] \
  [get_bd_pins image_processing_pipeline/ips]
  connect_bd_net -net core_sys_uart_txd  [get_bd_pins core_sys/uart_txd] \
  [get_bd_pins ulpi_uart/uart_tx]
  connect_bd_net -net i_superviser_1  [get_bd_ports i_superviser] \
  [get_bd_pins core_sys/superviser] \
  [get_bd_pins image_processing_pipeline/i_superviser]
  connect_bd_net -net i_trigger_0_1  [get_bd_ports trigger] \
  [get_bd_pins image_processing_pipeline/trigger]
  connect_bd_net -net ilvector_logic_0_Res  [get_bd_pins and_logic/Res] \
  [get_bd_pins core_sys/dcm_locked]
  connect_bd_net -net image_processing_pipeline_bba  [get_bd_pins image_processing_pipeline/bba] \
  [get_bd_pins core_sys/bba]
  connect_bd_net -net image_processing_pipeline_dbg_probe_mc_in_0  [get_bd_pins image_processing_pipeline/dbg_probe_mc_in_0] \
  [get_bd_pins core_sys/dbg_probe_0_mc_in]
  connect_bd_net -net image_processing_pipeline_dbg_probe_mc_in_2  [get_bd_pins image_processing_pipeline/dbg_probe_mc_in_2] \
  [get_bd_pins core_sys/dbg_probe_1_mc_in]
  connect_bd_net -net image_processing_pipeline_o_ips_mipi_csi_driver_rst  [get_bd_pins image_processing_pipeline/ips_mipi_csi_phy_rst] \
  [get_bd_ports o_mipi_csi_phy_rst_n]
  connect_bd_net -net image_processing_pipeline_o_led_0  [get_bd_pins image_processing_pipeline/o_led] \
  [get_bd_pins core_sys/STARTUP_IO_S_userdoneo]
  connect_bd_net -net image_processing_pipeline_pb_master_clk  [get_bd_pins image_processing_pipeline/pb_master_clk] \
  [get_bd_ports proxy_board_master_clk]
  connect_bd_net -net image_processing_pipeline_sens_img_frame_number  [get_bd_pins image_processing_pipeline/sens_img_frame_number] \
  [get_bd_pins core_sys/image_frame_number]
  connect_bd_net -net ipst_0_1  [get_bd_pins image_processing_pipeline/ipst] \
  [get_bd_pins core_sys/ipst]
  connect_bd_net -net proxy_board_pixel_clk_clk_out1  [get_bd_ports proxy_board_pixel_clk] \
  [get_bd_pins image_processing_pipeline/proxy_board_pixel_clk]
  connect_bd_net -net s_axi_aclk_0_1  [get_bd_ports s_axi_aclk_0] \
  [get_bd_pins core_sys/s_axi_aclk_0]
  connect_bd_net -net s_axi_aresetn_0_1  [get_bd_ports s_axi_aresetn_0] \
  [get_bd_pins core_sys/s_axi_aresetn_0]
  connect_bd_net -net usb_uart_uart_rx  [get_bd_pins ulpi_uart/uart_rx] \
  [get_bd_pins core_sys/uart_rxd]
  connect_bd_net -net util_ds_buf_0_BUFG_O  [get_bd_pins clk_buf/BUFG_O] \
  [get_bd_pins clk_store_sys/clk_in1] \
  [get_bd_pins clk_dphy_200/clk_in1]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x00010000 -with_name SEG_bba_0_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/gpio/bba_ifn/S_AXI/Reg] -force
  assign_bd_address -offset 0x40030000 -range 0x00010000 -with_name SEG_coefs_table_addr_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/gpio/coeff_table_base_addr/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/config_flash_spi/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/core/mblaze_local_memory/d_lmb_bram_if_cntlr/SLMB/Mem] -with_locktype global -force
  assign_bd_address -offset 0x40040000 -range 0x00010000 -with_name SEG_dbg_probe_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/gpio/dbg_probe_mc_in/S_AXI/Reg] -force
  assign_bd_address -offset 0x40010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/gpio/dbg_probe_mc_out/S_AXI/Reg] -force
  assign_bd_address -offset 0xC0000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/ddr3_proxy/ddr3_proxy_if/S_AXI/Mem0] -force
  assign_bd_address -offset 0x40050000 -range 0x00010000 -with_name SEG_ddr3_proxy_if_addr_size_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/ddr3_proxy/ddr3_proxy_txn_info/S_AXI/Reg] -force
  assign_bd_address -offset 0x40060000 -range 0x00010000 -with_name SEG_ddr3_proxy_if_req_rsp_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/ddr3_proxy/ddr3_proxy_req_rsp/S_AXI/Reg] -force
  assign_bd_address -offset 0x40090000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/gpio/ips/S_AXI/Reg] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -with_name SEG_mblaze_intc_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/core/mblaze_irq_cntr/S_AXI/Reg] -force
  assign_bd_address -offset 0x41400000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/core/mdm/S_AXI/Reg] -force
  assign_bd_address -offset 0x40810000 -range 0x00010000 -with_name SEG_mipi_csi_sccb_Reg -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/mipi_csi_iic/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A00000 -range 0x00002000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/mipi_csi_tx/s_axi/Reg] -force
  assign_bd_address -offset 0x44A20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/proxy_board_spi/AXI_LITE/Reg] -force
  assign_bd_address -offset 0x44A40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/uart/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Data] [get_bd_addr_segs core_sys/xadc/s_axi_lite/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces core_sys/core/mblaze_core/Instruction] [get_bd_addr_segs core_sys/core/mblaze_local_memory/i_lmb_bram_if_cntlr/SLMB/Mem] -with_locktype global -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


