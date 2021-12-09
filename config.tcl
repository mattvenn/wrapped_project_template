# User config
set script_dir [file dirname [file normalize [info script]]]

# name of your project, should also match the name of the top module
set ::env(DESIGN_NAME) wrapped_qarma

# add your source files here
set ::env(VERILOG_FILES) "$::env(DESIGN_DIR)/wrapper.v \
    $::env(DESIGN_DIR)/qarma_control.v \
    $::env(DESIGN_DIR)/qarma/qarma_64.v"

# target density, change this if you can't get your design to fit
set ::env(PL_TARGET_DENSITY) 0.50

# set absolute size of the die to 300 x 300 um
set ::env(DIE_AREA) "0 0 400 400"
set ::env(FP_SIZING) absolute

# define number of IO pads
set ::env(SYNTH_DEFINES) "MPRJ_IO_PADS=38"

# clock period is ns
set ::env(CLOCK_PERIOD) "25"
set ::env(CLOCK_PORT) "wb_clk_i"

# macro needs to work inside Caravel, so can't be core and can't use metal 5
set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

# define power straps so the macro works inside Caravel's PDN
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

# regular pin order seems to help with aggregating all the macros for the group project
set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

# turn off CVC as we have multiple power domains
set ::env(RUN_CVC) 0

set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.8
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.8

set ::env(FP_IO_VTHICKNESS_MULT) 4
set ::env(FP_IO_HTHICKNESS_MULT) 4
