clean
vlib work

vcom -quiet processor_types.vhd
vcom -quiet memory_config.vhd
vcom -quiet mips_processor.vhd
vcom -quiet memory.vhd
vcom -quiet pkg_control_names.vhd
vcom -quiet mips_processor.vho
vcom -quiet controller.vhd
vcom -quiet alu.vhd
vcom -quiet testbench.vhd
vcom -quiet testbench_instructions.vhd
vcom -quiet mips_dp_ctrl.vhd
vcom -quiet conf_postsim.vhd

vsim work.cnf_comp_postsim

set NumericStdNoWarnings 1

add wave *

run 92000ns
