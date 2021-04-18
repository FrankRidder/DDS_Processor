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
vcom -quiet testbench_instructions.vhd
vcom -quiet mips_dp_ctrl.vhd
vcom -quiet cnf_inst_test.vhd

vsim work.cnf_dp_test

set NumericStdNoWarnings 1

add wave /testbench/cpu/dp/*

run 700000ns
