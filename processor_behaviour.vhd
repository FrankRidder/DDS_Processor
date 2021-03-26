LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.processor_types.ALL;

ARCHITECTURE behaviour OF mips_processor  IS
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
		VARIABLE register_temp : word; --temporary register
		VARIABLE lo : word;
		VARIABLE hi : word;
		VARIABLE rt_temp : word;
		VARIABLE rs_temp : word;
		VARIABLE imm_temp : halfword;
		VARIABLE int_rs : integer; 
      VARIABLE int_rt : integer;
		VARIABLE int_imm : integer;
		VARIABLE double_word_temp   : doubleword;
		VARIABLE int_temp : integer;
		
		CONSTANT DONTCARE : word := (OTHERS => '-');

		TYPE bool2std_logic_table IS ARRAY (boolean) OF std_logic;
		CONSTANT BOOL2STD:bool2std_logic_table:=(false=>'0', true=>'1');
			
		--Set or clear condition codes based on given data
		PROCEDURE set_clear_cc(data : IN integer; rd : OUT word) IS
		
		CONSTANT LOW  : integer := -2**(word_length-1);
		CONSTANT HIGH : integer := 2**(word_length-1)-1;
		
		BEGIN
			IF (data<LOW) or (data>HIGH) THEN -- overflow
				ASSERT false REPORT "overflow situation in arithmetic operation" SEVERITY note;
				cc_v:='1'; cc_n:='-'; cc_z:='-'; rd:= DONTCARE;
			ELSE
				cc_v:='0'; cc_n:=BOOL2STD(data<0); cc_z:=BOOL2STD(data=0);
				rd := std_logic_vector(to_signed(data, word_length));
			END IF;
		END set_clear_cc;		
		
		--Read from internal register file
		PROCEDURE read_register(reg_number : IN bit5; output : OUT word) IS
		BEGIN
			IF((unsigned(reg_number)) > regfile'high) THEN
				ASSERT false REPORT "Register out of bound" SEVERITY failure;
			ELSE
				output := regfile(to_integer(unsigned(reg_number)));
			END IF;
		end read_register;
		
		--Write to internal register file
		PROCEDURE write_register(reg_number : IN bit5; input : IN word) IS
		BEGIN
			IF((unsigned(reg_number)) > regfile'high) THEN
				ASSERT false REPORT "Register out of bound" SEVERITY failure;
			ELSE
				regfile(to_integer(unsigned(reg_number))) := input;
			END IF;
		end write_register;
		
		--Read from given memory file
		PROCEDURE read_memory (address : IN natural; result : OUT word) IS
		BEGIN
			-- put address on output
			address_bus <= std_logic_vector(to_unsigned(address,word_length));
			WAIT UNTIL rising_edge(clk);
			IF reset='1' THEN
				  RETURN;
			END IF;

			LOOP -- ready must be low (handshake)
				IF reset='1' THEN
					 RETURN;
				END IF;
				EXIT WHEN ready='0';
				WAIT UNTIL rising_edge(clk);
			END LOOP;

			read <= '1';
			WAIT UNTIL rising_edge(clk);
			IF reset='1' THEN
				  RETURN;
			END IF;

			LOOP
				WAIT UNTIL rising_edge(clk);
				IF reset='1' THEN
					 RETURN;
				END IF;

				IF ready='1' THEN
					 result:=input_bus;
					 EXIT;
				END IF;    
			END LOOP;
			WAIT UNTIL rising_edge(clk);
			IF reset='1' THEN
				  RETURN;
			END IF;

			read <= '0'; 
			address_bus <= DONTCARE;
		END read_memory;                       
		
		--write to given memory file
		PROCEDURE write_memory(address : IN natural; data : IN word) IS
		BEGIN
			-- put address on output
			address_bus <= std_logic_vector(to_unsigned(address,word_length));
			WAIT UNTIL rising_edge(clk);
			IF reset='1' THEN
				RETURN;
			END IF;

			LOOP -- ready must be low (handshake)
				IF reset='1' THEN
					return;
				END IF;
				EXIT WHEN ready='0';
				WAIT UNTIL rising_edge(clk);
			END LOOP;

      output_bus <= data;
      WAIT UNTIL rising_edge(clk);
      IF reset='1' THEN
        RETURN;
      END IF;  
      write <= '1';

      LOOP
        WAIT UNTIL rising_edge(clk);
        IF reset='1' THEN
          RETURN;
        END if;
        EXIT WHEN ready='1';  
      END LOOP;
      WAIT UNTIL rising_edge(clk);
      if reset='1' THEN
        RETURN;
      END if;
      --
      write <= '0';
      output_bus <= DONTCARE;
      address_bus <= DONTCARE;
    END write_memory;
			
		--Processor loop:
		BEGIN 
			 --
			 -- check FOR reset active
			 --
		IF reset='1' THEN
			read <= '0';
			write <= '0';
			pc := 0;
			cc := "000"; -- clear condition code register
			regfile := (others => (others => '0'));
			lo := (others => '0');
			hi := (others => '0');
			LOOP         -- synchrone reset
				 WAIT UNTIL clk = '1';
				 EXIT WHEN reset='0';
			END LOOP;
		END IF;
		--
	   -- fetch next instruction
		--
		read_memory(pc,current_instr);
		IF reset /= '1' THEN
			 pc := pc + 4; -- how it works with Assembly
			 --
			 -- decode & execute
			 -- 
			 CASE op IS
--			 
				 WHEN BGEZ =>
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					IF(int_rs = 0) THEN
						cc_z := '1';
						cc_v := '1';
						pc := pc + to_integer(signed(imm));
					ELSE 
						cc_v := '0';
						cc_z := '0';
					END IF;
					WAIT UNTIL rising_edge(clk);
				 WHEN BEQ => 
					read_register(rs, rs_temp);
					read_register(rt, rt_temp);
					IF(rs_temp = rt_temp) THEN
						cc_v := '1';
						pc := pc + to_integer(signed(imm));
					ELSE 
						cc_v := '0';
					END IF;
					WAIT UNTIL rising_edge(clk);
				 WHEN ANDOP =>
					read_register(rs, rs_temp);
					read_register(rt, rt_temp);
					register_temp := rs_temp AND rt_temp;					
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN OROP =>
					read_register(rs, rs_temp);
					read_register(rt, rt_temp);
					register_temp := rs_temp OR rt_temp;
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN ORI=>
					read_register(rs, rs_temp);
					--Use as temp 32 bit vector to zero extend the imm value
					rt_temp := (others=> '0');
               rt_temp(15 downto 0) := imm;
					register_temp := rs_temp OR rt_temp;
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN ADD =>
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					read_register(rt, rt_temp);
					int_rt := to_integer(signed(rt_temp));
					int_temp := int_rs + int_rt;
					set_clear_cc(int_temp, register_temp);
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN ADDI =>
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					int_imm := to_integer(signed(imm));
					int_temp := int_rs + int_imm;
					set_clear_cc(int_temp, register_temp);
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN SUBOP => 
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					read_register(rt, rt_temp);
					int_rt := to_integer(signed(rt_temp));
					int_temp := int_rs - int_rt;
					set_clear_cc(int_temp, register_temp);
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN DIV => 
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					read_register(rt, rt_temp);
					int_rt := to_integer(signed(rt_temp));
					double_word_temp := std_logic_vector(to_signed(int_rs * int_rt, double_word_length));
					hi := double_word_temp(63 downto 32);
					lo := double_word_temp(31 downto 0);
					WAIT UNTIL rising_edge(clk);
				 WHEN MFLO => 
					register_temp := lo;
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN MFHI => 
					register_temp := hi;
					write_register(rd, register_temp);
					WAIT UNTIL rising_edge(clk);
				 WHEN MULT =>
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					read_register(rt, rt_temp);
					int_rt := to_integer(signed(rt_temp));
					double_word_temp := std_logic_vector(to_signed(int_rs * int_rt, double_word_length));
					hi := double_word_temp(63 downto 32);
					lo := double_word_temp(31 downto 0);
					WAIT UNTIL rising_edge(clk);
				 WHEN SLT => 
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					read_register(rt, rt_temp);
					int_rt := to_integer(signed(rt_temp));
					IF(int_rs < int_rt) THEN
						int_temp := 1;
					ELSE
						int_temp := 0;
					END IF;
					WAIT UNTIL rising_edge(clk);
				WHEN LUI => 
					read_register(rs, rs_temp);
					rs_temp := (others =>'0');
					rs_temp(31 DOWNTO 16) := imm;
					write_register(rt, rs_temp);	
					WAIT UNTIL rising_edge(clk);
				WHEN LW => 
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					int_temp := int_rs+to_integer(signed(imm)); 
               read_memory(int_temp, rt_temp);
               write_register(rt, rt_temp);
					WAIT UNTIL rising_edge(clk);
				WHEN SW => 
					read_register(rs, rs_temp);
					int_rs := to_integer(signed(rs_temp));
					int_temp := int_rs+to_integer(signed(imm)); 
					read_register(rt, rt_temp);
               write_memory(int_temp, rt_temp);
					WAIT UNTIL rising_edge(clk);
				WHEN NOP => ASSERT false REPORT "Finished calculation" SEVERITY failure;
					WAIT UNTIL rising_edge(clk);
				WHEN OTHERS => ASSERT false REPORT "Illegal instruction" SEVERITY warning;
					WAIT UNTIL rising_edge(clk);
			 END CASE;
		END IF;
	END PROCESS;
END behaviour;