LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.processor_types.ALL;

ENTITY mips_processor IS
  PORT (
  clk : IN std_logic;
  reset : IN std_logic;
  ready : IN std_ulogic;
  input_bus  : IN double_word;
  read  : OUT  std_ulogic;
  write : OUT  std_ulogic;
  adress_bus : OUT double_word;
  output_bus : OUT double_word);

END mips_processor;