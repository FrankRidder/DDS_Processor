LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.processor_types.ALL;

ARCHITECTURE behaviour OF mips_processor  IS
BEGIN
	PROCESS
		--Needed internal memory
		VARIABLE pc : natural;
		VARIABLE current_instr:double_word;
			ALIAS op  : bit6 IS current_instr(31 DOWNTO 26);
			ALIAS rs : bit5 IS current_instr(25 DOWNTO 21);
			ALIAS rt : bit5 IS current_instr(20 DOWNTO 16);
			ALIAS rd : bit5 IS current_instr(15 DOWNTO 11);
			ALIAS sa : bit5 IS current_instr(10 DOWNTO 6);
			ALIAS func : bit6 IS current_instr(5 DOWNTO 0);
			ALIAS imm : word IS current_instr( 15 DOWNTO 0);
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
		VARIABLE int_rs : integer; 
      VARIABLE int_rt : integer;
		VARIABLE word_temp   : word;
		VARIABLE double_word_temp :double_word; --used for temporary 32 bit logic vectors
		VARIABLE int_temp : integer;
		CONSTANT DONTCARE : double_word := (OTHERS => '-');
		
		--Needed funtions
			--Writemem
			--Write to internal reg
			--Clear / set cc (condition codes)
		PROCEDURE read_register(reg_number : in bit5; output : out word) is
		BEGIN
			if((unsigned(reg_number)) > regfile'high) then
				assert false report "Register out of bound" severity failure;
			else
				output := regfile(to_integer(unsigned(reg_number)));
			end if;
		end read_register;

			
		PROCEDURE read_memory (addr   : IN natural;
										result : OUT double_word) IS
		BEGIN
				-- put address on output
				adress_bus <= std_logic_vector(to_unsigned(addr,32));
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
				adress_bus <= DONTCARE;
		 END read_memory;                       

			
			
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
			LOOP         -- synchrone reset
				 WAIT UNTIL rising_edge(clk);
				 EXIT WHEN reset='0';
			END LOOP;
		END IF;
		--
	   -- fetch next instruction
		--
		read_memory(pc,current_instr);
		IF reset /= '1' THEN
			 pc:=pc+1; -- TODO: shouldn't this be 4? at least that is mostly how it works with Assembly
			 --
			 -- decode & execute
			 -- 
			 CASE op IS
--			 
--				 WHEN BGEZ => TODO

--				 WHEN BEQ => TODO

				 WHEN ANDOP =>
					read_register(rs, rs_temp);
					read_register(rt, rt_temp);
					register_temp := rs_temp AND rt_temp;
					
				 WHEN OROP =>
					read_register(rs, rs_temp);
					read_register(rt, rt_temp);
					register_temp := rs_temp OR rt_temp;
					
--				 WHEN ORI=> TODO

				 WHEN ADD =>
						read_register(rs,word_temp);
				      int_rs := to_integer(signed(word_temp));
						read_register(rt,word_temp);
						int_rt := to_integer(signed(word_temp));
						int_temp := int_rs + int_rt;
						--Write to register with write file
--				 WHEN ADDI =>	TODO	

				 WHEN SUBOP => int_temp := int_rs - int_rt;
				 
				 WHEN DIV => 
					read_register(rs, word_temp);
					int_rs := to_integer(signed(word_temp));
					read_register(rt, word_temp);
					int_rt := to_integer(signed(word_temp));
					double_word_temp := std_logic_vector(to_signed(int_rs * int_rt, 32));
					hi := double_word_temp(31 downto 16);
					lo := double_word_temp(15 downto 0);
					
				 WHEN MFLO => register_temp := lo;

				 WHEN MFHI => register_temp := hi;

				 WHEN MULT =>
					read_register(rs, word_temp);
					int_rs := to_integer(signed(word_temp));
					read_register(rt, word_temp);
					int_rt := to_integer(signed(word_temp));
					double_word_temp := std_logic_vector(to_signed(int_rs * int_rt, 32));
					hi := double_word_temp(31 downto 16);
					lo := double_word_temp(15 downto 0);
					
--				 WHEN SLT=> TODO

--				 WHEN LUI => TODO

--				 WHEN LW => TODO

--				 WHEN SW =>	TODO

				 WHEN NOP => ASSERT false REPORT "finished calculation" SEVERITY failure;
			 END CASE;
		END IF;
	END PROCESS;
END behaviour;