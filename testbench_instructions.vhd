library ieee;
use ieee.std_logic_1164.all;
use work.processor_types.all;
use work.memory_config.all;
entity testbench_instructions is
end testbench_instructions;

architecture behaviour of testbench_instructions is
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
	
	signal inputcpu_bus_beh,outputcpu_bus_beh,address_bus_beh : word;
	signal read_beh,write_beh,ready_beh               : std_ulogic;
	signal inputcpu_bus_inst,outputcpu_bus_inst,address_bus_inst : word;
	signal read_inst,write_inst,ready_inst            : std_ulogic;
	signal reset                          : std_ulogic := '1';
	signal clk                            : std_ulogic := '0';
	begin
	
		behaviour:mips_processor
			port map(inputcpu_bus_beh,outputcpu_bus_beh,address_bus_beh,clk,write_beh,read_beh,ready_beh,reset);
		instructions:mips_processor
			port map(inputcpu_bus_inst,outputcpu_bus_inst,address_bus_inst,clk,write_inst,read_inst,ready_inst,reset);
		mem_beh:memory
			port map(inputcpu_bus_beh,outputcpu_bus_beh,address_bus_beh,clk,write_beh,read_beh,ready_beh);
		mem_inst:memory
			port map(inputcpu_bus_inst,outputcpu_bus_inst,address_bus_inst,clk,write_inst,read_inst,ready_inst);
	reset <= '1', '0' after 100 ns;
	clk   <= not clk after 10 ns;
end behaviour;