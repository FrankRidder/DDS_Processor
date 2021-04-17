LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_types.all;
USE work.memory_config.all;
USE work.control_names.all;

ENTITY datapath IS
  PORT (
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
			ALIAS cc_n  : std_logic IS alu_cc(2);
			ALIAS cc_z  : std_logic IS alu_cc(1);
			ALIAS cc_v  : std_logic IS alu_cc(0);
		SIGNAL regfile : register_file;
		SIGNAL control : control_bus;
		SIGNAL readyi  : std_logic; 
		SIGNAL lo : word;
		SIGNAL hi : word;

		CONSTANT DONTCARE : word := (OTHERS => '-');
	
		--Read from internal register file
		PROCEDURE read_register(SIGNAL reg_number : IN bit5; SIGNAL regfile : IN register_file; SIGNAL output : OUT word) IS
		BEGIN
			IF((unsigned(reg_number)) > regfile'high) THEN
				ASSERT false REPORT "Register out of bound" SEVERITY failure;
			ELSE
				output <= regfile(to_integer(unsigned(reg_number)));
			END IF;
		END read_register;

		--Write to internal register file
		PROCEDURE write_register(SIGNAL reg_number : IN bit5; input : IN word; SIGNAL regfile : OUT register_file) IS
		BEGIN
			IF((unsigned(reg_number)) > regfile'high) THEN
				ASSERT false REPORT "Register out of bound" SEVERITY failure;
			ELSE
				regfile(to_integer(unsigned(reg_number))) <= input;
			END IF;
		END write_register;
		
		PROCEDURE sign_extend(SIGNAL inp : IN halfword; signal ret : OUT word) IS 
		 BEGIN 
			 ret(31 downto 16) <= (others => '0'); -- sign extend 
			 ret(15 downto 0) <= inp; 
		 END sign_extend; 
		 
		BEGIN 
			control <= std2ctlr(ctrl_bus); -- using control conversion (see lecture and alu example)
			ready <= readyi; 
			cc <= alu_cc;
		PROCESS
			BEGIN
			WAIT UNTIL rising_edge(clk);
			IF (reset = '1') THEN
				control <= (others => '0');
				current_instr <= (others => '0');
				regfile <= (others => (others => '0'));
				readyi <= '1';
				pc <= std_logic_vector(to_signed(text_base_address, word_length));
				cc <= "000"; -- clear condition code register
			ELSE
				IF (readyi = '1') THEN
					IF (control(read_mem) = '1') and (mem_ready = '0') AND (control(pc_incr) = '1') THEN
						address_bus <= pc;
						read <= '1';
						readyi <= '0';
					ELSIF (control(read_mem) = '1') and (mem_ready = '0') THEN
						address_bus <= alu_result1;
						read <= '1';
						readyi <= '0';
					ELSIF (control(write_mem) = '1') and (mem_ready = '0') THEN
						read_register(rd, regfile, output_bus);
						address_bus <= alu_result1;
						write <= '1';
						readyi <= '0';
					ELSIF (control(read_reg) = '1') THEN
						readyi <= '0';
						read_register(rs, regfile, alu_op1); 
						IF (control(enable_rt) = '1') THEN 
							read_register(rt, regfile, alu_op2); 
						ELSIF (control(enable_rd) = '1') THEN 
							read_register(rd, regfile, alu_op2); 
						ELSIF (control(enable_imm) = '1') THEN 
							sign_extend(imm, alu_op2); 
						ELSE 
							alu_op2 <= (others => '0');
						END IF; 
						readyi <= '1';
					ELSIF (control(write_reg) = '1' AND control(enable_low) = '1' AND control(enable_hi) = '1') THEN
						lo <= alu_result1;
						hi <= alu_result2;
					ELSIF (control(write_reg) = '1') THEN
						write_register(rd, alu_result1, regfile);
					ELSIF (control(enable_low) = '1') THEN
						write_register(rd, lo, regfile);
					ELSIF (control(enable_hi) = '1') THEN
						write_register(rd, hi, regfile);
					ELSIF (control(pc_imm) = '1') THEN
						pc <= std_logic_vector(signed(pc) + (signed(imm) & "00"));
					END IF;
				ELSE
					IF (control(read_mem) = '1') and (mem_ready = '1') and (control(pc_incr) = '1') THEN
						instruction   <= input_bus;
						current_instr <= input_bus;
						address_bus <= DONTCARE;
						read <= '0';
						pc <= std_logic_vector(signed(pc) + 4); --Use alu to add
						readyi <= '1';
					ELSIF (control(read_mem) = '1') and (mem_ready = '1')  THEN
						address_bus <= DONTCARE;
						write_register(rt, input_bus, regfile);
						read <= '0';
						readyi <= '1';
					ELSIF (control(write_mem) = '1') and (mem_ready = '1')  THEN
						address_bus <= DONTCARE;
						output_bus <= DONTCARE;
						write <= '0';
						readyi <= '1';
					END IF;
				END IF;
			END IF;
	END PROCESS;
END behaviour;
