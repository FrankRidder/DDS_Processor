LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.processor_types.ALL;

ENTITY mips_processor IS
  PORT (
		output_bus : OUT word;
		input_bus  : IN word;
		address_bus : OUT word;
		clk : IN std_logic;
		write : OUT  std_ulogic;
		read  : OUT  std_ulogic;
		ready : IN std_ulogic;
		reset : IN std_logic);

END mips_processor;