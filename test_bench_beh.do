clean
vlib work

vcom -quiet processor_types.vhd
vcom -quiet memory_config.vhd
vcom -quiet mips_processor.vhd
vcom -quiet processor_behaviour.vhd
vcom -quiet memory_config.vhd
vcom -quiet memory.vhd
vcom -quiet testbench.vhd

vsim work.testbench

add wave *
run 10000ns