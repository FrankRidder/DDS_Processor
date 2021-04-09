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
		
		ALIAS op  : bit6 IS instruction(31 DOWNTO 26);
		ALIAS func : bit6 IS instruction(5 DOWNTO 0);
		
		PROCEDURE datapath_ready IS
			BEGIN
				LOOP 
					WAIT UNTIL rising_edge(clk);
					IF reset = '1' THEN 
						EXIT;
					END if;
					EXIT WHEN ready = '1';
				END loop;
		END PROCEDURE;
	
		BEGIN
			-- using control conversion
			control <= std2ctlr(ctrl_bus);
		
			IF (reset = '1') THEN
				control <= (others => '0');
				LOOP
					WAIT UNTIL rising_edge(clk);
					EXIT WHEN reset = '0';
				END LOOP;
			
			ELSIF (rising_edge(clk)) then
				control <= (read_mem => '1', pc_incr => '1', others => '0'); 
				datapath_ready;
				
				IF(instruction = NOP) THEN
					ASSERT false REPORT "Finished calculation" SEVERITY failure;
				ELSE
					CASE op IS 
						WHEN RTYPE =>
							CASE func IS
								WHEN ANDOP =>
	
								WHEN OROP =>
	
								WHEN ADD =>

								WHEN SUBOP => 

								WHEN DIV => 
		
								WHEN MFLO => 

								WHEN MFHI => 

								WHEN MULT =>

								WHEN SLT => 
									
								WHEN OTHERS => 
									ASSERT false REPORT "Illegal R-TYPE instruction" SEVERITY warning;
							END CASE;
						 
						WHEN BGEZ =>
							
						WHEN BEQ => 
							
						WHEN ORI=>
							
						WHEN ADDI =>
							
						WHEN LUI => 
							
						WHEN LW => 
							
						WHEN SW => 
							
						WHEN OTHERS => 
							ASSERT false REPORT "Illegal I-Type instruction" SEVERITY warning;
					 END CASE;
				END IF;
			END IF;
	END PROCESS;
END behaviour;