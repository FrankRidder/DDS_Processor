clean
vlib work

vcom -quiet processor_types.vhd
vcom -quiet memory_config.vhd
vcom -quiet mips_processor.vhd
vcom -quiet processor_behaviour.vhd
vcom -quiet memory.vhd
vcom -quiet testmem.vhd
vcom -quiet mips_instructions.vhd

vcom -quiet testbench_instructions.vhd
vcom -quiet cnf_inst_test.vhd

vsim work.cnf_inst_test

add wave *
add wave -position insertpoint /testbench_instructions/behaviour/line__11/lo 
add wave -position insertpoint /testbench_instructions/instructions/line__11/lo
add wave -position insertpoint /testbench_instructions/behaviour/line__11/hi
add wave -position insertpoint /testbench_instructions/instructions/line__11/hi

run 20000ns