library ieee;
use ieee.std_logic_1164.all;
use work.processor_types.all;
use work.memory_config.all;
entity testbench is
end testbench;

architecture behaviour of testbench is
  component memory port(
		d_busout : out word;
      d_busin  : in  word;
      a_bus    : in  word;
      clk      : in  std_ulogic;
      write    : in  std_ulogic;
      read     : in  std_ulogic;
      ready    : out std_ulogic);
	end component;

	component mips_processor port (
		input_bus  : IN word;
		output_bus : OUT word;
		address_bus : OUT word;
		clk : IN std_logic;
		write : OUT  std_ulogic;
		read  : OUT  std_ulogic;
		ready : IN std_ulogic;
		reset : IN std_logic);
	end component;

	signal inputcpu_bus,outputcpu_bus,address_bus : word;
	signal read,write,ready               : std_ulogic;
	signal reset                          : std_ulogic := '1';
	signal clk                            : std_ulogic := '0';
	begin
		cpu:mips_processor
			port map(inputcpu_bus,outputcpu_bus,address_bus,clk,write,read,ready,reset);
		mem:memory
			port map(inputcpu_bus,outputcpu_bus,address_bus,clk,write,read,ready);
	reset <= '1', '0' after 100 ns;
	clk   <= not clk after 10 ns;
end behaviour;