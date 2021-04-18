clean
vlib work

vcom -quiet processor_types.vhd
vcom -quiet memory_config.vhd
vcom -quiet mips_processor.vhd
vcom -quiet memory.vhd
vcom -quiet pkg_control_names.vhd
vcom -quiet datapath.vhd
vcom -quiet controller.vhd
vcom -quiet alu.vhd
vcom -quiet testbench.vhd
vcom -quiet mips_dp_ctrl.vhd
vcom -quiet conf_beh.vhd

vsim work.cnf_dp_ctrl_test

set NumericStdNoWarnings 1

add wave sim:/testbench/cpu/dp/*

run 700000ns
