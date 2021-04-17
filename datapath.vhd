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
		alu_result1	: IN word;
		alu_result2	: IN word;
		alu_ready	: IN std_logic;
		alu_cc 		: IN bit3;
		alu_op1		: OUT word;
		alu_op2 		: OUT word);
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
    SIGNAL lo : word;
    SIGNAL hi : word;

		CONSTANT DONTCARE : word := (OTHERS => '-');

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
				IF (ready = '1') THEN
					ready <= '0';
					IF (control(read_mem) = '1') and (mem_ready = '0') AND (control(pc_incr) = '1') THEN
						address_bus <= pc;
						read <= '1';
					ELSIF (control(read_mem) = '1') and (mem_ready = '0') THEN
						address_bus <= alu_result1;
						read <= '1';
          ELSIF (control(write_mem) = '1') and (mem_ready = '0') THEN
  					read_reg(rd, output_bus);
  					write <= '1';
					ELSIF (control(read_reg) = '1') THEN
						alu_op1 <=  read_reg(rs, regfile);
						alu_op2 <=  read_reg(rt, regfile) when control(enable_rt) = '1' else
								read_reg(rd, regfile) when control(enable_rd) = '1' else
								--Add imm zero extended
								read_reg(OTHERS => 0, regfile);
						ready <= '1';
          ELSIF (control(write_reg) = '1' AND control(enable_low) = '1' AND control(enable_high) = '1') THEN
            lo <= alu_result1;
            hi <= alu_result2;
            ready <= '1';
          ELSIF (control(write_reg) = '1') THEN
            write_register(rd; alu_result1);
            ready <= '1';
          ELSIF (control(enable_low) = '1') THEN
            write_register(rd; lo);
            ready <= '1';
          ELSIF (control(enable_high) = '1') THEN
            write_register(rd; hi);
            ready <= '1';
					ELSIF (control(pc_imm) = '1') THEN
						pc := std_logic_vector(signed(pc) + (signed(imm) & "00"));
						ready <= '1';
					END IF;
				ELSE
					IF (control(read_mem) = '1') and (mem_ready = '1') and (control(pc_incr) = '1') THEN
						instruction   <= input_bus;
						current_instr <= input_bus;
            address_bus <= (others => '0');
						read <= '0';
						pc <= std_logic_vector( + 4); --Use alu to add
					ELSIF (control(read_mem) = '1') and (mem_ready = '1')  THEN
						write_register(rt; input_bus);
            address_bus <= (others => '0');
						read <= '0';
					END IF;
          ELSIF (control(write_mem) = '1') and (mem_ready = '1')  THEN
            address_bus <= (others => '0');
						write <= '0';
					END IF;
				END IF;
			END IF;
	END PROCESS;
END behaviour;
