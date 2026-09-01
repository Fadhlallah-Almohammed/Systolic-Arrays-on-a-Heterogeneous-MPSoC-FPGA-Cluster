
################################################################
# This is a generated script based on design: sa_q4_top
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
set scripts_vivado_version 2024.2
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
# source sa_q4_top_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# gt_reset, saxis_mux, axil_static_regs_vhdl93, frequency_measurement, frequency_measurement, frequency_measurement

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xczu4eg-sfvc784-1-e
   set_property BOARD_PART trenz.biz:te0803_4eg_1e:part0:3.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name sa_q4_top

# This script was generated for a remote BD. To create a non-remote design,
# change the variable <run_remote_bd_flow> to <0>.

set run_remote_bd_flow 1
if { $run_remote_bd_flow == 1 } {
  # Set the reference directory for source file relative paths (by default 
  # the value is script directory path)
  set origin_dir ./BD

  # Use origin directory path location variable, if specified in the tcl shell
  if { [info exists ::origin_dir_loc] } {
     set origin_dir $::origin_dir_loc
  }

  set str_bd_folder [file normalize ${origin_dir}]
  set str_bd_filepath ${str_bd_folder}/${design_name}/${design_name}.bd

  # Check if remote design exists on disk
  if { [file exists $str_bd_filepath ] == 1 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2030 -severity "ERROR" "The remote BD file path <$str_bd_filepath> already exists!"}
     common::send_gid_msg -ssname BD::TCL -id 2031 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0>."
     common::send_gid_msg -ssname BD::TCL -id 2032 -severity "INFO" "Also make sure there is no design <$design_name> existing in your current project."

     return 1
  }

  # Check if design exists in memory
  set list_existing_designs [get_bd_designs -quiet $design_name]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2033 -severity "ERROR" "The design <$design_name> already exists in this project! Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2034 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Check if design exists on disk within project
  set list_existing_designs [get_files -quiet */${design_name}.bd]
  if { $list_existing_designs ne "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2035 -severity "ERROR" "The design <$design_name> already exists in this project at location:
    $list_existing_designs"}
     catch {common::send_gid_msg -ssname BD::TCL -id 2036 -severity "ERROR" "Will not create the remote BD <$design_name> at the folder <$str_bd_folder>."}

     common::send_gid_msg -ssname BD::TCL -id 2037 -severity "INFO" "To create a non-remote BD, change the variable <run_remote_bd_flow> to <0> or please set a different value to variable <design_name>."

     return 1
  }

  # Now can create the remote BD
  # NOTE - usage of <-dir> will create <$str_bd_folder/$design_name/$design_name.bd>
  create_bd_design -dir $str_bd_folder $design_name
} else {

  # Create regular design
  if { [catch {create_bd_design $design_name} errmsg] } {
     common::send_gid_msg -ssname BD::TCL -id 2038 -severity "INFO" "Please set a different value to variable <design_name>."

     return 1
  }
}

current_bd_design $design_name

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:zynq_ultra_ps_e:3.5\
xilinx.com:ip:smartconnect:1.0\
www.ictp.it:user:comblock:2.0\
xilinx.com:ip:clk_wiz:6.0\
xilinx.com:ip:vio:3.0\
xilinx.com:ip:axis_broadcaster:1.1\
xilinx.com:hls:sa_grid:1.0\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:system_ila:1.1\
xilinx.com:ip:aurora_8b10b:11.1\
xilinx.com:ip:fifo_generator:13.2\
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
gt_reset\
saxis_mux\
axil_static_regs_vhdl93\
frequency_measurement\
frequency_measurement\
frequency_measurement\
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


# Hierarchical cell: GTHD
proc create_hier_cell_GTHD { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_GTHD() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 USER_DATA_S_AXI_TX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 USER_DATA_M_AXI_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_2


  # Create pins
  create_bd_pin -dir O hard_err
  create_bd_pin -dir O soft_err
  create_bd_pin -dir O frame_err
  create_bd_pin -dir O channel_up
  create_bd_pin -dir O -from 0 -to 0 lane_up
  create_bd_pin -dir I rst_i
  create_bd_pin -dir I -type rst gt_reset
  create_bd_pin -dir I -from 0 -to 0 loopback
  create_bd_pin -dir O crc_valid
  create_bd_pin -dir O crc_pass_fail_n
  create_bd_pin -dir I -type rst power_down
  create_bd_pin -dir O tx_lock
  create_bd_pin -dir O tx_resetdone_out
  create_bd_pin -dir O rx_resetdone_out
  create_bd_pin -dir O -type rst link_reset_out
  create_bd_pin -dir I -type clk init_clk_in
  create_bd_pin -dir O pll_not_locked_out
  create_bd_pin -dir O -type rst sys_reset_out
  create_bd_pin -dir I -type clk gt_refclk1
  create_bd_pin -dir O -type clk sync_clk_out
  create_bd_pin -dir O -from 0 -to 0 gt_powergood
  create_bd_pin -dir I SYS_CLK
  create_bd_pin -dir I s_aresetn

  # Create instance: aurora_8b10b_GTH0_D, and set properties
  set aurora_8b10b_GTH0_D [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_8b10b:11.1 aurora_8b10b_GTH0_D ]
  set_property -dict [list \
    CONFIG.C_DRP_IF {false} \
    CONFIG.C_LANE_WIDTH {4} \
    CONFIG.C_LINE_RATE {6.25} \
    CONFIG.C_REFCLK_SOURCE {MGTREFCLK1 of Quad X0Y1} \
    CONFIG.C_START_LANE {X0Y7} \
    CONFIG.C_USE_CRC {true} \
    CONFIG.Flow_Mode {None} \
    CONFIG.SINGLEEND_GTREFCLK {true} \
    CONFIG.SupportLevel {1} \
  ] $aurora_8b10b_GTH0_D


  # Create instance: IN_CDC_GTH0_D, and set properties
  set IN_CDC_GTH0_D [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 IN_CDC_GTH0_D ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $IN_CDC_GTH0_D


  # Create instance: OUT_CDC_GTH0_D, and set properties
  set OUT_CDC_GTH0_D [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 OUT_CDC_GTH0_D ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $OUT_CDC_GTH0_D


  # Create instance: ILA_GTHA, and set properties
  set ILA_GTHA [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ILA_GTHA ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {MIX} \
    CONFIG.C_NUM_MONITOR_SLOTS {1} \
    CONFIG.C_NUM_OF_PROBES {15} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE10_TYPE {0} \
    CONFIG.C_PROBE11_TYPE {0} \
    CONFIG.C_PROBE12_TYPE {0} \
    CONFIG.C_PROBE13_TYPE {0} \
    CONFIG.C_PROBE14_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
    CONFIG.C_PROBE3_TYPE {0} \
    CONFIG.C_PROBE4_TYPE {0} \
    CONFIG.C_PROBE5_TYPE {0} \
    CONFIG.C_PROBE6_TYPE {0} \
    CONFIG.C_PROBE7_TYPE {0} \
    CONFIG.C_PROBE8_TYPE {0} \
    CONFIG.C_PROBE9_TYPE {0} \
    CONFIG.C_SLOT_0_APC_EN {0} \
    CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
    CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  ] $ILA_GTHA


  # Create interface connections
  connect_bd_intf_net -intf_net CDC_GTH0_B_M_AXIS [get_bd_intf_pins IN_CDC_GTH0_D/M_AXIS] [get_bd_intf_pins aurora_8b10b_GTH0_D/USER_DATA_S_AXI_TX]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins GT_SERIAL_RX_2] [get_bd_intf_pins aurora_8b10b_GTH0_D/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins GT_SERIAL_TX_2] [get_bd_intf_pins aurora_8b10b_GTH0_D/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net OUT_CDC_GTH0_D_M_AXIS [get_bd_intf_pins USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_D/M_AXIS]
  connect_bd_intf_net -intf_net USER_DATA_S_AXI_TX_1 [get_bd_intf_pins USER_DATA_S_AXI_TX] [get_bd_intf_pins IN_CDC_GTH0_D/S_AXIS]
  connect_bd_intf_net -intf_net aurora_8b10b_GTH0_D_USER_DATA_M_AXI_RX [get_bd_intf_pins aurora_8b10b_GTH0_D/USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_D/S_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets aurora_8b10b_GTH0_D_USER_DATA_M_AXI_RX] [get_bd_intf_pins aurora_8b10b_GTH0_D/USER_DATA_M_AXI_RX] [get_bd_intf_pins ILA_GTHA/SLOT_0_AXIS]

  # Create port connections
  connect_bd_net -net SYS_CLK_1  [get_bd_pins SYS_CLK] \
  [get_bd_pins IN_CDC_GTH0_D/s_aclk] \
  [get_bd_pins OUT_CDC_GTH0_D/m_aclk]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_refclk1_out  [get_bd_pins gt_refclk1] \
  [get_bd_pins aurora_8b10b_GTH0_D/gt_refclk1]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_reset_out  [get_bd_pins gt_reset] \
  [get_bd_pins aurora_8b10b_GTH0_D/gt_reset]
  connect_bd_net -net aurora_8b10b_GTH0_D_channel_up  [get_bd_pins aurora_8b10b_GTH0_D/channel_up] \
  [get_bd_pins channel_up] \
  [get_bd_pins ILA_GTHA/probe0]
  connect_bd_net -net aurora_8b10b_GTH0_D_crc_pass_fail_n  [get_bd_pins aurora_8b10b_GTH0_D/crc_pass_fail_n] \
  [get_bd_pins crc_pass_fail_n] \
  [get_bd_pins ILA_GTHA/probe1]
  connect_bd_net -net aurora_8b10b_GTH0_D_crc_valid  [get_bd_pins aurora_8b10b_GTH0_D/crc_valid] \
  [get_bd_pins crc_valid] \
  [get_bd_pins ILA_GTHA/probe2]
  connect_bd_net -net aurora_8b10b_GTH0_D_frame_err  [get_bd_pins aurora_8b10b_GTH0_D/frame_err] \
  [get_bd_pins frame_err] \
  [get_bd_pins ILA_GTHA/probe3]
  connect_bd_net -net aurora_8b10b_GTH0_D_gt_powergood  [get_bd_pins aurora_8b10b_GTH0_D/gt_powergood] \
  [get_bd_pins gt_powergood] \
  [get_bd_pins ILA_GTHA/probe14]
  connect_bd_net -net aurora_8b10b_GTH0_D_gt_reset_out  [get_bd_pins aurora_8b10b_GTH0_D/gt_reset_out] \
  [get_bd_pins ILA_GTHA/probe13]
  connect_bd_net -net aurora_8b10b_GTH0_D_hard_err  [get_bd_pins aurora_8b10b_GTH0_D/hard_err] \
  [get_bd_pins hard_err] \
  [get_bd_pins ILA_GTHA/probe4]
  connect_bd_net -net aurora_8b10b_GTH0_D_lane_up  [get_bd_pins aurora_8b10b_GTH0_D/lane_up] \
  [get_bd_pins lane_up] \
  [get_bd_pins ILA_GTHA/probe5]
  connect_bd_net -net aurora_8b10b_GTH0_D_link_reset_out  [get_bd_pins aurora_8b10b_GTH0_D/link_reset_out] \
  [get_bd_pins link_reset_out] \
  [get_bd_pins ILA_GTHA/probe11]
  connect_bd_net -net aurora_8b10b_GTH0_D_pll_not_locked_out  [get_bd_pins aurora_8b10b_GTH0_D/pll_not_locked_out] \
  [get_bd_pins pll_not_locked_out] \
  [get_bd_pins ILA_GTHA/probe6]
  connect_bd_net -net aurora_8b10b_GTH0_D_rx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_D/rx_resetdone_out] \
  [get_bd_pins rx_resetdone_out] \
  [get_bd_pins ILA_GTHA/probe7]
  connect_bd_net -net aurora_8b10b_GTH0_D_soft_err  [get_bd_pins aurora_8b10b_GTH0_D/soft_err] \
  [get_bd_pins soft_err] \
  [get_bd_pins ILA_GTHA/probe8]
  connect_bd_net -net aurora_8b10b_GTH0_D_sync_clk_out  [get_bd_pins aurora_8b10b_GTH0_D/sync_clk_out] \
  [get_bd_pins sync_clk_out]
  connect_bd_net -net aurora_8b10b_GTH0_D_sys_reset_out  [get_bd_pins aurora_8b10b_GTH0_D/sys_reset_out] \
  [get_bd_pins sys_reset_out] \
  [get_bd_pins ILA_GTHA/probe12]
  connect_bd_net -net aurora_8b10b_GTH0_D_tx_lock  [get_bd_pins aurora_8b10b_GTH0_D/tx_lock] \
  [get_bd_pins tx_lock] \
  [get_bd_pins ILA_GTHA/probe9]
  connect_bd_net -net aurora_8b10b_GTH0_D_tx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_D/tx_resetdone_out] \
  [get_bd_pins tx_resetdone_out] \
  [get_bd_pins ILA_GTHA/probe10]
  connect_bd_net -net aurora_8b10b_GTH0_D_user_clk_out  [get_bd_pins aurora_8b10b_GTH0_D/user_clk_out] \
  [get_bd_pins IN_CDC_GTH0_D/m_aclk] \
  [get_bd_pins OUT_CDC_GTH0_D/s_aclk] \
  [get_bd_pins ILA_GTHA/clk]
  connect_bd_net -net clk_wiz_0_INIT_CLK  [get_bd_pins init_clk_in] \
  [get_bd_pins aurora_8b10b_GTH0_D/init_clk_in]
  connect_bd_net -net rst_i_1  [get_bd_pins rst_i] \
  [get_bd_pins aurora_8b10b_GTH0_D/reset]
  connect_bd_net -net s_aresetn_1  [get_bd_pins s_aresetn] \
  [get_bd_pins IN_CDC_GTH0_D/s_aresetn] \
  [get_bd_pins OUT_CDC_GTH0_D/s_aresetn] \
  [get_bd_pins ILA_GTHA/resetn]
  connect_bd_net -net vio_0_probe_out0  [get_bd_pins loopback] \
  [get_bd_pins aurora_8b10b_GTH0_D/loopback]
  connect_bd_net -net vio_0_probe_out1  [get_bd_pins power_down] \
  [get_bd_pins aurora_8b10b_GTH0_D/power_down]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: GTHA
proc create_hier_cell_GTHA { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_GTHA() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 USER_DATA_M_AXI_RX

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DIFF_REFCLK1_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_0


  # Create pins
  create_bd_pin -dir O -type clk USER_CLK_O
  create_bd_pin -dir I -type clk SYS_CLK
  create_bd_pin -dir I -type rst resetn
  create_bd_pin -dir O hard_err
  create_bd_pin -dir O soft_err
  create_bd_pin -dir O frame_err
  create_bd_pin -dir O channel_up
  create_bd_pin -dir O -from 0 -to 0 lane_up
  create_bd_pin -dir I -type rst gt_reset
  create_bd_pin -dir I -from 0 -to 0 loopback
  create_bd_pin -dir O crc_valid
  create_bd_pin -dir O crc_pass_fail_n
  create_bd_pin -dir I -type rst power_down
  create_bd_pin -dir O tx_lock
  create_bd_pin -dir O tx_resetdone_out
  create_bd_pin -dir O rx_resetdone_out
  create_bd_pin -dir O -type rst link_reset_out
  create_bd_pin -dir I -type clk init_clk_in
  create_bd_pin -dir O pll_not_locked_out
  create_bd_pin -dir O -type rst sys_reset_out
  create_bd_pin -dir O -type clk sync_clk_out
  create_bd_pin -dir O -type rst gt_reset_out
  create_bd_pin -dir O -type clk gt_refclk1_out
  create_bd_pin -dir O -from 0 -to 0 gt_powergood
  create_bd_pin -dir I -type rst rst_i

  # Create instance: IN_CDC_GTH0_A, and set properties
  set IN_CDC_GTH0_A [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 IN_CDC_GTH0_A ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $IN_CDC_GTH0_A


  # Create instance: aurora_8b10b_GTH0_A, and set properties
  set aurora_8b10b_GTH0_A [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_8b10b:11.1 aurora_8b10b_GTH0_A ]
  set_property -dict [list \
    CONFIG.C_DRP_IF {false} \
    CONFIG.C_LANE_WIDTH {4} \
    CONFIG.C_LINE_RATE {6.25} \
    CONFIG.C_REFCLK_SOURCE {MGTREFCLK1 of Quad X0Y1} \
    CONFIG.C_USE_CRC {true} \
    CONFIG.Flow_Mode {None} \
    CONFIG.SupportLevel {1} \
  ] $aurora_8b10b_GTH0_A


  # Create instance: OUT_CDC_GTH0_A, and set properties
  set OUT_CDC_GTH0_A [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 OUT_CDC_GTH0_A ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $OUT_CDC_GTH0_A


  # Create instance: ILA_GTHA, and set properties
  set ILA_GTHA [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ILA_GTHA ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {MIX} \
    CONFIG.C_NUM_MONITOR_SLOTS {1} \
    CONFIG.C_NUM_OF_PROBES {15} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE10_TYPE {0} \
    CONFIG.C_PROBE11_TYPE {0} \
    CONFIG.C_PROBE12_TYPE {0} \
    CONFIG.C_PROBE13_TYPE {0} \
    CONFIG.C_PROBE14_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
    CONFIG.C_PROBE3_TYPE {0} \
    CONFIG.C_PROBE4_TYPE {0} \
    CONFIG.C_PROBE5_TYPE {0} \
    CONFIG.C_PROBE6_TYPE {0} \
    CONFIG.C_PROBE7_TYPE {0} \
    CONFIG.C_PROBE8_TYPE {0} \
    CONFIG.C_PROBE9_TYPE {0} \
    CONFIG.C_SLOT_0_APC_EN {0} \
    CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
    CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  ] $ILA_GTHA


  # Create interface connections
  connect_bd_intf_net -intf_net CDC_GTH0_A_M_AXIS [get_bd_intf_pins IN_CDC_GTH0_A/M_AXIS] [get_bd_intf_pins aurora_8b10b_GTH0_A/USER_DATA_S_AXI_TX]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins GT_SERIAL_RX_0] [get_bd_intf_pins aurora_8b10b_GTH0_A/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins GT_SERIAL_TX_0] [get_bd_intf_pins aurora_8b10b_GTH0_A/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins GT_DIFF_REFCLK1_0] [get_bd_intf_pins aurora_8b10b_GTH0_A/GT_DIFF_REFCLK1]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins IN_CDC_GTH0_A/S_AXIS]
  connect_bd_intf_net -intf_net IN_CDC_GTH0_A1_M_AXIS [get_bd_intf_pins USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_A/M_AXIS]
  connect_bd_intf_net -intf_net aurora_8b10b_GTH0_A_USER_DATA_M_AXI_RX [get_bd_intf_pins aurora_8b10b_GTH0_A/USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_A/S_AXIS]
  connect_bd_intf_net -intf_net [get_bd_intf_nets aurora_8b10b_GTH0_A_USER_DATA_M_AXI_RX] [get_bd_intf_pins aurora_8b10b_GTH0_A/USER_DATA_M_AXI_RX] [get_bd_intf_pins ILA_GTHA/SLOT_0_AXIS]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_intf_nets aurora_8b10b_GTH0_A_USER_DATA_M_AXI_RX]

  # Create port connections
  connect_bd_net -net aurora_8b10b_GTH0_A_channel_up  [get_bd_pins aurora_8b10b_GTH0_A/channel_up] \
  [get_bd_pins channel_up] \
  [get_bd_pins ILA_GTHA/probe0]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_channel_up]
  connect_bd_net -net aurora_8b10b_GTH0_A_crc_pass_fail_n  [get_bd_pins aurora_8b10b_GTH0_A/crc_pass_fail_n] \
  [get_bd_pins crc_pass_fail_n] \
  [get_bd_pins ILA_GTHA/probe1]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_crc_pass_fail_n]
  connect_bd_net -net aurora_8b10b_GTH0_A_crc_valid  [get_bd_pins aurora_8b10b_GTH0_A/crc_valid] \
  [get_bd_pins crc_valid] \
  [get_bd_pins ILA_GTHA/probe2]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_crc_valid]
  connect_bd_net -net aurora_8b10b_GTH0_A_frame_err  [get_bd_pins aurora_8b10b_GTH0_A/frame_err] \
  [get_bd_pins frame_err] \
  [get_bd_pins ILA_GTHA/probe3]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_frame_err]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_powergood  [get_bd_pins aurora_8b10b_GTH0_A/gt_powergood] \
  [get_bd_pins gt_powergood] \
  [get_bd_pins ILA_GTHA/probe4]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_gt_powergood]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_refclk1_out  [get_bd_pins aurora_8b10b_GTH0_A/gt_refclk1_out] \
  [get_bd_pins gt_refclk1_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_reset_out  [get_bd_pins aurora_8b10b_GTH0_A/gt_reset_out] \
  [get_bd_pins gt_reset_out] \
  [get_bd_pins ILA_GTHA/probe5]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_gt_reset_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_hard_err  [get_bd_pins aurora_8b10b_GTH0_A/hard_err] \
  [get_bd_pins hard_err] \
  [get_bd_pins ILA_GTHA/probe6]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_hard_err]
  connect_bd_net -net aurora_8b10b_GTH0_A_lane_up  [get_bd_pins aurora_8b10b_GTH0_A/lane_up] \
  [get_bd_pins lane_up] \
  [get_bd_pins ILA_GTHA/probe7]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_lane_up]
  connect_bd_net -net aurora_8b10b_GTH0_A_link_reset_out  [get_bd_pins aurora_8b10b_GTH0_A/link_reset_out] \
  [get_bd_pins link_reset_out] \
  [get_bd_pins ILA_GTHA/probe8]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_link_reset_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_pll_not_locked_out  [get_bd_pins aurora_8b10b_GTH0_A/pll_not_locked_out] \
  [get_bd_pins pll_not_locked_out] \
  [get_bd_pins ILA_GTHA/probe9]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_pll_not_locked_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_rx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_A/rx_resetdone_out] \
  [get_bd_pins rx_resetdone_out] \
  [get_bd_pins ILA_GTHA/probe10]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_rx_resetdone_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_soft_err  [get_bd_pins aurora_8b10b_GTH0_A/soft_err] \
  [get_bd_pins soft_err] \
  [get_bd_pins ILA_GTHA/probe11]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_soft_err]
  connect_bd_net -net aurora_8b10b_GTH0_A_sync_clk_out  [get_bd_pins aurora_8b10b_GTH0_A/sync_clk_out] \
  [get_bd_pins sync_clk_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_sys_reset_out  [get_bd_pins aurora_8b10b_GTH0_A/sys_reset_out] \
  [get_bd_pins sys_reset_out] \
  [get_bd_pins ILA_GTHA/probe12]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_sys_reset_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_tx_lock  [get_bd_pins aurora_8b10b_GTH0_A/tx_lock] \
  [get_bd_pins tx_lock] \
  [get_bd_pins ILA_GTHA/probe13]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_tx_lock]
  connect_bd_net -net aurora_8b10b_GTH0_A_tx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_A/tx_resetdone_out] \
  [get_bd_pins tx_resetdone_out] \
  [get_bd_pins ILA_GTHA/probe14]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets aurora_8b10b_GTH0_A_tx_resetdone_out]
  connect_bd_net -net aurora_8b10b_GTH0_A_user_clk_out  [get_bd_pins aurora_8b10b_GTH0_A/user_clk_out] \
  [get_bd_pins USER_CLK_O] \
  [get_bd_pins IN_CDC_GTH0_A/m_aclk] \
  [get_bd_pins OUT_CDC_GTH0_A/s_aclk] \
  [get_bd_pins ILA_GTHA/clk]
  connect_bd_net -net clk_wiz_0_INIT_CLK  [get_bd_pins init_clk_in] \
  [get_bd_pins aurora_8b10b_GTH0_A/init_clk_in]
  connect_bd_net -net gt_reset_0_rst_o  [get_bd_pins gt_reset] \
  [get_bd_pins aurora_8b10b_GTH0_A/gt_reset]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins IN_CDC_GTH0_A/s_aresetn] \
  [get_bd_pins OUT_CDC_GTH0_A/s_aresetn] \
  [get_bd_pins ILA_GTHA/resetn]
  connect_bd_net -net rst_i_1  [get_bd_pins rst_i] \
  [get_bd_pins aurora_8b10b_GTH0_A/reset]
  connect_bd_net -net s_aclk_0_1  [get_bd_pins SYS_CLK] \
  [get_bd_pins IN_CDC_GTH0_A/s_aclk] \
  [get_bd_pins OUT_CDC_GTH0_A/m_aclk]
  connect_bd_net -net vio_0_probe_out0  [get_bd_pins loopback] \
  [get_bd_pins aurora_8b10b_GTH0_A/loopback]
  connect_bd_net -net vio_0_probe_out1  [get_bd_pins power_down] \
  [get_bd_pins aurora_8b10b_GTH0_A/power_down]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: GTHC
proc create_hier_cell_GTHC { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_GTHC() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 USER_DATA_M_AXI_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS


  # Create pins
  create_bd_pin -dir O hard_err
  create_bd_pin -dir O soft_err
  create_bd_pin -dir O frame_err
  create_bd_pin -dir O channel_up
  create_bd_pin -dir O -from 0 -to 0 lane_up
  create_bd_pin -dir I rst_i
  create_bd_pin -dir I -type rst gt_reset
  create_bd_pin -dir I -from 0 -to 0 loopback
  create_bd_pin -dir O crc_valid
  create_bd_pin -dir O crc_pass_fail_n
  create_bd_pin -dir I -type rst power_down
  create_bd_pin -dir O tx_lock
  create_bd_pin -dir O tx_resetdone_out
  create_bd_pin -dir O rx_resetdone_out
  create_bd_pin -dir O -type rst link_reset_out
  create_bd_pin -dir I -type clk init_clk_in
  create_bd_pin -dir O pll_not_locked_out
  create_bd_pin -dir O -type rst sys_reset_out
  create_bd_pin -dir I -type clk gt_refclk1
  create_bd_pin -dir O -type clk sync_clk_out
  create_bd_pin -dir O -from 0 -to 0 gt_powergood
  create_bd_pin -dir I -type clk SYS_CLK
  create_bd_pin -dir I -type rst resetn

  # Create instance: aurora_8b10b_GTH0_C, and set properties
  set aurora_8b10b_GTH0_C [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_8b10b:11.1 aurora_8b10b_GTH0_C ]
  set_property -dict [list \
    CONFIG.C_DRP_IF {false} \
    CONFIG.C_LANE_WIDTH {4} \
    CONFIG.C_LINE_RATE {6.25} \
    CONFIG.C_REFCLK_SOURCE {MGTREFCLK1 of Quad X0Y1} \
    CONFIG.C_START_LANE {X0Y6} \
    CONFIG.C_USE_CRC {true} \
    CONFIG.Flow_Mode {None} \
    CONFIG.SINGLEEND_GTREFCLK {true} \
    CONFIG.SupportLevel {1} \
  ] $aurora_8b10b_GTH0_C


  # Create instance: IN_CDC_GTH0_C, and set properties
  set IN_CDC_GTH0_C [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 IN_CDC_GTH0_C ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $IN_CDC_GTH0_C


  # Create instance: OUT_CDC_GTH0_C, and set properties
  set OUT_CDC_GTH0_C [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 OUT_CDC_GTH0_C ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $OUT_CDC_GTH0_C


  # Create instance: ILA_GTHC, and set properties
  set ILA_GTHC [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ILA_GTHC ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {MIX} \
    CONFIG.C_NUM_MONITOR_SLOTS {1} \
    CONFIG.C_NUM_OF_PROBES {15} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE10_TYPE {0} \
    CONFIG.C_PROBE11_TYPE {0} \
    CONFIG.C_PROBE12_TYPE {0} \
    CONFIG.C_PROBE13_TYPE {0} \
    CONFIG.C_PROBE14_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
    CONFIG.C_PROBE3_TYPE {0} \
    CONFIG.C_PROBE4_TYPE {0} \
    CONFIG.C_PROBE5_TYPE {0} \
    CONFIG.C_PROBE6_TYPE {0} \
    CONFIG.C_PROBE7_TYPE {0} \
    CONFIG.C_PROBE8_TYPE {0} \
    CONFIG.C_PROBE9_TYPE {0} \
    CONFIG.C_SLOT_0_APC_EN {0} \
    CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
    CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  ] $ILA_GTHC


  # Create interface connections
  connect_bd_intf_net -intf_net CDC_GTH0_C_M_AXIS [get_bd_intf_pins IN_CDC_GTH0_C/M_AXIS] [get_bd_intf_pins aurora_8b10b_GTH0_C/USER_DATA_S_AXI_TX]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins GT_SERIAL_RX_3] [get_bd_intf_pins aurora_8b10b_GTH0_C/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins GT_SERIAL_TX_3] [get_bd_intf_pins aurora_8b10b_GTH0_C/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net IN_GT_C_DOWN_1 [get_bd_intf_pins S_AXIS] [get_bd_intf_pins IN_CDC_GTH0_C/S_AXIS]
  connect_bd_intf_net -intf_net OUT_CDC_GTH0_C_M_AXIS [get_bd_intf_pins USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_C/M_AXIS]
  connect_bd_intf_net -intf_net aurora_8b10b_GTH0_C_USER_DATA_M_AXI_RX [get_bd_intf_pins OUT_CDC_GTH0_C/S_AXIS] [get_bd_intf_pins aurora_8b10b_GTH0_C/USER_DATA_M_AXI_RX]
  connect_bd_intf_net -intf_net [get_bd_intf_nets aurora_8b10b_GTH0_C_USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_C/S_AXIS] [get_bd_intf_pins ILA_GTHC/SLOT_0_AXIS]

  # Create port connections
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_refclk1_out  [get_bd_pins gt_refclk1] \
  [get_bd_pins aurora_8b10b_GTH0_C/gt_refclk1]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_reset_out  [get_bd_pins gt_reset] \
  [get_bd_pins aurora_8b10b_GTH0_C/gt_reset]
  connect_bd_net -net aurora_8b10b_GTH0_C_channel_up  [get_bd_pins aurora_8b10b_GTH0_C/channel_up] \
  [get_bd_pins channel_up] \
  [get_bd_pins ILA_GTHC/probe0]
  connect_bd_net -net aurora_8b10b_GTH0_C_crc_pass_fail_n  [get_bd_pins aurora_8b10b_GTH0_C/crc_pass_fail_n] \
  [get_bd_pins crc_pass_fail_n] \
  [get_bd_pins ILA_GTHC/probe1]
  connect_bd_net -net aurora_8b10b_GTH0_C_crc_valid  [get_bd_pins aurora_8b10b_GTH0_C/crc_valid] \
  [get_bd_pins crc_valid] \
  [get_bd_pins ILA_GTHC/probe2]
  connect_bd_net -net aurora_8b10b_GTH0_C_frame_err  [get_bd_pins aurora_8b10b_GTH0_C/frame_err] \
  [get_bd_pins frame_err] \
  [get_bd_pins ILA_GTHC/probe3]
  connect_bd_net -net aurora_8b10b_GTH0_C_gt_powergood  [get_bd_pins aurora_8b10b_GTH0_C/gt_powergood] \
  [get_bd_pins gt_powergood] \
  [get_bd_pins ILA_GTHC/probe14]
  connect_bd_net -net aurora_8b10b_GTH0_C_gt_reset_out  [get_bd_pins aurora_8b10b_GTH0_C/gt_reset_out] \
  [get_bd_pins ILA_GTHC/probe13]
  connect_bd_net -net aurora_8b10b_GTH0_C_hard_err  [get_bd_pins aurora_8b10b_GTH0_C/hard_err] \
  [get_bd_pins hard_err] \
  [get_bd_pins ILA_GTHC/probe4]
  connect_bd_net -net aurora_8b10b_GTH0_C_lane_up  [get_bd_pins aurora_8b10b_GTH0_C/lane_up] \
  [get_bd_pins lane_up] \
  [get_bd_pins ILA_GTHC/probe5]
  connect_bd_net -net aurora_8b10b_GTH0_C_link_reset_out  [get_bd_pins aurora_8b10b_GTH0_C/link_reset_out] \
  [get_bd_pins link_reset_out] \
  [get_bd_pins ILA_GTHC/probe11]
  connect_bd_net -net aurora_8b10b_GTH0_C_pll_not_locked_out  [get_bd_pins aurora_8b10b_GTH0_C/pll_not_locked_out] \
  [get_bd_pins pll_not_locked_out] \
  [get_bd_pins ILA_GTHC/probe6]
  connect_bd_net -net aurora_8b10b_GTH0_C_rx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_C/rx_resetdone_out] \
  [get_bd_pins rx_resetdone_out] \
  [get_bd_pins ILA_GTHC/probe7]
  connect_bd_net -net aurora_8b10b_GTH0_C_soft_err  [get_bd_pins aurora_8b10b_GTH0_C/soft_err] \
  [get_bd_pins soft_err] \
  [get_bd_pins ILA_GTHC/probe8]
  connect_bd_net -net aurora_8b10b_GTH0_C_sync_clk_out  [get_bd_pins aurora_8b10b_GTH0_C/sync_clk_out] \
  [get_bd_pins sync_clk_out]
  connect_bd_net -net aurora_8b10b_GTH0_C_sys_reset_out  [get_bd_pins aurora_8b10b_GTH0_C/sys_reset_out] \
  [get_bd_pins sys_reset_out] \
  [get_bd_pins ILA_GTHC/probe12]
  connect_bd_net -net aurora_8b10b_GTH0_C_tx_lock  [get_bd_pins aurora_8b10b_GTH0_C/tx_lock] \
  [get_bd_pins tx_lock] \
  [get_bd_pins ILA_GTHC/probe9]
  connect_bd_net -net aurora_8b10b_GTH0_C_tx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_C/tx_resetdone_out] \
  [get_bd_pins tx_resetdone_out] \
  [get_bd_pins ILA_GTHC/probe10]
  connect_bd_net -net aurora_8b10b_GTH0_C_user_clk_out  [get_bd_pins aurora_8b10b_GTH0_C/user_clk_out] \
  [get_bd_pins IN_CDC_GTH0_C/m_aclk] \
  [get_bd_pins OUT_CDC_GTH0_C/s_aclk] \
  [get_bd_pins ILA_GTHC/clk]
  connect_bd_net -net clk_wiz_0_INIT_CLK  [get_bd_pins init_clk_in] \
  [get_bd_pins aurora_8b10b_GTH0_C/init_clk_in]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins IN_CDC_GTH0_C/s_aresetn] \
  [get_bd_pins OUT_CDC_GTH0_C/s_aresetn] \
  [get_bd_pins ILA_GTHC/resetn]
  connect_bd_net -net rst_i_1  [get_bd_pins rst_i] \
  [get_bd_pins aurora_8b10b_GTH0_C/reset]
  connect_bd_net -net s_aclk_0_1  [get_bd_pins SYS_CLK] \
  [get_bd_pins IN_CDC_GTH0_C/s_aclk] \
  [get_bd_pins OUT_CDC_GTH0_C/m_aclk]
  connect_bd_net -net vio_0_probe_out0  [get_bd_pins loopback] \
  [get_bd_pins aurora_8b10b_GTH0_C/loopback]
  connect_bd_net -net vio_0_probe_out1  [get_bd_pins power_down] \
  [get_bd_pins aurora_8b10b_GTH0_C/power_down]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: GTHB
proc create_hier_cell_GTHB { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_GTHB() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 USER_DATA_S_AXI_TX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 USER_DATA_M_AXI_RX

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_1


  # Create pins
  create_bd_pin -dir O hard_err
  create_bd_pin -dir O soft_err
  create_bd_pin -dir O frame_err
  create_bd_pin -dir O channel_up
  create_bd_pin -dir O -from 0 -to 0 lane_up
  create_bd_pin -dir I rst_i
  create_bd_pin -dir I -type rst gt_reset
  create_bd_pin -dir I -from 0 -to 0 loopback
  create_bd_pin -dir O crc_valid
  create_bd_pin -dir O crc_pass_fail_n
  create_bd_pin -dir I -type rst power_down
  create_bd_pin -dir O tx_lock
  create_bd_pin -dir O tx_resetdone_out
  create_bd_pin -dir O rx_resetdone_out
  create_bd_pin -dir O -type rst link_reset_out
  create_bd_pin -dir I -type clk init_clk_in
  create_bd_pin -dir O pll_not_locked_out
  create_bd_pin -dir O -type rst sys_reset_out
  create_bd_pin -dir I -type clk gt_refclk1
  create_bd_pin -dir O -type clk sync_clk_out
  create_bd_pin -dir O -from 0 -to 0 gt_powergood
  create_bd_pin -dir I -type clk SYS_CLK
  create_bd_pin -dir I -type rst resetn

  # Create instance: aurora_8b10b_GTH0_B, and set properties
  set aurora_8b10b_GTH0_B [ create_bd_cell -type ip -vlnv xilinx.com:ip:aurora_8b10b:11.1 aurora_8b10b_GTH0_B ]
  set_property -dict [list \
    CONFIG.C_DRP_IF {false} \
    CONFIG.C_LANE_WIDTH {4} \
    CONFIG.C_LINE_RATE {6.25} \
    CONFIG.C_REFCLK_SOURCE {MGTREFCLK1 of Quad X0Y1} \
    CONFIG.C_START_LANE {X0Y5} \
    CONFIG.C_USE_CRC {true} \
    CONFIG.Flow_Mode {None} \
    CONFIG.SINGLEEND_GTREFCLK {true} \
    CONFIG.SupportLevel {1} \
  ] $aurora_8b10b_GTH0_B


  # Create instance: IN_CDC_GTH0_B, and set properties
  set IN_CDC_GTH0_B [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 IN_CDC_GTH0_B ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $IN_CDC_GTH0_B


  # Create instance: OUT_CDC_GTH0_B, and set properties
  set OUT_CDC_GTH0_B [ create_bd_cell -type ip -vlnv xilinx.com:ip:fifo_generator:13.2 OUT_CDC_GTH0_B ]
  set_property -dict [list \
    CONFIG.Clock_Type_AXI {Independent_Clock} \
    CONFIG.Enable_TLAST {true} \
    CONFIG.HAS_TKEEP {true} \
    CONFIG.INTERFACE_TYPE {AXI_STREAM} \
    CONFIG.TDATA_NUM_BYTES {4} \
    CONFIG.TUSER_WIDTH {0} \
  ] $OUT_CDC_GTH0_B


  # Create instance: ILA_GTHB, and set properties
  set ILA_GTHB [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 ILA_GTHB ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {MIX} \
    CONFIG.C_NUM_MONITOR_SLOTS {1} \
    CONFIG.C_NUM_OF_PROBES {15} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE10_TYPE {0} \
    CONFIG.C_PROBE11_TYPE {0} \
    CONFIG.C_PROBE12_TYPE {0} \
    CONFIG.C_PROBE13_TYPE {0} \
    CONFIG.C_PROBE14_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
    CONFIG.C_PROBE3_TYPE {0} \
    CONFIG.C_PROBE4_TYPE {0} \
    CONFIG.C_PROBE5_TYPE {0} \
    CONFIG.C_PROBE6_TYPE {0} \
    CONFIG.C_PROBE7_TYPE {0} \
    CONFIG.C_PROBE8_TYPE {0} \
    CONFIG.C_PROBE9_TYPE {0} \
    CONFIG.C_SLOT_0_APC_EN {0} \
    CONFIG.C_SLOT_0_AXI_DATA_SEL {1} \
    CONFIG.C_SLOT_0_AXI_TRIG_SEL {1} \
    CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
  ] $ILA_GTHB


  # Create interface connections
  connect_bd_intf_net -intf_net CDC_GTH0_A_M_AXIS [get_bd_intf_pins IN_CDC_GTH0_B/M_AXIS] [get_bd_intf_pins aurora_8b10b_GTH0_B/USER_DATA_S_AXI_TX]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins GT_SERIAL_RX_1] [get_bd_intf_pins aurora_8b10b_GTH0_B/GT_SERIAL_RX]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins GT_SERIAL_TX_1] [get_bd_intf_pins aurora_8b10b_GTH0_B/GT_SERIAL_TX]
  connect_bd_intf_net -intf_net IN_CDC_GTH0_B1_M_AXIS [get_bd_intf_pins USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_B/M_AXIS]
  connect_bd_intf_net -intf_net USER_DATA_S_AXI_TX_1 [get_bd_intf_pins USER_DATA_S_AXI_TX] [get_bd_intf_pins IN_CDC_GTH0_B/S_AXIS]
  connect_bd_intf_net -intf_net aurora_8b10b_GTH0_B_USER_DATA_M_AXI_RX [get_bd_intf_pins OUT_CDC_GTH0_B/S_AXIS] [get_bd_intf_pins aurora_8b10b_GTH0_B/USER_DATA_M_AXI_RX]
  connect_bd_intf_net -intf_net [get_bd_intf_nets aurora_8b10b_GTH0_B_USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_CDC_GTH0_B/S_AXIS] [get_bd_intf_pins ILA_GTHB/SLOT_0_AXIS]

  # Create port connections
  connect_bd_net -net SYS_CLK_1  [get_bd_pins SYS_CLK] \
  [get_bd_pins IN_CDC_GTH0_B/s_aclk] \
  [get_bd_pins OUT_CDC_GTH0_B/m_aclk]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_refclk1_out  [get_bd_pins gt_refclk1] \
  [get_bd_pins aurora_8b10b_GTH0_B/gt_refclk1]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_reset_out  [get_bd_pins gt_reset] \
  [get_bd_pins aurora_8b10b_GTH0_B/gt_reset]
  connect_bd_net -net aurora_8b10b_GTH0_B_channel_up  [get_bd_pins aurora_8b10b_GTH0_B/channel_up] \
  [get_bd_pins channel_up] \
  [get_bd_pins ILA_GTHB/probe0]
  connect_bd_net -net aurora_8b10b_GTH0_B_crc_pass_fail_n  [get_bd_pins aurora_8b10b_GTH0_B/crc_pass_fail_n] \
  [get_bd_pins crc_pass_fail_n] \
  [get_bd_pins ILA_GTHB/probe1]
  connect_bd_net -net aurora_8b10b_GTH0_B_crc_valid  [get_bd_pins aurora_8b10b_GTH0_B/crc_valid] \
  [get_bd_pins crc_valid] \
  [get_bd_pins ILA_GTHB/probe2]
  connect_bd_net -net aurora_8b10b_GTH0_B_frame_err  [get_bd_pins aurora_8b10b_GTH0_B/frame_err] \
  [get_bd_pins frame_err] \
  [get_bd_pins ILA_GTHB/probe3]
  connect_bd_net -net aurora_8b10b_GTH0_B_gt_powergood  [get_bd_pins aurora_8b10b_GTH0_B/gt_powergood] \
  [get_bd_pins gt_powergood] \
  [get_bd_pins ILA_GTHB/probe14]
  connect_bd_net -net aurora_8b10b_GTH0_B_gt_reset_out  [get_bd_pins aurora_8b10b_GTH0_B/gt_reset_out] \
  [get_bd_pins ILA_GTHB/probe13]
  connect_bd_net -net aurora_8b10b_GTH0_B_hard_err  [get_bd_pins aurora_8b10b_GTH0_B/hard_err] \
  [get_bd_pins hard_err] \
  [get_bd_pins ILA_GTHB/probe4]
  connect_bd_net -net aurora_8b10b_GTH0_B_lane_up  [get_bd_pins aurora_8b10b_GTH0_B/lane_up] \
  [get_bd_pins lane_up] \
  [get_bd_pins ILA_GTHB/probe5]
  connect_bd_net -net aurora_8b10b_GTH0_B_link_reset_out  [get_bd_pins aurora_8b10b_GTH0_B/link_reset_out] \
  [get_bd_pins link_reset_out] \
  [get_bd_pins ILA_GTHB/probe11]
  connect_bd_net -net aurora_8b10b_GTH0_B_pll_not_locked_out  [get_bd_pins aurora_8b10b_GTH0_B/pll_not_locked_out] \
  [get_bd_pins pll_not_locked_out] \
  [get_bd_pins ILA_GTHB/probe6]
  connect_bd_net -net aurora_8b10b_GTH0_B_rx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_B/rx_resetdone_out] \
  [get_bd_pins rx_resetdone_out] \
  [get_bd_pins ILA_GTHB/probe7]
  connect_bd_net -net aurora_8b10b_GTH0_B_soft_err  [get_bd_pins aurora_8b10b_GTH0_B/soft_err] \
  [get_bd_pins soft_err] \
  [get_bd_pins ILA_GTHB/probe8]
  connect_bd_net -net aurora_8b10b_GTH0_B_sync_clk_out  [get_bd_pins aurora_8b10b_GTH0_B/sync_clk_out] \
  [get_bd_pins sync_clk_out]
  connect_bd_net -net aurora_8b10b_GTH0_B_sys_reset_out  [get_bd_pins aurora_8b10b_GTH0_B/sys_reset_out] \
  [get_bd_pins sys_reset_out] \
  [get_bd_pins ILA_GTHB/probe12]
  connect_bd_net -net aurora_8b10b_GTH0_B_tx_lock  [get_bd_pins aurora_8b10b_GTH0_B/tx_lock] \
  [get_bd_pins tx_lock] \
  [get_bd_pins ILA_GTHB/probe9]
  connect_bd_net -net aurora_8b10b_GTH0_B_tx_resetdone_out  [get_bd_pins aurora_8b10b_GTH0_B/tx_resetdone_out] \
  [get_bd_pins tx_resetdone_out] \
  [get_bd_pins ILA_GTHB/probe10]
  connect_bd_net -net aurora_8b10b_GTH0_B_user_clk_out  [get_bd_pins aurora_8b10b_GTH0_B/user_clk_out] \
  [get_bd_pins IN_CDC_GTH0_B/m_aclk] \
  [get_bd_pins OUT_CDC_GTH0_B/s_aclk] \
  [get_bd_pins ILA_GTHB/clk]
  connect_bd_net -net clk_wiz_0_INIT_CLK  [get_bd_pins init_clk_in] \
  [get_bd_pins aurora_8b10b_GTH0_B/init_clk_in]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins IN_CDC_GTH0_B/s_aresetn] \
  [get_bd_pins OUT_CDC_GTH0_B/s_aresetn] \
  [get_bd_pins ILA_GTHB/resetn]
  connect_bd_net -net rst_i_1  [get_bd_pins rst_i] \
  [get_bd_pins aurora_8b10b_GTH0_B/reset]
  connect_bd_net -net vio_0_probe_out0  [get_bd_pins loopback] \
  [get_bd_pins aurora_8b10b_GTH0_B/loopback]
  connect_bd_net -net vio_0_probe_out1  [get_bd_pins power_down] \
  [get_bd_pins aurora_8b10b_GTH0_B/power_down]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: STATUS_REG
proc create_hier_cell_STATUS_REG { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_STATUS_REG() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s00_axi


  # Create pins
  create_bd_pin -dir I -from 31 -to 0 static_in_00
  create_bd_pin -dir I -from 31 -to 0 static_in_01
  create_bd_pin -dir I -from 31 -to 0 static_in_02
  create_bd_pin -dir I -from 31 -to 0 static_in_03
  create_bd_pin -dir I -from 31 -to 0 static_in_04
  create_bd_pin -dir I -from 0 -to 0 static_in_05
  create_bd_pin -dir I -from 31 -to 0 static_in_06
  create_bd_pin -dir I -from 31 -to 0 static_in_07
  create_bd_pin -dir I -from 31 -to 0 static_in_08
  create_bd_pin -dir I -from 31 -to 0 static_in_09
  create_bd_pin -dir I -from 31 -to 0 static_in_10
  create_bd_pin -dir I -from 31 -to 0 static_in_11
  create_bd_pin -dir I -from 31 -to 0 static_in_12
  create_bd_pin -dir I -from 31 -to 0 static_in_13
  create_bd_pin -dir I -from 0 -to 0 static_in_14
  create_bd_pin -dir I -from 31 -to 0 static_in_15
  create_bd_pin -dir I -from 31 -to 0 static_in_16
  create_bd_pin -dir I -from 31 -to 0 static_in_17
  create_bd_pin -dir I -from 31 -to 0 static_in_18
  create_bd_pin -dir I -from 31 -to 0 static_in_19
  create_bd_pin -dir I -from 0 -to 0 static_in_20
  create_bd_pin -dir I -from 31 -to 0 static_in_21
  create_bd_pin -dir I -from 31 -to 0 static_in_22
  create_bd_pin -dir I -from 31 -to 0 static_in_23
  create_bd_pin -dir I -from 31 -to 0 static_in_24
  create_bd_pin -dir I -from 31 -to 0 static_in_25
  create_bd_pin -dir I -from 31 -to 0 static_in_26
  create_bd_pin -dir I -from 31 -to 0 static_in_27
  create_bd_pin -dir I -from 31 -to 0 static_in_28
  create_bd_pin -dir I -from 0 -to 0 static_in_29
  create_bd_pin -dir I -from 31 -to 0 static_in_30
  create_bd_pin -dir I -from 31 -to 0 static_in_31
  create_bd_pin -dir I -from 31 -to 0 static_in_32
  create_bd_pin -dir I -from 31 -to 0 static_in_33
  create_bd_pin -dir I -from 31 -to 0 static_in_34
  create_bd_pin -dir I -from 0 -to 0 static_in_35
  create_bd_pin -dir I -from 31 -to 0 static_in_36
  create_bd_pin -dir I -from 31 -to 0 static_in_37
  create_bd_pin -dir I -from 31 -to 0 static_in_38
  create_bd_pin -dir I -from 31 -to 0 static_in_39
  create_bd_pin -dir I -from 31 -to 0 static_in_40
  create_bd_pin -dir I -from 31 -to 0 static_in_41
  create_bd_pin -dir I -from 31 -to 0 static_in_42
  create_bd_pin -dir I -from 31 -to 0 static_in_43
  create_bd_pin -dir I -from 0 -to 0 static_in_44
  create_bd_pin -dir I -from 31 -to 0 static_in_45
  create_bd_pin -dir I -from 31 -to 0 static_in_46
  create_bd_pin -dir I -from 31 -to 0 static_in_47
  create_bd_pin -dir I -from 31 -to 0 static_in_48
  create_bd_pin -dir I -from 31 -to 0 static_in_49
  create_bd_pin -dir I -from 0 -to 0 static_in_50
  create_bd_pin -dir I -from 31 -to 0 static_in_51
  create_bd_pin -dir I -from 31 -to 0 static_in_52
  create_bd_pin -dir I -from 31 -to 0 static_in_53
  create_bd_pin -dir I -from 31 -to 0 static_in_54
  create_bd_pin -dir I -from 31 -to 0 static_in_55
  create_bd_pin -dir I -from 31 -to 0 static_in_56
  create_bd_pin -dir I -from 31 -to 0 static_in_57
  create_bd_pin -dir I -from 31 -to 0 static_in_58
  create_bd_pin -dir I -from 0 -to 0 static_in_59
  create_bd_pin -dir I -type clk clk_in1
  create_bd_pin -dir I -type rst resetn
  create_bd_pin -dir I clk_out_i
  create_bd_pin -dir I USER_CLK_O

  # Create instance: axil_static_regs_vhd_0, and set properties
  set block_name axil_static_regs_vhdl93
  set block_cell_name axil_static_regs_vhd_0
  if { [catch {set axil_static_regs_vhd_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $axil_static_regs_vhd_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: USER_CLK, and set properties
  set block_name frequency_measurement
  set block_cell_name USER_CLK
  if { [catch {set USER_CLK [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $USER_CLK eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.CLK_OSC_FREQUENCY {156250000} $USER_CLK


  # Create instance: SYS_CLK, and set properties
  set block_name frequency_measurement
  set block_cell_name SYS_CLK
  if { [catch {set SYS_CLK [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $SYS_CLK eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.CLK_OSC_FREQUENCY {156250000} $SYS_CLK


  # Create instance: INIT_CLK, and set properties
  set block_name frequency_measurement
  set block_cell_name INIT_CLK
  if { [catch {set INIT_CLK [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $INIT_CLK eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.CLK_OSC_FREQUENCY {300000000} $INIT_CLK


  # Create instance: system_ila_0, and set properties
  set system_ila_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila:1.1 system_ila_0 ]
  set_property -dict [list \
    CONFIG.C_MON_TYPE {NATIVE} \
    CONFIG.C_NUM_OF_PROBES {3} \
    CONFIG.C_PROBE0_TYPE {0} \
    CONFIG.C_PROBE1_TYPE {0} \
    CONFIG.C_PROBE2_TYPE {0} \
  ] $system_ila_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn23 [get_bd_intf_pins s00_axi] [get_bd_intf_pins axil_static_regs_vhd_0/s00_axi]

  # Create port connections
  connect_bd_net -net INIT_CLK_result_o  [get_bd_pins INIT_CLK/result_o] \
  [get_bd_pins system_ila_0/probe0] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_89]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets INIT_CLK_result_o]
  connect_bd_net -net SYS_CLK_result_o  [get_bd_pins SYS_CLK/result_o] \
  [get_bd_pins system_ila_0/probe1] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_90]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets SYS_CLK_result_o]
  connect_bd_net -net USER_CLK_O_1  [get_bd_pins USER_CLK_O] \
  [get_bd_pins USER_CLK/clk_meas_i]
  connect_bd_net -net USER_CLK_result_o  [get_bd_pins USER_CLK/result_o] \
  [get_bd_pins system_ila_0/probe2] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_91]
  set_property HDL_ATTRIBUTE.DEBUG {true} [get_bd_nets USER_CLK_result_o]
  connect_bd_net -net aurora_8b10b_GTH0_A_channel_up  [get_bd_pins static_in_00] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_00]
  connect_bd_net -net aurora_8b10b_GTH0_A_crc_pass_fail_n  [get_bd_pins static_in_01] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_01]
  connect_bd_net -net aurora_8b10b_GTH0_A_crc_valid  [get_bd_pins static_in_02] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_02]
  connect_bd_net -net aurora_8b10b_GTH0_A_frame_err  [get_bd_pins static_in_03] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_03]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_powergood  [get_bd_pins static_in_14] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_14]
  connect_bd_net -net aurora_8b10b_GTH0_A_hard_err  [get_bd_pins static_in_04] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_04]
  connect_bd_net -net aurora_8b10b_GTH0_A_lane_up  [get_bd_pins static_in_05] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_05]
  connect_bd_net -net aurora_8b10b_GTH0_A_link_reset_out  [get_bd_pins static_in_11] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_11]
  connect_bd_net -net aurora_8b10b_GTH0_A_pll_not_locked_out  [get_bd_pins static_in_06] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_06]
  connect_bd_net -net aurora_8b10b_GTH0_A_rx_resetdone_out  [get_bd_pins static_in_07] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_07]
  connect_bd_net -net aurora_8b10b_GTH0_A_soft_err  [get_bd_pins static_in_08] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_08]
  connect_bd_net -net aurora_8b10b_GTH0_A_sync_clk_out  [get_bd_pins static_in_13] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_13]
  connect_bd_net -net aurora_8b10b_GTH0_A_sys_reset_out  [get_bd_pins static_in_12] \
  [get_bd_pins INIT_CLK/rst_i] \
  [get_bd_pins SYS_CLK/rst_i] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_12] \
  [get_bd_pins USER_CLK/rst_i]
  connect_bd_net -net aurora_8b10b_GTH0_A_tx_lock  [get_bd_pins static_in_09] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_09]
  connect_bd_net -net aurora_8b10b_GTH0_A_tx_resetdone_out  [get_bd_pins static_in_10] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_10]
  connect_bd_net -net aurora_8b10b_GTH0_B_channel_up  [get_bd_pins static_in_15] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_15]
  connect_bd_net -net aurora_8b10b_GTH0_B_crc_pass_fail_n  [get_bd_pins static_in_16] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_16]
  connect_bd_net -net aurora_8b10b_GTH0_B_crc_valid  [get_bd_pins static_in_17] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_17]
  connect_bd_net -net aurora_8b10b_GTH0_B_frame_err  [get_bd_pins static_in_18] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_18]
  connect_bd_net -net aurora_8b10b_GTH0_B_gt_powergood  [get_bd_pins static_in_29] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_29]
  connect_bd_net -net aurora_8b10b_GTH0_B_hard_err  [get_bd_pins static_in_19] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_19]
  connect_bd_net -net aurora_8b10b_GTH0_B_lane_up  [get_bd_pins static_in_20] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_20]
  connect_bd_net -net aurora_8b10b_GTH0_B_link_reset_out  [get_bd_pins static_in_26] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_26]
  connect_bd_net -net aurora_8b10b_GTH0_B_pll_not_locked_out  [get_bd_pins static_in_21] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_21]
  connect_bd_net -net aurora_8b10b_GTH0_B_rx_resetdone_out  [get_bd_pins static_in_22] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_22]
  connect_bd_net -net aurora_8b10b_GTH0_B_soft_err  [get_bd_pins static_in_23] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_23]
  connect_bd_net -net aurora_8b10b_GTH0_B_sync_clk_out  [get_bd_pins static_in_28] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_28]
  connect_bd_net -net aurora_8b10b_GTH0_B_sys_reset_out  [get_bd_pins static_in_27] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_27]
  connect_bd_net -net aurora_8b10b_GTH0_B_tx_lock  [get_bd_pins static_in_24] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_24]
  connect_bd_net -net aurora_8b10b_GTH0_B_tx_resetdone_out  [get_bd_pins static_in_25] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_25]
  connect_bd_net -net aurora_8b10b_GTH0_C_channel_up  [get_bd_pins static_in_30] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_30]
  connect_bd_net -net aurora_8b10b_GTH0_C_crc_pass_fail_n  [get_bd_pins static_in_31] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_31]
  connect_bd_net -net aurora_8b10b_GTH0_C_crc_valid  [get_bd_pins static_in_32] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_32]
  connect_bd_net -net aurora_8b10b_GTH0_C_frame_err  [get_bd_pins static_in_33] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_33]
  connect_bd_net -net aurora_8b10b_GTH0_C_gt_powergood  [get_bd_pins static_in_44] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_44]
  connect_bd_net -net aurora_8b10b_GTH0_C_hard_err  [get_bd_pins static_in_34] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_34]
  connect_bd_net -net aurora_8b10b_GTH0_C_lane_up  [get_bd_pins static_in_35] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_35]
  connect_bd_net -net aurora_8b10b_GTH0_C_link_reset_out  [get_bd_pins static_in_41] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_41]
  connect_bd_net -net aurora_8b10b_GTH0_C_pll_not_locked_out  [get_bd_pins static_in_36] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_36]
  connect_bd_net -net aurora_8b10b_GTH0_C_rx_resetdone_out  [get_bd_pins static_in_37] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_37]
  connect_bd_net -net aurora_8b10b_GTH0_C_soft_err  [get_bd_pins static_in_38] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_38]
  connect_bd_net -net aurora_8b10b_GTH0_C_sync_clk_out  [get_bd_pins static_in_43] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_43]
  connect_bd_net -net aurora_8b10b_GTH0_C_sys_reset_out  [get_bd_pins static_in_42] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_42]
  connect_bd_net -net aurora_8b10b_GTH0_C_tx_lock  [get_bd_pins static_in_39] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_39]
  connect_bd_net -net aurora_8b10b_GTH0_C_tx_resetdone_out  [get_bd_pins static_in_40] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_40]
  connect_bd_net -net aurora_8b10b_GTH0_D_channel_up  [get_bd_pins static_in_45] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_45]
  connect_bd_net -net aurora_8b10b_GTH0_D_crc_pass_fail_n  [get_bd_pins static_in_46] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_46]
  connect_bd_net -net aurora_8b10b_GTH0_D_crc_valid  [get_bd_pins static_in_47] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_47]
  connect_bd_net -net aurora_8b10b_GTH0_D_frame_err  [get_bd_pins static_in_48] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_48]
  connect_bd_net -net aurora_8b10b_GTH0_D_gt_powergood  [get_bd_pins static_in_59] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_59]
  connect_bd_net -net aurora_8b10b_GTH0_D_hard_err  [get_bd_pins static_in_49] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_49]
  connect_bd_net -net aurora_8b10b_GTH0_D_lane_up  [get_bd_pins static_in_50] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_50]
  connect_bd_net -net aurora_8b10b_GTH0_D_link_reset_out  [get_bd_pins static_in_56] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_56]
  connect_bd_net -net aurora_8b10b_GTH0_D_pll_not_locked_out  [get_bd_pins static_in_51] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_51]
  connect_bd_net -net aurora_8b10b_GTH0_D_rx_resetdone_out  [get_bd_pins static_in_52] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_52]
  connect_bd_net -net aurora_8b10b_GTH0_D_soft_err  [get_bd_pins static_in_53] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_53]
  connect_bd_net -net aurora_8b10b_GTH0_D_sync_clk_out  [get_bd_pins static_in_58] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_58]
  connect_bd_net -net aurora_8b10b_GTH0_D_sys_reset_out  [get_bd_pins static_in_57] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_57]
  connect_bd_net -net aurora_8b10b_GTH0_D_tx_lock  [get_bd_pins static_in_54] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_54]
  connect_bd_net -net aurora_8b10b_GTH0_D_tx_resetdone_out  [get_bd_pins static_in_55] \
  [get_bd_pins axil_static_regs_vhd_0/static_in_55]
  connect_bd_net -net clk_in1_1  [get_bd_pins clk_in1] \
  [get_bd_pins system_ila_0/clk] \
  [get_bd_pins INIT_CLK/clk_osc_i] \
  [get_bd_pins INIT_CLK/clk_out_i] \
  [get_bd_pins SYS_CLK/clk_meas_i] \
  [get_bd_pins axil_static_regs_vhd_0/s00_axi_aclk]
  connect_bd_net -net clk_out_i_1  [get_bd_pins clk_out_i] \
  [get_bd_pins INIT_CLK/clk_meas_i] \
  [get_bd_pins SYS_CLK/clk_osc_i] \
  [get_bd_pins SYS_CLK/clk_out_i] \
  [get_bd_pins USER_CLK/clk_osc_i] \
  [get_bd_pins USER_CLK/clk_out_i]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins axil_static_regs_vhd_0/s00_axi_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: Project
proc create_hier_cell_Project { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Project() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 IN_GT_B_LEFT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 IN_GT_A_UP

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 DMA_M00_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 OUT_GT_C_DOWN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 OUT_GT_D_RIGHT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi_control

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE


  # Create pins
  create_bd_pin -dir I -type clk SYS_CLK
  create_bd_pin -dir I -type rst ap_rst_n
  create_bd_pin -dir I -from 31 -to 0 DMA_MUX_SEL_i

  # Create instance: axis_broadcaster_0, and set properties
  set axis_broadcaster_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_broadcaster:1.1 axis_broadcaster_0 ]
  set_property -dict [list \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TREADY {1} \
    CONFIG.HAS_TSTRB {1} \
    CONFIG.M_TDATA_NUM_BYTES {4} \
    CONFIG.M_TUSER_WIDTH {0} \
    CONFIG.S_TDATA_NUM_BYTES {4} \
    CONFIG.S_TUSER_WIDTH {0} \
    CONFIG.TDEST_WIDTH {0} \
    CONFIG.TID_WIDTH {0} \
  ] $axis_broadcaster_0


  # Create instance: dma_mux_inst, and set properties
  set block_name saxis_mux
  set block_cell_name dma_mux_inst
  if { [catch {set dma_mux_inst [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dma_mux_inst eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: sa_grid_0, and set properties
  set sa_grid_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:sa_grid:1.0 sa_grid_0 ]

  # Create instance: axi_smc_1, and set properties
  set axi_smc_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc_1 ]
  set_property CONFIG.NUM_SI {2} $axi_smc_1


  # Create instance: axis_data_fifo_down, and set properties
  set axis_data_fifo_down [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_down ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {32} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {1} \
    CONFIG.TDATA_NUM_BYTES {4} \
  ] $axis_data_fifo_down


  # Create instance: axis_data_fifo_right, and set properties
  set axis_data_fifo_right [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 axis_data_fifo_right ]
  set_property -dict [list \
    CONFIG.FIFO_DEPTH {32} \
    CONFIG.HAS_TKEEP {1} \
    CONFIG.HAS_TLAST {1} \
    CONFIG.HAS_TSTRB {1} \
    CONFIG.TDATA_NUM_BYTES {4} \
  ] $axis_data_fifo_right


  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [list \
    CONFIG.c_addr_width {40} \
    CONFIG.c_include_sg {0} \
    CONFIG.c_sg_length_width {26} \
  ] $axi_dma_0


  # Create interface connections
  connect_bd_intf_net -intf_net AURORA_OUT_GT_A_UP [get_bd_intf_pins IN_GT_A_UP] [get_bd_intf_pins sa_grid_0/in_up]
  connect_bd_intf_net -intf_net AURORA_OUT_GT_B_LEFT [get_bd_intf_pins IN_GT_B_LEFT] [get_bd_intf_pins dma_mux_inst/S0_AXIS]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins dma_mux_inst/S1_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_smc_1/S00_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins axi_smc_1/S01_AXI]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins DMA_M00_AXI] [get_bd_intf_pins axi_smc_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins S_AXI_LITE]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins sa_grid_0/s_axi_control] [get_bd_intf_pins s_axi_control]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M00_AXIS [get_bd_intf_pins axis_broadcaster_0/M00_AXIS] [get_bd_intf_pins axis_data_fifo_down/S_AXIS]
  connect_bd_intf_net -intf_net axis_broadcaster_0_M01_AXIS [get_bd_intf_pins axis_broadcaster_0/M01_AXIS] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axis_data_fifo_down_M_AXIS [get_bd_intf_pins OUT_GT_C_DOWN] [get_bd_intf_pins axis_data_fifo_down/M_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_right_M_AXIS [get_bd_intf_pins OUT_GT_D_RIGHT] [get_bd_intf_pins axis_data_fifo_right/M_AXIS]
  connect_bd_intf_net -intf_net dma_mux_inst_M_AXIS [get_bd_intf_pins dma_mux_inst/M_AXIS] [get_bd_intf_pins sa_grid_0/in_left]
  connect_bd_intf_net -intf_net sa_grid_0_out_down [get_bd_intf_pins sa_grid_0/out_down] [get_bd_intf_pins axis_broadcaster_0/S_AXIS]
  connect_bd_intf_net -intf_net sa_grid_0_out_right [get_bd_intf_pins axis_data_fifo_right/S_AXIS] [get_bd_intf_pins sa_grid_0/out_right]

  # Create port connections
  connect_bd_net -net DMA_MUX_SEL_i_1  [get_bd_pins DMA_MUX_SEL_i] \
  [get_bd_pins dma_mux_inst/sel_i]
  connect_bd_net -net Net1  [get_bd_pins ap_rst_n] \
  [get_bd_pins sa_grid_0/ap_rst_n] \
  [get_bd_pins axis_data_fifo_right/s_axis_aresetn] \
  [get_bd_pins axis_data_fifo_down/s_axis_aresetn] \
  [get_bd_pins axis_broadcaster_0/aresetn] \
  [get_bd_pins axi_smc_1/aresetn] \
  [get_bd_pins axi_dma_0/axi_resetn] \
  [get_bd_pins dma_mux_inst/rst_i]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0  [get_bd_pins SYS_CLK] \
  [get_bd_pins axi_smc_1/aclk] \
  [get_bd_pins axi_dma_0/s_axi_lite_aclk] \
  [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] \
  [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] \
  [get_bd_pins sa_grid_0/ap_clk] \
  [get_bd_pins axis_data_fifo_down/s_axis_aclk] \
  [get_bd_pins axis_data_fifo_right/s_axis_aclk] \
  [get_bd_pins axis_broadcaster_0/aclk] \
  [get_bd_pins dma_mux_inst/clk_i]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: AURORA
proc create_hier_cell_AURORA { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_AURORA() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_2

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_2

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_3

  create_bd_intf_pin -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_3

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DIFF_REFCLK1_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 IN_GT_D_RIGHT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 IN_GT_B_LEFT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 IN_GT_C_DOWN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 IN_GT_A_UP

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 OUT_GT_A_UP

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 OUT_GT_B_LEFT

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 OUT_GT_C_DOWN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 OUT_GT_D_RIGHT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s00_axi


  # Create pins
  create_bd_pin -dir I -type rst resetn
  create_bd_pin -dir I rst_i
  create_bd_pin -dir I -type clk SYS_CLK

  # Create instance: clk_wiz_0, and set properties
  set clk_wiz_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_0 ]
  set_property -dict [list \
    CONFIG.CLKOUT1_JITTER {191.759} \
    CONFIG.CLKOUT1_PHASE_ERROR {348.339} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {156.25} \
    CONFIG.CLK_OUT1_PORT {INIT_CLK} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {96.875} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {7.750} \
    CONFIG.MMCM_DIVCLK_DIVIDE {24} \
    CONFIG.RESET_PORT {resetn} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
  ] $clk_wiz_0


  # Create instance: gt_reset_0, and set properties
  set block_name gt_reset
  set block_cell_name gt_reset_0
  if { [catch {set gt_reset_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $gt_reset_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: vio_0, and set properties
  set vio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:vio:3.0 vio_0 ]
  set_property -dict [list \
    CONFIG.C_NUM_PROBE_IN {0} \
    CONFIG.C_NUM_PROBE_OUT {2} \
  ] $vio_0


  # Create instance: STATUS_REG
  create_hier_cell_STATUS_REG $hier_obj STATUS_REG

  # Create instance: GTHB
  create_hier_cell_GTHB $hier_obj GTHB

  # Create instance: GTHC
  create_hier_cell_GTHC $hier_obj GTHC

  # Create instance: GTHA
  create_hier_cell_GTHA $hier_obj GTHA

  # Create instance: GTHD
  create_hier_cell_GTHD $hier_obj GTHD

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins GTHA/GT_SERIAL_RX_0] [get_bd_intf_pins GT_SERIAL_RX_0]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins GTHA/GT_SERIAL_TX_0] [get_bd_intf_pins GT_SERIAL_TX_0]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins GTHB/GT_SERIAL_RX_1] [get_bd_intf_pins GT_SERIAL_RX_1]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins GTHB/GT_SERIAL_TX_1] [get_bd_intf_pins GT_SERIAL_TX_1]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins GTHD/GT_SERIAL_RX_2] [get_bd_intf_pins GT_SERIAL_RX_2]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins GTHD/GT_SERIAL_TX_2] [get_bd_intf_pins GT_SERIAL_TX_2]
  connect_bd_intf_net -intf_net Conn7 [get_bd_intf_pins GTHC/GT_SERIAL_RX_3] [get_bd_intf_pins GT_SERIAL_RX_3]
  connect_bd_intf_net -intf_net Conn8 [get_bd_intf_pins GTHC/GT_SERIAL_TX_3] [get_bd_intf_pins GT_SERIAL_TX_3]
  connect_bd_intf_net -intf_net Conn9 [get_bd_intf_pins GTHA/GT_DIFF_REFCLK1_0] [get_bd_intf_pins GT_DIFF_REFCLK1_0]
  connect_bd_intf_net -intf_net Conn10 [get_bd_intf_pins GTHD/USER_DATA_S_AXI_TX] [get_bd_intf_pins IN_GT_D_RIGHT]
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins GTHB/USER_DATA_S_AXI_TX] [get_bd_intf_pins IN_GT_B_LEFT]
  connect_bd_intf_net -intf_net Conn13 [get_bd_intf_pins GTHA/S_AXIS] [get_bd_intf_pins IN_GT_A_UP]
  connect_bd_intf_net -intf_net Conn14 [get_bd_intf_pins GTHA/USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_GT_A_UP]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins GTHB/USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_GT_B_LEFT]
  connect_bd_intf_net -intf_net Conn16 [get_bd_intf_pins GTHC/USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_GT_C_DOWN]
  connect_bd_intf_net -intf_net Conn17 [get_bd_intf_pins GTHD/USER_DATA_M_AXI_RX] [get_bd_intf_pins OUT_GT_D_RIGHT]
  connect_bd_intf_net -intf_net Conn23 [get_bd_intf_pins STATUS_REG/s00_axi] [get_bd_intf_pins s00_axi]
  connect_bd_intf_net -intf_net IN_GT_C_DOWN_1 [get_bd_intf_pins IN_GT_C_DOWN] [get_bd_intf_pins GTHC/S_AXIS]

  # Create port connections
  connect_bd_net -net aurora_8b10b_GTH0_A_channel_up  [get_bd_pins GTHA/channel_up] \
  [get_bd_pins STATUS_REG/static_in_00]
  connect_bd_net -net aurora_8b10b_GTH0_A_crc_pass_fail_n  [get_bd_pins GTHA/crc_pass_fail_n] \
  [get_bd_pins STATUS_REG/static_in_01]
  connect_bd_net -net aurora_8b10b_GTH0_A_crc_valid  [get_bd_pins GTHA/crc_valid] \
  [get_bd_pins STATUS_REG/static_in_02]
  connect_bd_net -net aurora_8b10b_GTH0_A_frame_err  [get_bd_pins GTHA/frame_err] \
  [get_bd_pins STATUS_REG/static_in_03]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_powergood  [get_bd_pins GTHA/gt_powergood] \
  [get_bd_pins STATUS_REG/static_in_14]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_refclk1_out  [get_bd_pins GTHA/gt_refclk1_out] \
  [get_bd_pins GTHB/gt_refclk1] \
  [get_bd_pins GTHC/gt_refclk1] \
  [get_bd_pins GTHD/gt_refclk1]
  connect_bd_net -net aurora_8b10b_GTH0_A_gt_reset_out  [get_bd_pins GTHA/gt_reset_out] \
  [get_bd_pins GTHB/gt_reset] \
  [get_bd_pins GTHC/gt_reset] \
  [get_bd_pins GTHD/gt_reset]
  connect_bd_net -net aurora_8b10b_GTH0_A_hard_err  [get_bd_pins GTHA/hard_err] \
  [get_bd_pins STATUS_REG/static_in_04]
  connect_bd_net -net aurora_8b10b_GTH0_A_lane_up  [get_bd_pins GTHA/lane_up] \
  [get_bd_pins STATUS_REG/static_in_05]
  connect_bd_net -net aurora_8b10b_GTH0_A_link_reset_out  [get_bd_pins GTHA/link_reset_out] \
  [get_bd_pins STATUS_REG/static_in_11]
  connect_bd_net -net aurora_8b10b_GTH0_A_pll_not_locked_out  [get_bd_pins GTHA/pll_not_locked_out] \
  [get_bd_pins STATUS_REG/static_in_06]
  connect_bd_net -net aurora_8b10b_GTH0_A_rx_resetdone_out  [get_bd_pins GTHA/rx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_07]
  connect_bd_net -net aurora_8b10b_GTH0_A_soft_err  [get_bd_pins GTHA/soft_err] \
  [get_bd_pins STATUS_REG/static_in_08]
  connect_bd_net -net aurora_8b10b_GTH0_A_sync_clk_out  [get_bd_pins GTHA/sync_clk_out] \
  [get_bd_pins STATUS_REG/static_in_13]
  connect_bd_net -net aurora_8b10b_GTH0_A_sys_reset_out  [get_bd_pins GTHA/sys_reset_out] \
  [get_bd_pins STATUS_REG/static_in_12] \
  [get_bd_pins GTHC/rst_i] \
  [get_bd_pins GTHD/rst_i] \
  [get_bd_pins GTHB/rst_i]
  connect_bd_net -net aurora_8b10b_GTH0_A_tx_lock  [get_bd_pins GTHA/tx_lock] \
  [get_bd_pins STATUS_REG/static_in_09]
  connect_bd_net -net aurora_8b10b_GTH0_A_tx_resetdone_out  [get_bd_pins GTHA/tx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_10]
  connect_bd_net -net aurora_8b10b_GTH0_A_user_clk_out  [get_bd_pins GTHA/USER_CLK_O] \
  [get_bd_pins STATUS_REG/USER_CLK_O]
  connect_bd_net -net aurora_8b10b_GTH0_B_channel_up  [get_bd_pins GTHB/channel_up] \
  [get_bd_pins STATUS_REG/static_in_15]
  connect_bd_net -net aurora_8b10b_GTH0_B_crc_pass_fail_n  [get_bd_pins GTHB/crc_pass_fail_n] \
  [get_bd_pins STATUS_REG/static_in_16]
  connect_bd_net -net aurora_8b10b_GTH0_B_crc_valid  [get_bd_pins GTHB/crc_valid] \
  [get_bd_pins STATUS_REG/static_in_17]
  connect_bd_net -net aurora_8b10b_GTH0_B_frame_err  [get_bd_pins GTHB/frame_err] \
  [get_bd_pins STATUS_REG/static_in_18]
  connect_bd_net -net aurora_8b10b_GTH0_B_gt_powergood  [get_bd_pins GTHB/gt_powergood] \
  [get_bd_pins STATUS_REG/static_in_29]
  connect_bd_net -net aurora_8b10b_GTH0_B_hard_err  [get_bd_pins GTHB/hard_err] \
  [get_bd_pins STATUS_REG/static_in_19]
  connect_bd_net -net aurora_8b10b_GTH0_B_lane_up  [get_bd_pins GTHB/lane_up] \
  [get_bd_pins STATUS_REG/static_in_20]
  connect_bd_net -net aurora_8b10b_GTH0_B_link_reset_out  [get_bd_pins GTHB/link_reset_out] \
  [get_bd_pins STATUS_REG/static_in_26]
  connect_bd_net -net aurora_8b10b_GTH0_B_pll_not_locked_out  [get_bd_pins GTHB/pll_not_locked_out] \
  [get_bd_pins STATUS_REG/static_in_21]
  connect_bd_net -net aurora_8b10b_GTH0_B_rx_resetdone_out  [get_bd_pins GTHB/rx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_22]
  connect_bd_net -net aurora_8b10b_GTH0_B_soft_err  [get_bd_pins GTHB/soft_err] \
  [get_bd_pins STATUS_REG/static_in_23]
  connect_bd_net -net aurora_8b10b_GTH0_B_sync_clk_out  [get_bd_pins GTHB/sync_clk_out] \
  [get_bd_pins STATUS_REG/static_in_28]
  connect_bd_net -net aurora_8b10b_GTH0_B_sys_reset_out  [get_bd_pins GTHB/sys_reset_out] \
  [get_bd_pins STATUS_REG/static_in_27]
  connect_bd_net -net aurora_8b10b_GTH0_B_tx_lock  [get_bd_pins GTHB/tx_lock] \
  [get_bd_pins STATUS_REG/static_in_24]
  connect_bd_net -net aurora_8b10b_GTH0_B_tx_resetdone_out  [get_bd_pins GTHB/tx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_25]
  connect_bd_net -net aurora_8b10b_GTH0_C_channel_up  [get_bd_pins GTHC/channel_up] \
  [get_bd_pins STATUS_REG/static_in_30]
  connect_bd_net -net aurora_8b10b_GTH0_C_crc_pass_fail_n  [get_bd_pins GTHC/crc_pass_fail_n] \
  [get_bd_pins STATUS_REG/static_in_31]
  connect_bd_net -net aurora_8b10b_GTH0_C_crc_valid  [get_bd_pins GTHC/crc_valid] \
  [get_bd_pins STATUS_REG/static_in_32]
  connect_bd_net -net aurora_8b10b_GTH0_C_frame_err  [get_bd_pins GTHC/frame_err] \
  [get_bd_pins STATUS_REG/static_in_33]
  connect_bd_net -net aurora_8b10b_GTH0_C_gt_powergood  [get_bd_pins GTHC/gt_powergood] \
  [get_bd_pins STATUS_REG/static_in_44]
  connect_bd_net -net aurora_8b10b_GTH0_C_hard_err  [get_bd_pins GTHC/hard_err] \
  [get_bd_pins STATUS_REG/static_in_34]
  connect_bd_net -net aurora_8b10b_GTH0_C_lane_up  [get_bd_pins GTHC/lane_up] \
  [get_bd_pins STATUS_REG/static_in_35]
  connect_bd_net -net aurora_8b10b_GTH0_C_link_reset_out  [get_bd_pins GTHC/link_reset_out] \
  [get_bd_pins STATUS_REG/static_in_41]
  connect_bd_net -net aurora_8b10b_GTH0_C_pll_not_locked_out  [get_bd_pins GTHC/pll_not_locked_out] \
  [get_bd_pins STATUS_REG/static_in_36]
  connect_bd_net -net aurora_8b10b_GTH0_C_rx_resetdone_out  [get_bd_pins GTHC/rx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_37]
  connect_bd_net -net aurora_8b10b_GTH0_C_soft_err  [get_bd_pins GTHC/soft_err] \
  [get_bd_pins STATUS_REG/static_in_38]
  connect_bd_net -net aurora_8b10b_GTH0_C_sync_clk_out  [get_bd_pins GTHC/sync_clk_out] \
  [get_bd_pins STATUS_REG/static_in_43]
  connect_bd_net -net aurora_8b10b_GTH0_C_sys_reset_out  [get_bd_pins GTHC/sys_reset_out] \
  [get_bd_pins STATUS_REG/static_in_42]
  connect_bd_net -net aurora_8b10b_GTH0_C_tx_lock  [get_bd_pins GTHC/tx_lock] \
  [get_bd_pins STATUS_REG/static_in_39]
  connect_bd_net -net aurora_8b10b_GTH0_C_tx_resetdone_out  [get_bd_pins GTHC/tx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_40]
  connect_bd_net -net aurora_8b10b_GTH0_D_channel_up  [get_bd_pins GTHD/channel_up] \
  [get_bd_pins STATUS_REG/static_in_45]
  connect_bd_net -net aurora_8b10b_GTH0_D_crc_pass_fail_n  [get_bd_pins GTHD/crc_pass_fail_n] \
  [get_bd_pins STATUS_REG/static_in_46]
  connect_bd_net -net aurora_8b10b_GTH0_D_crc_valid  [get_bd_pins GTHD/crc_valid] \
  [get_bd_pins STATUS_REG/static_in_47]
  connect_bd_net -net aurora_8b10b_GTH0_D_frame_err  [get_bd_pins GTHD/frame_err] \
  [get_bd_pins STATUS_REG/static_in_48]
  connect_bd_net -net aurora_8b10b_GTH0_D_gt_powergood  [get_bd_pins GTHD/gt_powergood] \
  [get_bd_pins STATUS_REG/static_in_59]
  connect_bd_net -net aurora_8b10b_GTH0_D_hard_err  [get_bd_pins GTHD/hard_err] \
  [get_bd_pins STATUS_REG/static_in_49]
  connect_bd_net -net aurora_8b10b_GTH0_D_lane_up  [get_bd_pins GTHD/lane_up] \
  [get_bd_pins STATUS_REG/static_in_50]
  connect_bd_net -net aurora_8b10b_GTH0_D_link_reset_out  [get_bd_pins GTHD/link_reset_out] \
  [get_bd_pins STATUS_REG/static_in_56]
  connect_bd_net -net aurora_8b10b_GTH0_D_pll_not_locked_out  [get_bd_pins GTHD/pll_not_locked_out] \
  [get_bd_pins STATUS_REG/static_in_51]
  connect_bd_net -net aurora_8b10b_GTH0_D_rx_resetdone_out  [get_bd_pins GTHD/rx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_52]
  connect_bd_net -net aurora_8b10b_GTH0_D_soft_err  [get_bd_pins GTHD/soft_err] \
  [get_bd_pins STATUS_REG/static_in_53]
  connect_bd_net -net aurora_8b10b_GTH0_D_sync_clk_out  [get_bd_pins GTHD/sync_clk_out] \
  [get_bd_pins STATUS_REG/static_in_58]
  connect_bd_net -net aurora_8b10b_GTH0_D_sys_reset_out  [get_bd_pins GTHD/sys_reset_out] \
  [get_bd_pins STATUS_REG/static_in_57]
  connect_bd_net -net aurora_8b10b_GTH0_D_tx_lock  [get_bd_pins GTHD/tx_lock] \
  [get_bd_pins STATUS_REG/static_in_54]
  connect_bd_net -net aurora_8b10b_GTH0_D_tx_resetdone_out  [get_bd_pins GTHD/tx_resetdone_out] \
  [get_bd_pins STATUS_REG/static_in_55]
  connect_bd_net -net clk_wiz_0_INIT_CLK  [get_bd_pins clk_wiz_0/INIT_CLK] \
  [get_bd_pins vio_0/clk] \
  [get_bd_pins GTHA/init_clk_in] \
  [get_bd_pins GTHC/init_clk_in] \
  [get_bd_pins GTHD/init_clk_in] \
  [get_bd_pins GTHB/init_clk_in] \
  [get_bd_pins STATUS_REG/clk_out_i] \
  [get_bd_pins gt_reset_0/clk_i]
  connect_bd_net -net gt_reset_0_rst_o  [get_bd_pins gt_reset_0/rst_o] \
  [get_bd_pins GTHA/gt_reset]
  connect_bd_net -net resetn_1  [get_bd_pins resetn] \
  [get_bd_pins clk_wiz_0/resetn] \
  [get_bd_pins STATUS_REG/resetn] \
  [get_bd_pins GTHA/resetn] \
  [get_bd_pins GTHC/resetn] \
  [get_bd_pins GTHD/s_aresetn] \
  [get_bd_pins GTHB/resetn]
  connect_bd_net -net rst_i_1  [get_bd_pins rst_i] \
  [get_bd_pins GTHA/rst_i] \
  [get_bd_pins gt_reset_0/rst_i]
  connect_bd_net -net s_aclk_0_1  [get_bd_pins SYS_CLK] \
  [get_bd_pins clk_wiz_0/clk_in1] \
  [get_bd_pins STATUS_REG/clk_in1] \
  [get_bd_pins GTHA/SYS_CLK] \
  [get_bd_pins GTHC/SYS_CLK] \
  [get_bd_pins GTHD/SYS_CLK] \
  [get_bd_pins GTHB/SYS_CLK]
  connect_bd_net -net vio_0_probe_out0  [get_bd_pins vio_0/probe_out0] \
  [get_bd_pins GTHA/loopback] \
  [get_bd_pins GTHC/loopback] \
  [get_bd_pins GTHD/loopback] \
  [get_bd_pins GTHB/loopback]
  connect_bd_net -net vio_0_probe_out1  [get_bd_pins vio_0/probe_out1] \
  [get_bd_pins GTHA/power_down] \
  [get_bd_pins GTHC/power_down] \
  [get_bd_pins GTHD/power_down] \
  [get_bd_pins GTHB/power_down]

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
  set GT_SERIAL_RX_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_0 ]

  set GT_SERIAL_TX_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_0 ]

  set GT_SERIAL_RX_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_1 ]

  set GT_SERIAL_TX_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_1 ]

  set GT_SERIAL_RX_2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_2 ]

  set GT_SERIAL_TX_2 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_2 ]

  set GT_SERIAL_RX_3 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_RX_rtl:1.0 GT_SERIAL_RX_3 ]

  set GT_SERIAL_TX_3 [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_aurora:GT_Serial_Transceiver_Pins_TX_rtl:1.0 GT_SERIAL_TX_3 ]

  set GT_DIFF_REFCLK1_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 GT_DIFF_REFCLK1_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $GT_DIFF_REFCLK1_0


  # Create ports

  # Create instance: rst_ps8_0_299M, and set properties
  set rst_ps8_0_299M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_ps8_0_299M ]

  # Create instance: zynq_ultra_ps_e_0, and set properties
  set zynq_ultra_ps_e_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0 ]
  set_property -dict [list \
    CONFIG.PSU_BANK_0_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_1_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_2_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_BANK_3_IO_STANDARD {LVCMOS18} \
    CONFIG.PSU_DDR_RAM_HIGHADDR {0xFFFFFFFF} \
    CONFIG.PSU_DDR_RAM_HIGHADDR_OFFSET {0x800000000} \
    CONFIG.PSU_DDR_RAM_LOWADDR_OFFSET {0x80000000} \
    CONFIG.PSU_MIO_0_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_0_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_0_SLEW {fast} \
    CONFIG.PSU_MIO_10_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_10_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_10_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_10_SLEW {fast} \
    CONFIG.PSU_MIO_11_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_11_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_11_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_11_SLEW {fast} \
    CONFIG.PSU_MIO_12_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_12_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_12_SLEW {fast} \
    CONFIG.PSU_MIO_13_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_13_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_13_POLARITY {Default} \
    CONFIG.PSU_MIO_13_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_13_SLEW {fast} \
    CONFIG.PSU_MIO_14_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_14_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_14_POLARITY {Default} \
    CONFIG.PSU_MIO_14_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_14_SLEW {fast} \
    CONFIG.PSU_MIO_15_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_15_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_15_POLARITY {Default} \
    CONFIG.PSU_MIO_15_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_15_SLEW {fast} \
    CONFIG.PSU_MIO_16_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_16_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_16_POLARITY {Default} \
    CONFIG.PSU_MIO_16_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_16_SLEW {fast} \
    CONFIG.PSU_MIO_17_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_17_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_17_POLARITY {Default} \
    CONFIG.PSU_MIO_17_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_17_SLEW {fast} \
    CONFIG.PSU_MIO_18_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_18_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_18_POLARITY {Default} \
    CONFIG.PSU_MIO_18_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_18_SLEW {fast} \
    CONFIG.PSU_MIO_19_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_19_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_19_POLARITY {Default} \
    CONFIG.PSU_MIO_19_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_19_SLEW {fast} \
    CONFIG.PSU_MIO_1_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_1_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_1_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_1_SLEW {fast} \
    CONFIG.PSU_MIO_20_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_20_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_20_POLARITY {Default} \
    CONFIG.PSU_MIO_20_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_20_SLEW {fast} \
    CONFIG.PSU_MIO_21_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_21_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_21_POLARITY {Default} \
    CONFIG.PSU_MIO_21_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_21_SLEW {fast} \
    CONFIG.PSU_MIO_22_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_22_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_22_POLARITY {Default} \
    CONFIG.PSU_MIO_22_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_22_SLEW {fast} \
    CONFIG.PSU_MIO_23_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_23_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_23_POLARITY {Default} \
    CONFIG.PSU_MIO_23_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_23_SLEW {fast} \
    CONFIG.PSU_MIO_24_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_24_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_24_POLARITY {Default} \
    CONFIG.PSU_MIO_24_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_24_SLEW {fast} \
    CONFIG.PSU_MIO_25_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_25_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_25_POLARITY {Default} \
    CONFIG.PSU_MIO_25_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_25_SLEW {fast} \
    CONFIG.PSU_MIO_26_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_26_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_26_POLARITY {Default} \
    CONFIG.PSU_MIO_26_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_26_SLEW {fast} \
    CONFIG.PSU_MIO_27_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_27_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_27_POLARITY {Default} \
    CONFIG.PSU_MIO_27_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_27_SLEW {fast} \
    CONFIG.PSU_MIO_28_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_28_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_28_POLARITY {Default} \
    CONFIG.PSU_MIO_28_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_28_SLEW {fast} \
    CONFIG.PSU_MIO_29_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_29_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_29_POLARITY {Default} \
    CONFIG.PSU_MIO_29_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_29_SLEW {fast} \
    CONFIG.PSU_MIO_2_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_2_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_2_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_2_SLEW {fast} \
    CONFIG.PSU_MIO_30_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_30_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_30_POLARITY {Default} \
    CONFIG.PSU_MIO_30_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_30_SLEW {fast} \
    CONFIG.PSU_MIO_31_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_31_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_31_POLARITY {Default} \
    CONFIG.PSU_MIO_31_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_31_SLEW {fast} \
    CONFIG.PSU_MIO_32_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_32_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_32_POLARITY {Default} \
    CONFIG.PSU_MIO_32_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_32_SLEW {fast} \
    CONFIG.PSU_MIO_33_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_33_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_33_POLARITY {Default} \
    CONFIG.PSU_MIO_33_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_33_SLEW {fast} \
    CONFIG.PSU_MIO_34_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_34_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_34_POLARITY {Default} \
    CONFIG.PSU_MIO_34_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_34_SLEW {fast} \
    CONFIG.PSU_MIO_35_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_35_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_35_POLARITY {Default} \
    CONFIG.PSU_MIO_35_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_35_SLEW {fast} \
    CONFIG.PSU_MIO_36_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_36_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_36_POLARITY {Default} \
    CONFIG.PSU_MIO_36_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_36_SLEW {fast} \
    CONFIG.PSU_MIO_37_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_37_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_38_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_38_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_38_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_38_SLEW {fast} \
    CONFIG.PSU_MIO_39_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_39_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_39_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_39_SLEW {fast} \
    CONFIG.PSU_MIO_3_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_3_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_3_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_3_SLEW {fast} \
    CONFIG.PSU_MIO_40_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_40_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_40_POLARITY {Default} \
    CONFIG.PSU_MIO_40_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_40_SLEW {fast} \
    CONFIG.PSU_MIO_41_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_41_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_41_POLARITY {Default} \
    CONFIG.PSU_MIO_41_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_41_SLEW {fast} \
    CONFIG.PSU_MIO_42_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_42_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_43_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_43_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_43_SLEW {fast} \
    CONFIG.PSU_MIO_44_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_44_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_44_POLARITY {Default} \
    CONFIG.PSU_MIO_44_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_44_SLEW {fast} \
    CONFIG.PSU_MIO_45_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_45_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_46_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_46_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_46_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_46_SLEW {fast} \
    CONFIG.PSU_MIO_47_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_47_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_47_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_47_SLEW {fast} \
    CONFIG.PSU_MIO_48_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_48_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_48_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_48_SLEW {fast} \
    CONFIG.PSU_MIO_49_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_49_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_49_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_49_SLEW {fast} \
    CONFIG.PSU_MIO_4_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_4_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_4_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_4_SLEW {fast} \
    CONFIG.PSU_MIO_50_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_50_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_50_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_50_SLEW {fast} \
    CONFIG.PSU_MIO_51_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_51_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_51_SLEW {fast} \
    CONFIG.PSU_MIO_52_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_52_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_52_SLEW {fast} \
    CONFIG.PSU_MIO_53_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_53_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_54_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_54_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_54_POLARITY {Default} \
    CONFIG.PSU_MIO_54_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_54_SLEW {fast} \
    CONFIG.PSU_MIO_55_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_55_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_55_POLARITY {Default} \
    CONFIG.PSU_MIO_55_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_55_SLEW {fast} \
    CONFIG.PSU_MIO_56_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_56_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_56_POLARITY {Default} \
    CONFIG.PSU_MIO_56_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_56_SLEW {fast} \
    CONFIG.PSU_MIO_57_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_57_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_57_POLARITY {Default} \
    CONFIG.PSU_MIO_57_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_57_SLEW {fast} \
    CONFIG.PSU_MIO_58_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_58_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_58_POLARITY {Default} \
    CONFIG.PSU_MIO_58_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_58_SLEW {fast} \
    CONFIG.PSU_MIO_59_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_59_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_59_POLARITY {Default} \
    CONFIG.PSU_MIO_59_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_59_SLEW {fast} \
    CONFIG.PSU_MIO_5_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_5_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_5_SLEW {fast} \
    CONFIG.PSU_MIO_60_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_60_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_60_POLARITY {Default} \
    CONFIG.PSU_MIO_60_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_60_SLEW {fast} \
    CONFIG.PSU_MIO_61_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_61_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_61_POLARITY {Default} \
    CONFIG.PSU_MIO_61_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_61_SLEW {fast} \
    CONFIG.PSU_MIO_62_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_62_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_62_POLARITY {Default} \
    CONFIG.PSU_MIO_62_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_62_SLEW {fast} \
    CONFIG.PSU_MIO_63_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_63_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_63_POLARITY {Default} \
    CONFIG.PSU_MIO_63_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_63_SLEW {fast} \
    CONFIG.PSU_MIO_64_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_64_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_64_SLEW {fast} \
    CONFIG.PSU_MIO_65_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_65_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_65_SLEW {fast} \
    CONFIG.PSU_MIO_66_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_66_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_66_SLEW {fast} \
    CONFIG.PSU_MIO_67_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_67_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_67_SLEW {fast} \
    CONFIG.PSU_MIO_68_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_68_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_68_SLEW {fast} \
    CONFIG.PSU_MIO_69_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_69_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_69_SLEW {fast} \
    CONFIG.PSU_MIO_6_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_6_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_6_SLEW {fast} \
    CONFIG.PSU_MIO_70_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_70_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_71_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_71_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_72_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_72_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_73_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_73_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_74_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_74_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_75_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_75_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_76_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_76_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_76_SLEW {fast} \
    CONFIG.PSU_MIO_77_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_77_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_77_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_77_SLEW {fast} \
    CONFIG.PSU_MIO_7_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_7_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_7_SLEW {fast} \
    CONFIG.PSU_MIO_8_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_8_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_8_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_8_SLEW {fast} \
    CONFIG.PSU_MIO_9_DRIVE_STRENGTH {12} \
    CONFIG.PSU_MIO_9_INPUT_TYPE {cmos} \
    CONFIG.PSU_MIO_9_PULLUPDOWN {pullup} \
    CONFIG.PSU_MIO_9_SLEW {fast} \
    CONFIG.PSU_MIO_TREE_PERIPHERALS {Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Feedback Clk#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad SPI Flash#Quad\
SPI Flash#Quad SPI Flash#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO0 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1\
MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#GPIO1 MIO#PCIE#I2C 0#I2C 0#GPIO1 MIO#GPIO1 MIO#UART 0#UART 0#GPIO1 MIO#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#SD 1#CAN 1#CAN 1#GPIO2 MIO#GPIO2 MIO#GPIO2 MIO#GPIO2\
MIO#GPIO2 MIO#GPIO2 MIO#GPIO2 MIO#GPIO2 MIO#GPIO2 MIO#GPIO2 MIO#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#Gem 3#MDIO 3#MDIO 3} \
    CONFIG.PSU_MIO_TREE_SIGNALS {sclk_out#miso_mo1#mo2#mo3#mosi_mi0#n_ss_out#clk_for_lpbk#n_ss_out_upper#mo_upper[0]#mo_upper[1]#mo_upper[2]#mo_upper[3]#sclk_out_upper#gpio0[13]#gpio0[14]#gpio0[15]#gpio0[16]#gpio0[17]#gpio0[18]#gpio0[19]#gpio0[20]#gpio0[21]#gpio0[22]#gpio0[23]#gpio0[24]#gpio0[25]#gpio1[26]#gpio1[27]#gpio1[28]#gpio1[29]#gpio1[30]#gpio1[31]#gpio1[32]#gpio1[33]#gpio1[34]#gpio1[35]#gpio1[36]#reset_n#scl_out#sda_out#gpio1[40]#gpio1[41]#rxd#txd#gpio1[44]#sdio1_cd_n#sdio1_data_out[0]#sdio1_data_out[1]#sdio1_data_out[2]#sdio1_data_out[3]#sdio1_cmd_out#sdio1_clk_out#phy_tx#phy_rx#gpio2[54]#gpio2[55]#gpio2[56]#gpio2[57]#gpio2[58]#gpio2[59]#gpio2[60]#gpio2[61]#gpio2[62]#gpio2[63]#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem3_mdc#gem3_mdio_out}\
\
    CONFIG.PSU_SD1_INTERNAL_BUS_WIDTH {4} \
    CONFIG.PSU__ACT_DDR_FREQ_MHZ {1199.999756} \
    CONFIG.PSU__CAN0_LOOP_CAN1__ENABLE {0} \
    CONFIG.PSU__CAN0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__CAN1__GRP_CLK__ENABLE {0} \
    CONFIG.PSU__CAN1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__CAN1__PERIPHERAL__IO {MIO 52 .. 53} \
    CONFIG.PSU__CRF_APB__ACPU_CTRL__ACT_FREQMHZ {1199.999756} \
    CONFIG.PSU__CRF_APB__DBG_FPD_CTRL__ACT_FREQMHZ {249.999954} \
    CONFIG.PSU__CRF_APB__DBG_TSTMP_CTRL__ACT_FREQMHZ {249.999954} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__ACT_FREQMHZ {599.999878} \
    CONFIG.PSU__CRF_APB__DDR_CTRL__FREQMHZ {1200} \
    CONFIG.PSU__CRF_APB__DPDMA_REF_CTRL__ACT_FREQMHZ {599.999878} \
    CONFIG.PSU__CRF_APB__DP_AUDIO_REF_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRF_APB__DP_STC_REF_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRF_APB__DP_VIDEO_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__GDMA_REF_CTRL__ACT_FREQMHZ {599.999878} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__ACT_FREQMHZ {599.999878} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__FREQMHZ {600} \
    CONFIG.PSU__CRF_APB__GPU_REF_CTRL__SRCSEL {DPLL} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__ACT_FREQMHZ {249.999954} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__FREQMHZ {250} \
    CONFIG.PSU__CRF_APB__PCIE_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRF_APB__TOPSW_LSBUS_CTRL__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__ACT_FREQMHZ {524.999939} \
    CONFIG.PSU__CRF_APB__TOPSW_MAIN_CTRL__SRCSEL {VPLL} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__ACT_FREQMHZ {499.999908} \
    CONFIG.PSU__CRL_APB__ADMA_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__AMS_REF_CTRL__ACT_FREQMHZ {49.999992} \
    CONFIG.PSU__CRL_APB__CAN0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__CRL_APB__CAN1_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__ACT_FREQMHZ {499.999908} \
    CONFIG.PSU__CRL_APB__CPU_R5_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__DBG_LPD_CTRL__ACT_FREQMHZ {249.999954} \
    CONFIG.PSU__CRL_APB__DLL_REF_CTRL__ACT_FREQMHZ {1499.999756} \
    CONFIG.PSU__CRL_APB__GEM3_REF_CTRL__ACT_FREQMHZ {124.999977} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__ACT_FREQMHZ {249.999954} \
    CONFIG.PSU__CRL_APB__GEM_TSU_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__I2C0_REF_CTRL__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__ACT_FREQMHZ {266.666626} \
    CONFIG.PSU__CRL_APB__IOU_SWITCH_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__LPD_LSBUS_CTRL__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__ACT_FREQMHZ {499.999908} \
    CONFIG.PSU__CRL_APB__LPD_SWITCH_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__PCAP_CTRL__ACT_FREQMHZ {187.499969} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__ACT_FREQMHZ {299.999939} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {300} \
    CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL} \
    CONFIG.PSU__CRL_APB__QSPI_REF_CTRL__ACT_FREQMHZ {299.999939} \
    CONFIG.PSU__CRL_APB__SDIO0_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__ACT_FREQMHZ {199.999969} \
    CONFIG.PSU__CRL_APB__SDIO1_REF_CTRL__SRCSEL {RPLL} \
    CONFIG.PSU__CRL_APB__TIMESTAMP_REF_CTRL__ACT_FREQMHZ {33.333328} \
    CONFIG.PSU__CRL_APB__UART0_REF_CTRL__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__DDRC__BG_ADDR_COUNT {1} \
    CONFIG.PSU__DDRC__CL {17} \
    CONFIG.PSU__DDRC__CWL {16} \
    CONFIG.PSU__DDRC__DDR4_T_REF_MODE {1} \
    CONFIG.PSU__DDRC__DEVICE_CAPACITY {8192 MBits} \
    CONFIG.PSU__DDRC__DRAM_WIDTH {16 Bits} \
    CONFIG.PSU__DDRC__ROW_ADDR_COUNT {16} \
    CONFIG.PSU__DDRC__SPEED_BIN {DDR4_2400P} \
    CONFIG.PSU__DDRC__T_FAW {30.0} \
    CONFIG.PSU__DDRC__T_RAS_MIN {32.0} \
    CONFIG.PSU__DDRC__T_RC {50} \
    CONFIG.PSU__DDRC__T_RCD {17} \
    CONFIG.PSU__DDRC__T_RP {17} \
    CONFIG.PSU__DDR_HIGH_ADDRESS_GUI_ENABLE {1} \
    CONFIG.PSU__DDR__INTERFACE__FREQMHZ {600.000} \
    CONFIG.PSU__DLL__ISUSED {1} \
    CONFIG.PSU__ENET3__FIFO__ENABLE {0} \
    CONFIG.PSU__ENET3__GRP_MDIO__ENABLE {1} \
    CONFIG.PSU__ENET3__GRP_MDIO__IO {MIO 76 .. 77} \
    CONFIG.PSU__ENET3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__ENET3__PERIPHERAL__IO {MIO 64 .. 75} \
    CONFIG.PSU__ENET3__PTP__ENABLE {0} \
    CONFIG.PSU__ENET3__TSU__ENABLE {0} \
    CONFIG.PSU__FPDMASTERS_COHERENCY {0} \
    CONFIG.PSU__FPD_SLCR__WDT1__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__FPGA_PL0_ENABLE {1} \
    CONFIG.PSU__GEM3_COHERENCY {0} \
    CONFIG.PSU__GEM3_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__GEM__TSU__ENABLE {0} \
    CONFIG.PSU__GPIO0_MIO__IO {MIO 0 .. 25} \
    CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO1_MIO__IO {MIO 26 .. 51} \
    CONFIG.PSU__GPIO1_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPIO2_MIO__IO {MIO 52 .. 77} \
    CONFIG.PSU__GPIO2_MIO__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__GPU_PP0__POWER__ON {1} \
    CONFIG.PSU__GPU_PP1__POWER__ON {1} \
    CONFIG.PSU__I2C0_LOOP_I2C1__ENABLE {0} \
    CONFIG.PSU__I2C0__GRP_INT__ENABLE {0} \
    CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 38 .. 39} \
    CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__IOU_SLCR__TTC0__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC1__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC2__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__TTC3__ACT_FREQMHZ {100.000000} \
    CONFIG.PSU__IOU_SLCR__WDT0__ACT_FREQMHZ {99.999985} \
    CONFIG.PSU__PCIE__BAR0_64BIT {0} \
    CONFIG.PSU__PCIE__BAR0_ENABLE {1} \
    CONFIG.PSU__PCIE__BAR0_PREFETCHABLE {0} \
    CONFIG.PSU__PCIE__BAR0_SCALE {Megabytes} \
    CONFIG.PSU__PCIE__BAR0_SIZE {1} \
    CONFIG.PSU__PCIE__BAR0_TYPE {Memory} \
    CONFIG.PSU__PCIE__BAR0_VAL {0xfff00000} \
    CONFIG.PSU__PCIE__BAR1_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR1_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR2_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR2_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR3_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR3_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR4_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR4_VAL {0x0} \
    CONFIG.PSU__PCIE__BAR5_ENABLE {0} \
    CONFIG.PSU__PCIE__BAR5_VAL {0x0} \
    CONFIG.PSU__PCIE__BRIDGE_BAR_INDICATOR {BAR 0} \
    CONFIG.PSU__PCIE__CLASS_CODE_BASE {0x05} \
    CONFIG.PSU__PCIE__CLASS_CODE_INTERFACE {0x0} \
    CONFIG.PSU__PCIE__CLASS_CODE_SUB {0x04} \
    CONFIG.PSU__PCIE__CLASS_CODE_VALUE {0x50400} \
    CONFIG.PSU__PCIE__DEVICE_ID {0xD021} \
    CONFIG.PSU__PCIE__DEVICE_PORT_TYPE {Endpoint Device} \
    CONFIG.PSU__PCIE__EROM_ENABLE {0} \
    CONFIG.PSU__PCIE__EROM_VAL {0x0} \
    CONFIG.PSU__PCIE__INTX_GENERATION {1} \
    CONFIG.PSU__PCIE__INTX_PIN {INTA} \
    CONFIG.PSU__PCIE__LANE0__ENABLE {1} \
    CONFIG.PSU__PCIE__LANE0__IO {GT Lane0} \
    CONFIG.PSU__PCIE__LANE1__ENABLE {1} \
    CONFIG.PSU__PCIE__LANE1__IO {GT Lane1} \
    CONFIG.PSU__PCIE__LANE2__ENABLE {1} \
    CONFIG.PSU__PCIE__LANE2__IO {GT Lane2} \
    CONFIG.PSU__PCIE__LANE3__ENABLE {1} \
    CONFIG.PSU__PCIE__LANE3__IO {GT Lane3} \
    CONFIG.PSU__PCIE__LINK_SPEED {5.0 Gb/s} \
    CONFIG.PSU__PCIE__MAXIMUM_LINK_WIDTH {x4} \
    CONFIG.PSU__PCIE__MAX_PAYLOAD_SIZE {256 bytes} \
    CONFIG.PSU__PCIE__MSIX_BAR_INDICATOR {BAR 0} \
    CONFIG.PSU__PCIE__MSIX_PBA_BAR_INDICATOR {BAR 0} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_ENABLE {1} \
    CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_IO {MIO 37} \
    CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_ENABLE {0} \
    CONFIG.PSU__PCIE__REF_CLK_FREQ {100} \
    CONFIG.PSU__PCIE__REF_CLK_SEL {Ref Clk0} \
    CONFIG.PSU__PCIE__RESET__POLARITY {Active Low} \
    CONFIG.PSU__PCIE__REVISION_ID {0x0} \
    CONFIG.PSU__PCIE__SUBSYSTEM_ID {0x7} \
    CONFIG.PSU__PCIE__SUBSYSTEM_VENDOR_ID {0x10EE} \
    CONFIG.PSU__PCIE__VENDOR_ID {0x10EE} \
    CONFIG.PSU__PL_CLK0_BUF {TRUE} \
    CONFIG.PSU__PRESET_APPLIED {1} \
    CONFIG.PSU__PROTECTION__MASTERS {USB1:NonSecure;0|USB0:NonSecure;0|S_AXI_LPD:NA;0|S_AXI_HPC1_FPD:NA;0|S_AXI_HPC0_FPD:NA;0|S_AXI_HP3_FPD:NA;0|S_AXI_HP2_FPD:NA;0|S_AXI_HP1_FPD:NA;0|S_AXI_HP0_FPD:NA;1|S_AXI_ACP:NA;0|S_AXI_ACE:NA;0|SD1:NonSecure;1|SD0:NonSecure;0|SATA1:NonSecure;0|SATA0:NonSecure;0|RPU1:Secure;1|RPU0:Secure;1|QSPI:NonSecure;1|PMU:NA;1|PCIe:NonSecure;1|NAND:NonSecure;0|LDMA:NonSecure;1|GPU:NonSecure;1|GEM3:NonSecure;1|GEM2:NonSecure;0|GEM1:NonSecure;0|GEM0:NonSecure;0|FDMA:NonSecure;1|DP:NonSecure;0|DAP:NA;1|Coresight:NA;1|CSU:NA;1|APU:NA;1}\
\
    CONFIG.PSU__PROTECTION__SLAVES {LPD;USB3_1_XHCI;FE300000;FE3FFFFF;0|LPD;USB3_1;FF9E0000;FF9EFFFF;0|LPD;USB3_0_XHCI;FE200000;FE2FFFFF;0|LPD;USB3_0;FF9D0000;FF9DFFFF;0|LPD;UART1;FF010000;FF01FFFF;0|LPD;UART0;FF000000;FF00FFFF;1|LPD;TTC3;FF140000;FF14FFFF;1|LPD;TTC2;FF130000;FF13FFFF;1|LPD;TTC1;FF120000;FF12FFFF;1|LPD;TTC0;FF110000;FF11FFFF;1|FPD;SWDT1;FD4D0000;FD4DFFFF;1|LPD;SWDT0;FF150000;FF15FFFF;1|LPD;SPI1;FF050000;FF05FFFF;0|LPD;SPI0;FF040000;FF04FFFF;0|FPD;SMMU_REG;FD5F0000;FD5FFFFF;1|FPD;SMMU;FD800000;FDFFFFFF;1|FPD;SIOU;FD3D0000;FD3DFFFF;1|FPD;SERDES;FD400000;FD47FFFF;1|LPD;SD1;FF170000;FF17FFFF;1|LPD;SD0;FF160000;FF16FFFF;0|FPD;SATA;FD0C0000;FD0CFFFF;0|LPD;RTC;FFA60000;FFA6FFFF;1|LPD;RSA_CORE;FFCE0000;FFCEFFFF;1|LPD;RPU;FF9A0000;FF9AFFFF;1|LPD;R5_TCM_RAM_GLOBAL;FFE00000;FFE3FFFF;1|LPD;R5_1_Instruction_Cache;FFEC0000;FFECFFFF;1|LPD;R5_1_Data_Cache;FFED0000;FFEDFFFF;1|LPD;R5_1_BTCM_GLOBAL;FFEB0000;FFEBFFFF;1|LPD;R5_1_ATCM_GLOBAL;FFE90000;FFE9FFFF;1|LPD;R5_0_Instruction_Cache;FFE40000;FFE4FFFF;1|LPD;R5_0_Data_Cache;FFE50000;FFE5FFFF;1|LPD;R5_0_BTCM_GLOBAL;FFE20000;FFE2FFFF;1|LPD;R5_0_ATCM_GLOBAL;FFE00000;FFE0FFFF;1|LPD;QSPI_Linear_Address;C0000000;DFFFFFFF;1|LPD;QSPI;FF0F0000;FF0FFFFF;1|LPD;PMU_RAM;FFDC0000;FFDDFFFF;1|LPD;PMU_GLOBAL;FFD80000;FFDBFFFF;1|FPD;PCIE_MAIN;FD0E0000;FD0EFFFF;1|FPD;PCIE_LOW;E0000000;EFFFFFFF;1|FPD;PCIE_HIGH2;8000000000;BFFFFFFFFF;1|FPD;PCIE_HIGH1;600000000;7FFFFFFFF;1|FPD;PCIE_DMA;FD0F0000;FD0FFFFF;1|FPD;PCIE_ATTRIB;FD480000;FD48FFFF;1|LPD;OCM_XMPU_CFG;FFA70000;FFA7FFFF;1|LPD;OCM_SLCR;FF960000;FF96FFFF;1|OCM;OCM;FFFC0000;FFFFFFFF;1|LPD;NAND;FF100000;FF10FFFF;0|LPD;MBISTJTAG;FFCF0000;FFCFFFFF;1|LPD;LPD_XPPU_SINK;FF9C0000;FF9CFFFF;1|LPD;LPD_XPPU;FF980000;FF98FFFF;1|LPD;LPD_SLCR_SECURE;FF4B0000;FF4DFFFF;1|LPD;LPD_SLCR;FF410000;FF4AFFFF;1|LPD;LPD_GPV;FE100000;FE1FFFFF;1|LPD;LPD_DMA_7;FFAF0000;FFAFFFFF;1|LPD;LPD_DMA_6;FFAE0000;FFAEFFFF;1|LPD;LPD_DMA_5;FFAD0000;FFADFFFF;1|LPD;LPD_DMA_4;FFAC0000;FFACFFFF;1|LPD;LPD_DMA_3;FFAB0000;FFABFFFF;1|LPD;LPD_DMA_2;FFAA0000;FFAAFFFF;1|LPD;LPD_DMA_1;FFA90000;FFA9FFFF;1|LPD;LPD_DMA_0;FFA80000;FFA8FFFF;1|LPD;IPI_CTRL;FF380000;FF3FFFFF;1|LPD;IOU_SLCR;FF180000;FF23FFFF;1|LPD;IOU_SECURE_SLCR;FF240000;FF24FFFF;1|LPD;IOU_SCNTRS;FF260000;FF26FFFF;1|LPD;IOU_SCNTR;FF250000;FF25FFFF;1|LPD;IOU_GPV;FE000000;FE0FFFFF;1|LPD;I2C1;FF030000;FF03FFFF;0|LPD;I2C0;FF020000;FF02FFFF;1|FPD;GPU;FD4B0000;FD4BFFFF;1|LPD;GPIO;FF0A0000;FF0AFFFF;1|LPD;GEM3;FF0E0000;FF0EFFFF;1|LPD;GEM2;FF0D0000;FF0DFFFF;0|LPD;GEM1;FF0C0000;FF0CFFFF;0|LPD;GEM0;FF0B0000;FF0BFFFF;0|FPD;FPD_XMPU_SINK;FD4F0000;FD4FFFFF;1|FPD;FPD_XMPU_CFG;FD5D0000;FD5DFFFF;1|FPD;FPD_SLCR_SECURE;FD690000;FD6CFFFF;1|FPD;FPD_SLCR;FD610000;FD68FFFF;1|FPD;FPD_DMA_CH7;FD570000;FD57FFFF;1|FPD;FPD_DMA_CH6;FD560000;FD56FFFF;1|FPD;FPD_DMA_CH5;FD550000;FD55FFFF;1|FPD;FPD_DMA_CH4;FD540000;FD54FFFF;1|FPD;FPD_DMA_CH3;FD530000;FD53FFFF;1|FPD;FPD_DMA_CH2;FD520000;FD52FFFF;1|FPD;FPD_DMA_CH1;FD510000;FD51FFFF;1|FPD;FPD_DMA_CH0;FD500000;FD50FFFF;1|LPD;EFUSE;FFCC0000;FFCCFFFF;1|FPD;Display\
Port;FD4A0000;FD4AFFFF;0|FPD;DPDMA;FD4C0000;FD4CFFFF;0|FPD;DDR_XMPU5_CFG;FD050000;FD05FFFF;1|FPD;DDR_XMPU4_CFG;FD040000;FD04FFFF;1|FPD;DDR_XMPU3_CFG;FD030000;FD03FFFF;1|FPD;DDR_XMPU2_CFG;FD020000;FD02FFFF;1|FPD;DDR_XMPU1_CFG;FD010000;FD01FFFF;1|FPD;DDR_XMPU0_CFG;FD000000;FD00FFFF;1|FPD;DDR_QOS_CTRL;FD090000;FD09FFFF;1|FPD;DDR_PHY;FD080000;FD08FFFF;1|DDR;DDR_LOW;0;7FFFFFFF;1|DDR;DDR_HIGH;800000000;87FFFFFFF;1|FPD;DDDR_CTRL;FD070000;FD070FFF;1|LPD;Coresight;FE800000;FEFFFFFF;1|LPD;CSU_DMA;FFC80000;FFC9FFFF;1|LPD;CSU;FFCA0000;FFCAFFFF;1|LPD;CRL_APB;FF5E0000;FF85FFFF;1|FPD;CRF_APB;FD1A0000;FD2DFFFF;1|FPD;CCI_REG;FD5E0000;FD5EFFFF;1|LPD;CAN1;FF070000;FF07FFFF;1|LPD;CAN0;FF060000;FF06FFFF;0|FPD;APU;FD5C0000;FD5CFFFF;1|LPD;APM_INTC_IOU;FFA20000;FFA2FFFF;1|LPD;APM_FPD_LPD;FFA30000;FFA3FFFF;1|FPD;APM_5;FD490000;FD49FFFF;1|FPD;APM_0;FD0B0000;FD0BFFFF;1|LPD;APM2;FFA10000;FFA1FFFF;1|LPD;APM1;FFA00000;FFA0FFFF;1|LPD;AMS;FFA50000;FFA5FFFF;1|FPD;AFI_5;FD3B0000;FD3BFFFF;1|FPD;AFI_4;FD3A0000;FD3AFFFF;1|FPD;AFI_3;FD390000;FD39FFFF;1|FPD;AFI_2;FD380000;FD38FFFF;1|FPD;AFI_1;FD370000;FD37FFFF;1|FPD;AFI_0;FD360000;FD36FFFF;1|LPD;AFIFM6;FF9B0000;FF9BFFFF;1|FPD;ACPU_GIC;F9010000;F907FFFF;1}\
\
    CONFIG.PSU__PSS_REF_CLK__FREQMHZ {33.33333} \
    CONFIG.PSU__QSPI_COHERENCY {0} \
    CONFIG.PSU__QSPI_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
    CONFIG.PSU__QSPI__GRP_FBCLK__IO {MIO 6} \
    CONFIG.PSU__QSPI__PERIPHERAL__DATA_MODE {x4} \
    CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__QSPI__PERIPHERAL__IO {MIO 0 .. 12} \
    CONFIG.PSU__QSPI__PERIPHERAL__MODE {Dual Parallel} \
    CONFIG.PSU__SAXIGP2__DATA_WIDTH {128} \
    CONFIG.PSU__SD1_COHERENCY {0} \
    CONFIG.PSU__SD1_ROUTE_THROUGH_FPD {0} \
    CONFIG.PSU__SD1__CLK_50_SDR_ITAP_DLY {0x15} \
    CONFIG.PSU__SD1__CLK_50_SDR_OTAP_DLY {0x5} \
    CONFIG.PSU__SD1__DATA_TRANSFER_MODE {4Bit} \
    CONFIG.PSU__SD1__GRP_CD__ENABLE {1} \
    CONFIG.PSU__SD1__GRP_CD__IO {MIO 45} \
    CONFIG.PSU__SD1__GRP_POW__ENABLE {0} \
    CONFIG.PSU__SD1__GRP_WP__ENABLE {0} \
    CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
    CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
    CONFIG.PSU__SWDT0__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT0__RESET__ENABLE {0} \
    CONFIG.PSU__SWDT1__CLOCK__ENABLE {0} \
    CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__SWDT1__RESET__ENABLE {0} \
    CONFIG.PSU__TSU__BUFG_PORT_PAIR {0} \
    CONFIG.PSU__TTC0__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC0__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC1__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC1__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC2__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC2__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__TTC3__CLOCK__ENABLE {0} \
    CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__TTC3__WAVEOUT__ENABLE {0} \
    CONFIG.PSU__UART0__BAUD_RATE {115200} \
    CONFIG.PSU__UART0__MODEM__ENABLE {0} \
    CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
    CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 42 .. 43} \
    CONFIG.PSU__USB0__PERIPHERAL__ENABLE {0} \
    CONFIG.PSU__USB0__RESET__ENABLE {0} \
    CONFIG.PSU__USE__S_AXI_GP2 {1} \
  ] $zynq_ultra_ps_e_0


  # Create instance: AURORA
  create_hier_cell_AURORA [current_bd_instance .] AURORA

  # Create instance: Project
  create_hier_cell_Project [current_bd_instance .] Project

  # Create instance: axi_smc, and set properties
  set axi_smc [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_smc ]
  set_property -dict [list \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {1} \
  ] $axi_smc


  # Create instance: comblock_0, and set properties
  set comblock_0 [ create_bd_cell -type ip -vlnv www.ictp.it:user:comblock:2.0 comblock_0 ]
  set_property -dict [list \
    CONFIG.DRAM_IO_ENA {false} \
    CONFIG.FIFO_IN_ENA {false} \
  ] $comblock_0


  # Create interface connections
  connect_bd_intf_net -intf_net AURORA_GT_SERIAL_TX_0 [get_bd_intf_ports GT_SERIAL_TX_0] [get_bd_intf_pins AURORA/GT_SERIAL_TX_0]
  connect_bd_intf_net -intf_net AURORA_GT_SERIAL_TX_1 [get_bd_intf_ports GT_SERIAL_TX_1] [get_bd_intf_pins AURORA/GT_SERIAL_TX_1]
  connect_bd_intf_net -intf_net AURORA_GT_SERIAL_TX_2 [get_bd_intf_ports GT_SERIAL_TX_2] [get_bd_intf_pins AURORA/GT_SERIAL_TX_2]
  connect_bd_intf_net -intf_net AURORA_GT_SERIAL_TX_3 [get_bd_intf_ports GT_SERIAL_TX_3] [get_bd_intf_pins AURORA/GT_SERIAL_TX_3]
  connect_bd_intf_net -intf_net AURORA_OUT_GT_A_UP [get_bd_intf_pins AURORA/OUT_GT_A_UP] [get_bd_intf_pins Project/IN_GT_A_UP]
  connect_bd_intf_net -intf_net AURORA_OUT_GT_B_LEFT [get_bd_intf_pins AURORA/OUT_GT_B_LEFT] [get_bd_intf_pins Project/IN_GT_B_LEFT]
  connect_bd_intf_net -intf_net GT_DIFF_REFCLK1_0_1 [get_bd_intf_ports GT_DIFF_REFCLK1_0] [get_bd_intf_pins AURORA/GT_DIFF_REFCLK1_0]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_0_1 [get_bd_intf_ports GT_SERIAL_RX_0] [get_bd_intf_pins AURORA/GT_SERIAL_RX_0]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_0_2 [get_bd_intf_ports GT_SERIAL_RX_1] [get_bd_intf_pins AURORA/GT_SERIAL_RX_1]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_1_1 [get_bd_intf_ports GT_SERIAL_RX_2] [get_bd_intf_pins AURORA/GT_SERIAL_RX_2]
  connect_bd_intf_net -intf_net GT_SERIAL_RX_2_1 [get_bd_intf_ports GT_SERIAL_RX_3] [get_bd_intf_pins AURORA/GT_SERIAL_RX_3]
  connect_bd_intf_net -intf_net axi_smc_1_M00_AXI [get_bd_intf_pins Project/DMA_M00_AXI] [get_bd_intf_pins zynq_ultra_ps_e_0/S_AXI_HP0_FPD]
  connect_bd_intf_net -intf_net axi_smc_M00_AXI [get_bd_intf_pins Project/S_AXI_LITE] [get_bd_intf_pins axi_smc/M00_AXI]
  connect_bd_intf_net -intf_net axi_smc_M01_AXI [get_bd_intf_pins Project/s_axi_control] [get_bd_intf_pins axi_smc/M01_AXI]
  connect_bd_intf_net -intf_net axi_smc_M02_AXI [get_bd_intf_pins axi_smc/M02_AXI] [get_bd_intf_pins AURORA/s00_axi]
  connect_bd_intf_net -intf_net axi_smc_M03_AXI [get_bd_intf_pins axi_smc/M03_AXI] [get_bd_intf_pins comblock_0/AXIL]
  connect_bd_intf_net -intf_net axis_data_fifo_down_M_AXIS [get_bd_intf_pins Project/OUT_GT_C_DOWN] [get_bd_intf_pins AURORA/IN_GT_C_DOWN]
  connect_bd_intf_net -intf_net axis_data_fifo_right_M_AXIS [get_bd_intf_pins Project/OUT_GT_D_RIGHT] [get_bd_intf_pins AURORA/IN_GT_D_RIGHT]
  connect_bd_intf_net -intf_net zynq_ultra_ps_e_0_M_AXI_HPM0_LPD [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_LPD] [get_bd_intf_pins axi_smc/S00_AXI]

  # Create port connections
  connect_bd_net -net comblock_0_reg0_o  [get_bd_pins comblock_0/reg0_o] \
  [get_bd_pins Project/DMA_MUX_SEL_i]
  connect_bd_net -net rst_ps8_0_299M_peripheral_aresetn  [get_bd_pins rst_ps8_0_299M/peripheral_aresetn] \
  [get_bd_pins AURORA/resetn] \
  [get_bd_pins axi_smc/aresetn] \
  [get_bd_pins Project/ap_rst_n] \
  [get_bd_pins comblock_0/axil_aresetn]
  connect_bd_net -net rst_ps8_0_299M_peripheral_reset  [get_bd_pins rst_ps8_0_299M/peripheral_reset] \
  [get_bd_pins AURORA/rst_i]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_clk0  [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] \
  [get_bd_pins zynq_ultra_ps_e_0/maxihpm0_lpd_aclk] \
  [get_bd_pins rst_ps8_0_299M/slowest_sync_clk] \
  [get_bd_pins zynq_ultra_ps_e_0/saxihp0_fpd_aclk] \
  [get_bd_pins Project/SYS_CLK] \
  [get_bd_pins axi_smc/aclk] \
  [get_bd_pins AURORA/SYS_CLK] \
  [get_bd_pins comblock_0/axil_aclk]
  connect_bd_net -net zynq_ultra_ps_e_0_pl_resetn0  [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] \
  [get_bd_pins rst_ps8_0_299M/ext_reset_in]

  # Create address segments
  assign_bd_address -offset 0x80000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs Project/axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x80020000 -range 0x00001000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs AURORA/STATUS_REG/axil_static_regs_vhd_0/s00_axi/reg0] -force
  assign_bd_address -offset 0x80030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs comblock_0/AXIL/AXIL] -force
  assign_bd_address -offset 0x80010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces zynq_ultra_ps_e_0/Data] [get_bd_addr_segs Project/sa_grid_0/s_axi_control/Reg] -force
  assign_bd_address -offset 0x000800000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_HIGH] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_PCIE_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI] -force
  assign_bd_address -offset 0x000800000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_HIGH] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_DDR_LOW] -force
  assign_bd_address -offset 0xE0000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_PCIE_LOW] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_QSPI] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_MM2S] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM]
  exclude_bd_addr_seg -offset 0xFF000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces Project/axi_dma_0/Data_S2MM] [get_bd_addr_segs zynq_ultra_ps_e_0/SAXIGP2/HP0_LPS_OCM]


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


