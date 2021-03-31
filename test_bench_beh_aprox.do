clean
vlib work

vcom -quiet processor_types.vhd
vcom -quiet memory_config.vhd
vcom -quiet mips_processor.vhd
vcom -quiet processor_behaviour.vhd
vcom -quiet memory.vhd
vcom -quiet testmem.vhd
vcom -quiet testbench.vhd
vcom -quiet conf_beh.vhd

vsim work.cnf_beh_aprox

add wave *
run 200000ns