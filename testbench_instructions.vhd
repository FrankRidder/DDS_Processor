LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.processor_types.all;
USE work.memory_config.all;
ENTITY testbench_instructions IS
END testbench_instructions;

ARCHITECTURE behaviour OF testbench_instructions IS
  COMPONENT memory PORT(
		d_busout : OUT word;
      d_busin  : IN  word;
      a_bus    : IN  word;
      clk      : IN  std_ulogic;
      write    : IN  std_ulogic;
      read     : IN  std_ulogic;
      ready    : OUT std_ulogic);
	END COMPONENT;

	COMPONENT mips_processor PORT (
		input_bus  : IN word;
		output_bus : OUT word;
		address_bus : OUT word;
		clk : IN std_logic;
		write : OUT  std_ulogic;
		read  : OUT  std_ulogic;
		ready : IN std_ulogic;
		reset : IN std_logic);
	END COMPONENT;
	
	SIGNAL inputcpu_bus_beh,outputcpu_bus_beh,address_bus_beh : word;
	SIGNAL read_beh,write_beh,ready_beh               : std_ulogic;
	SIGNAL inputcpu_bus_inst,outputcpu_bus_inst,address_bus_inst : word;
	SIGNAL read_inst,write_inst,ready_inst            : std_ulogic;
	SIGNAL reset                          : std_ulogic := '1';
	SIGNAL clk                            : std_ulogic := '0';
	BEGIN
	
		behaviour:mips_processor
			PORT MAP(inputcpu_bus_beh,outputcpu_bus_beh,address_bus_beh,clk,write_beh,read_beh,ready_beh,reset);
		instructions:mips_processor
			PORT MAP(inputcpu_bus_inst,outputcpu_bus_inst,address_bus_inst,clk,write_inst,read_inst,ready_inst,reset);
		mem_beh:memory
			PORT MAP(inputcpu_bus_beh,outputcpu_bus_beh,address_bus_beh,clk,write_beh,read_beh,ready_beh);
		mem_inst:memory
			PORT MAP(inputcpu_bus_inst,outputcpu_bus_inst,address_bus_inst,clk,write_inst,read_inst,ready_inst);
	reset <= '1', '0' AFTER 100 ns;
	clk   <= not clk AFTER 10 ns;
	
	PROCESS
	BEGIN
		WAIT UNTIL falling_edge(clk);
			ASSERT inputcpu_bus_beh = inputcpu_bus_inst REPORT "inequality on the input bus from memory" SEVERITY note;
			ASSERT outputcpu_bus_beh = outputcpu_bus_inst REPORT "inequality on the output bus to memory" SEVERITY note;
			ASSERT address_bus_beh = address_bus_inst REPORT "inequality on the address bus" SEVERITY note;
			ASSERT write_beh = write_inst REPORT "inequality on the write bus" SEVERITY note;
			ASSERT read_beh = read_inst REPORT "inequality on the read bus" SEVERITY note;
			ASSERT ready_beh = ready_inst REPORT "inequality on the ready bus" SEVERITY note;
	END PROCESS;
			
	
END behaviour;