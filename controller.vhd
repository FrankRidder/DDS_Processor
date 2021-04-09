LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_types.all;
USE work.memory_config.all;
USE work.control_names.all;

ENTITY controller IS
	PORT (
		clk 				: IN 	std_ulogic;
		reset 			: IN	std_ulogic;
		ready				: IN 	std_ulogic; --Datapath ready for new operation
		instruction		: IN word;
		cc 				: IN 	cc_type;
		ctrl_bus  		: OUT std_logic_vector(0 to control_bus'length-1));
END controller;

ARCHITECTURE behaviour OF controller IS
BEGIN
	PROCESS
		VARIABLE cc : bit3;
			ALIAS cc_n  : std_logic IS cc(2);
			ALIAS cc_z  : std_logic IS cc(1);
			ALIAS cc_v  : std_logic IS cc(0);
		SIGNAL control : control_bus;
		
		procedure datapath_ready is
			begin
				loop 
					wait until rising_edge(clk);
					if reset = '1' then 
						exit;
					end if;
					exit when ready = '1';
				end loop;
		end procedure;
	
		BEGIN
			-- using control conversion
			control <= std2ctlr(ctrl_bus);
		
			if reset = '1' then
				control <= (others => '0');
				loop
					wait until rising_edge(clk);
					exit when reset = '0';
				end loop;
			
			elsif (rising_edge(clk)) then
				control <= (read_mem => '1', pc_incr => '1', others => '0'); 
				datapath_ready;
			
			end if;
	END PROCESS;
END behaviour;