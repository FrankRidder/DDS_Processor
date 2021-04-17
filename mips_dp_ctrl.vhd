LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.processor_types.ALL;
USE work.memory_config.ALL;
USE work.control_names.all;

ARCHITECTURE mips_dp_ctrl OF mips_processor IS

COMPONENT controller IS
	PORT (
		clk 				: IN 	std_ulogic;
		reset 			: IN	std_ulogic;
		ready				: IN 	std_ulogic; --Datapath ready for new operation
		instruction		: IN word;
		cc 				: IN 	bit3;
		ctrl_bus  		: OUT std_logic_vector(0 to control_bus'length-1);
		alu_ready		: IN std_logic;
		alu_start		: OUT std_logic;
		alu_inst 		: OUT bit6);
END COMPONENT controller;

COMPONENT datapath is
  PORT (
		clk         : IN  std_ulogic;
		reset       : IN  std_ulogic;
		ctrl_bus    : IN  std_logic_vector(0 to control_bus'length-1);
		mem_ready 	: IN  std_ulogic;
		input_bus   : IN  word;
		ready       : OUT std_logic;  --Datapath ready for new operation
		instruction : OUT word;
		output_bus  : OUT word;
		address_bus : OUT word;
		write 		: OUT std_ulogic;
		read  		: OUT std_ulogic;
		alu_result1	: IN  word;
		alu_result2	: IN  word;
		alu_ready	: IN  std_logic;
		alu_cc 		: IN  bit3;
		alu_op1		: OUT word;
		alu_op2 		: OUT word);
END COMPONENT datapath;

COMPONENT alu IS
		PORT (
				result1 	: OUT word;
				result2 	: OUT word;
				ready		: OUT std_logic;
				cc 		: OUT bit3;
				clk		: IN std_logic;
				start		: IN std_logic;
				reset  	: IN std_logic;
				inst 		: IN bit6;
				op1		: IN word;
				op2 		: IN word);
END COMPONENT alu;

  SIGNAL control_bus : std_logic_vector(0 to control_bus'length-1);

  SIGNAL dp_ready 			: std_ulogic;
  SIGNAL instruction 		: word;
  SIGNAL alu_op1, alu_op2 	: word;
  SIGNAL alu_result1 		: word;
  SIGNAL alu_result2 		: word;
  SIGNAL alu_ready  			: std_logic;
  SIGNAL alu_inst   			: bit6;
  SIGNAL alu_start  			: std_logic;
  SIGNAL cc         			: bit3;
begin

ctrl:controller
  port map(clk, reset, dp_ready, instruction, cc, control_bus, alu_ready, alu_start, alu_inst);
dp:datapath
  port map(clk, reset, control_bus, ready, input_bus, dp_ready, instruction, output_bus, address_bus, write, read, alu_result1, alu_result2, alu_ready, cc, alu_op1, alu_op2);
alu_i:alu
  port map(alu_result1, alu_result2, alu_ready, cc, clk, alu_start, reset, alu_inst, alu_op1, alu_op2);

END mips_dp_ctrl;