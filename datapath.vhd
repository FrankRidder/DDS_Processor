LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_types.all;
USE work.memory_config.all;
USE work.control_names.all;
ENTITY datapath is
	--Add alu in and outputs
  port (
		clk         : IN  std_ulogic;
		reset       : IN  std_ulogic;
		ctrl_bus    : IN  std_logic_vector(0 to control_bus'length-1);
		mem_ready 	: IN std_ulogic;
		input_bus   : IN word;
		ready       : OUT std_logic;
		instruction : OUT word;
		output_bus  : OUT word;
		address_bus : OUT word;
		write 		: OUT  std_ulogic;
		read  		: OUT  std_ulogic;

    );
END datapath;

ARCHITECTURE behaviour OF datapath IS
BEGIN
	PROCESS
		--Needed internal memory
		SIGNAL pc : word;
		SIGNAL current_instr:word;
			ALIAS op  : bit6 IS current_instr(31 DOWNTO 26);
			ALIAS rs : bit5 IS current_instr(25 DOWNTO 21);
			ALIAS rt : bit5 IS current_instr(20 DOWNTO 16);
			ALIAS rd : bit5 IS current_instr(15 DOWNTO 11);
			ALIAS sa : bit5 IS current_instr(10 DOWNTO 6);
			ALIAS func : bit6 IS current_instr(5 DOWNTO 0);
			ALIAS imm : halfword IS current_instr( 15 DOWNTO 0);
		SIGNAL cc : bit3;
			ALIAS cc_n  : std_logic IS cc(2);
			ALIAS cc_z  : std_logic IS cc(1);
			ALIAS cc_v  : std_logic IS cc(0);
		VARIABLE regfile : register_file;
		SIGNAL control : control_bus;
		
		--Read from internal register file
		PROCEDURE read_register(reg_number : IN bit5; output : OUT word) IS
		BEGIN
			IF((unsigned(reg_number)) > regfile'high) THEN
				ASSERT false REPORT "Register out of bound" SEVERITY failure;
			ELSE
				output := regfile(to_integer(unsigned(reg_number)));
			END IF;
		END read_register;
		
		--Write to internal register file
		PROCEDURE write_register(reg_number : IN bit5; input : IN word) IS
		BEGIN
			IF((unsigned(reg_number)) > regfile'high) THEN
				ASSERT false REPORT "Register out of bound" SEVERITY failure;
			ELSE
				regfile(to_integer(unsigned(reg_number))) := input;
			END IF;
		END write_register;	
		
		BEGIN
  
			-- using control conversion (see lecture and alu example)
			control <= std2ctlr(ctrl_bus);
			
			IF reset = '1' THEN
				control <= (others => '0');
				current_instr := (others => '0');
				regfile <= (others => (others => '0'));
				pc <= text_base_address;
				cc <= "000"; -- clear condition code register
				LOOP
					WAIT UNTIL rising_edge(clk);
					EXIT WHEN reset = '0';
				END LOOP;
			
			ELSIF (rising_edge(clk)) THEN
				  if ready = '1' THEN
						if (control(read_mem) = '1') and (mem_ready = '0') THEN
							address_bus <= pc;
							read <= '1';
							ready <= '0';
						END IF;
				ELSE
					if (control(mread) = '1') and (mem_ready = '1') and (control(pc_incr) = '1') THEN
							instruction   <= input_bus;
							current_instr <= input_bus;
							read <= '0';
							pc <= std_logic_vector(signed(pc) + 4); --Use alu to add
						END IF;
				END IF;
			END IF;
	END PROCESS;
END behaviour;