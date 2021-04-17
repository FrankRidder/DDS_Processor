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
		cc 				: IN 	bit3;
		ctrl_bus  		: OUT std_logic_vector(0 to control_bus'length-1);
		alu_ready		: IN std_logic;
		alu_start		: OUT std_logic;
		alu_inst 		: OUT bit6);
END controller;

ARCHITECTURE behaviour OF controller IS
		ALIAS cc_n  : std_logic IS cc(2);
		ALIAS cc_z  : std_logic IS cc(1);
		ALIAS cc_v  : std_logic IS cc(0);
		SIGNAL control : control_bus;

		ALIAS op  : bit6 IS instruction(31 DOWNTO 26);
		ALIAS func : bit6 IS instruction(5 DOWNTO 0);
BEGIN

	-- using control conversion
	ctrl_bus <= ctlr2std(control);
	PROCESS
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

		PROCEDURE send_alu(instr : bit6) IS
			BEGIN
				WAIT UNTIL rising_edge(clk);
				alu_inst <= instr;
				alu_start <= '1';
				LOOP -- wait until alu is finished
				WAIT UNTIL rising_edge(clk);
					IF reset = '1' THEN
						EXIT;
					END if;
					alu_start <= '0';
					EXIT WHEN alu_ready = '1';
				end LOOP;
		end PROCEDURE;

		BEGIN
			IF (reset = '1') THEN
				control <= (others => '0');
				alu_start <= '0';
				LOOP
					WAIT UNTIL rising_edge(clk);
					EXIT WHEN reset = '0';
				END LOOP;

			ELSIF (rising_edge(clk)) THEN
				control <= (read_mem => '1', pc_incr => '1', others => '0');
				datapath_ready;

				IF(instruction = NOP) THEN
					ASSERT false REPORT "Finished calculation" SEVERITY failure;
				ELSE
					CASE op IS
						WHEN RTYPE =>
							CASE func IS
								WHEN ANDOP =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(ANDOP);
									control <= (write_reg => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN OROP =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(OROP);
									control <= (write_reg => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN ADD =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(ADD);
									control <= (write_reg => '1', others => '0');
									datapath_ready;
								WHEN SUBOP =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(SUBOP);
									control <= (write_reg => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN DIV =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(DIV);
									control <= (write_reg => '1', enable_low => '1' , enable_hi => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN MFLO =>
									control <= (enable_low => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN MFHI =>
									control <= (enable_hi => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN MULT =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(MULT);
									control <= (write_reg => '1', enable_low => '1', enable_hi => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN SLT =>
									control <= (read_reg => '1', enable_rt => '1', others => '0');
									send_alu(COMP);
									control <= (write_reg => '1', others => '0');
									WAIT UNTIL rising_edge(clk);
								WHEN OTHERS =>
									ASSERT false REPORT "Illegal R-TYPE instruction" SEVERITY warning;
							END CASE;

						WHEN BGEZ =>
							control <= (read_reg => '1', others => '0');
							send_alu(ADD);
							IF(cc_z = '1' or cc_n = '0') THEN
								control <= (pc_imm => '1', others => '0');
								ASSERT false REPORT "do it" SEVERITY warning;
							END IF;
							WAIT UNTIL rising_edge(clk);
						WHEN BEQ =>
							control <= (read_reg => '1', enable_rt => '1', others => '0');
							send_alu(SUBOP);
							IF(cc_z = '1' ) THEN
								control <= (pc_imm => '1', others => '0');
							END IF;
							WAIT UNTIL rising_edge(clk);
						WHEN ORI=>
							control <= (read_reg => '1', enable_imm => '1', others => '0');
							send_alu(OROP);
							control <= (write_reg => '1', others => '0');
							WAIT UNTIL rising_edge(clk);
						WHEN ADDI =>
							control <= (read_reg => '1', enable_imm => '1', others => '0');
							send_alu(ADD);
							control <= (write_reg => '1', others => '0');
							WAIT UNTIL rising_edge(clk);
						WHEN LUI =>
							control <= (read_reg => '1', enable_imm => '1', imm_upper => '1',  others => '0');
						WHEN LW =>
							control <= (read_reg => '1', enable_imm => '1', others => '0');
							send_alu(ADD);
							control <= (read_mem => '1', others => '0');
							datapath_ready;
						WHEN SW =>
							control <= (read_reg => '1', enable_imm => '1', others => '0');
							send_alu(ADD);
							control <= (write_mem => '1', others => '0');
							datapath_ready;
						WHEN OTHERS =>
							ASSERT false REPORT "Illegal I-Type instruction" SEVERITY warning;
					 END CASE;
				END IF;
			END IF;
	END PROCESS;
END behaviour;
