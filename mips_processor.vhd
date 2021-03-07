LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY mips_processor IS
  PORT (
  clk : IN std_logic;
  reset : IN std_logic;
  read  : IN  std_ulogic;
  ready : IN std_ulogic;
  input_bus  : IN std_logic(31 downto 0);
  write : OUT  std_ulogic;
  adress_bus : OUT std_logic(31 downto 0);
  output_bus : OUT std_logic(31 downto 0);

END mips_processor;