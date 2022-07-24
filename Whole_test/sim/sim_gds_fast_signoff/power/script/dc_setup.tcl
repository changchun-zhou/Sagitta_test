source -e -v ./config_temp.tcl

set TOP_MODULE $DESIGN_NAME

set PRJ_PATH ..
set RPT_PATH     $PRJ_PATH/$DESIGN_NAME/report
set LOG_PATH     $PRJ_PATH/$DESIGN_NAME/log
set INPUT_PATH   $PRJ_PATH/$DESIGN_NAME/input
set OUTPUT_PATH  $PRJ_PATH/$DESIGN_NAME/output
set SCRLOC_PATH  $PRJ_PATH/$DESIGN_NAME/script_local
set TEMP_PATH    ""

#set hdlin_check_no_latch true
#set compile_preserve_subdesign_interfaces true
#set enable_recovery_removal_arcs true
#
#
#verilogout_show_unconnected_pins true
#verilogout_unconnected_prefix UNCONNECTED_

#set hdlin_vrlg_std     2005

#set hdlin_check_no_latch true

set RPT_PATH     $RPT_PATH/$DATE_VALUE
set LOG_PATH     $LOG_PATH/$DATE_VALUE
set OUTPUT_PATH  $OUTPUT_PATH/$DATE_VALUE

set_svf  $OUTPUT_PATH/${DESIGN_NAME}.svf

source -e -v ../scripts/dc_app_vars.tcl
