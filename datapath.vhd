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
		VARIABLE pc : natural;
		VARIABLE current_instr:word;
			ALIAS op  : bit6 IS current_instr(31 DOWNTO 26);
			ALIAS rs : bit5 IS current_instr(25 DOWNTO 21);
			ALIAS rt : bit5 IS current_instr(20 DOWNTO 16);
			ALIAS rd : bit5 IS current_instr(15 DOWNTO 11);
			ALIAS sa : bit5 IS current_instr(10 DOWNTO 6);
			ALIAS func : bit6 IS current_instr(5 DOWNTO 0);
			ALIAS imm : halfword IS current_instr( 15 DOWNTO 0);
		VARIABLE cc : bit3;
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
			
			if reset = '1' then
				control <= (others => '0');
				current_instr := (others => '0');
				regfile <= (others => (others => '0'));
				pc := text_base_address;
				cc := "000"; -- clear condition code register
				loop
					wait until rising_edge(clk);
					exit when reset = '0';
				end loop;
			
			elsif (rising_edge(clk)) then
				  address_bus <= pc  when control(mread) = '1';
			
			end if;
	END PROCESS;
END behaviour;