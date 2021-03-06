LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_types.all;
USE work.memory_config.all;

ENTITY alu IS
		PORT (
				result1 	: OUT word;
				result2 	: OUT word;
				ready		: OUT std_logic;
				cc 		: OUT bit3;
				clk		: IN std_logic;
				start		: IN std_logic;				reset  	: IN std_logic;
				inst 		: IN bit6;
				op1		: IN word;
				op2 		: IN word);
END alu;

ARCHITECTURE behaviour OF alu IS

		ALIAS cc_n 	: std_logic IS cc(2); -- negative
		ALIAS cc_z 	: std_logic IS cc(1); -- zero
		ALIAS cc_v 	: std_logic IS cc(0); -- overflow/compare
		SIGNAL readyi  : std_logic;
		
		  --Addition procedure
		PROCEDURE addition(addend1, addend2 : IN std_logic_vector;
				VARIABLE sum : out std_logic_vector) IS
				BEGIN
				sum := std_logic_vector(resize(signed(addend1), sum'length) + resize(signed(addend2), sum'length));
		END addition;
	
		--Substraction procedure
		PROCEDURE subtraction(minuend, subtrahend : IN std_logic_vector;
				VARIABLE difference : out std_logic_vector) IS
				BEGIN
				addition(minuend, std_logic_vector(-signed(subtrahend)), difference);
		END subtraction;
	
		 --Multiplication procedure
		 PROCEDURE multiplication(multiplicand, multiplier : IN word;
				signal hi, lo : out word) IS
				
				VARIABLE shift_vector : std_logic_vector(double_word_length downto 0);-- the full vector for booth's algorithm
				ALIAS upper  : word IS shift_vector(double_word_length DOWNTO word_length + 1);
				ALIAS lower : word IS shift_vector(word_length DOWNTO 1);
				ALIAS Q : bit2 IS shift_vector(1 DOWNTO 0);
				
				BEGIN
				upper := (others => '0');
				lower := std_logic_vector(multiplicand);
				Q(0) := '0';
				
				for i in 1 to word_length loop
					CASE Q IS
						WHEN "01" => 
						addition(upper, multiplier, upper);
						
						WHEN "10" => 
						subtraction(upper, multiplier, upper);
						
						WHEN others => null; 
						
					END CASE;
					shift_vector(double_word_length-1 DOWNTO 0) := shift_vector(double_word_length DOWNTO 1); --this is shifting right, while keeping the MSB
					
				END LOOP;
				hi <= upper;
				lo <= lower;
					
		END multiplication;
	
			-- division algorithm
		PROCEDURE division(dividend, divisor: IN word;
		  SIGNAL quotient, remainder: out word) IS

		  VARIABLE EAQ : std_logic_vector(double_word_length downto 0);
		  ALIAS E: std_logic IS EAQ(double_word_length);
		  ALIAS A: word IS EAQ(double_word_length - 1 downto word_length);
		  ALIAS EA: std_logic_vector(word_length downto 0) IS EAQ(double_word_length downto word_length);
		  ALIAS Q: word IS EAQ(word_length -1 downto 0);
		  
		  VARIABLE B : word;
		  
		  VARIABLE signQ : std_logic;
		  VARIABLE signB : std_logic;
		  VARIABLE sign: std_logic;
		  VARIABLE mult: std_logic_vector(31 downto 0);

		  begin
		    E := '0';
		    A := (others => '0');
		    Q := dividend;
		    B := divisor;
			 sign := '0';
			 signQ := '0';
			 signB := '0';
			 
			 if(Q(31) = '1') then
				Q := std_logic_vector(unsigned(-signed(Q)));
				signQ := '1';
			 end if;
			 
			 if(B(31) = '1') then
			 B := std_logic_vector(unsigned(-signed(B)));
				signB := '1';
			end if;
			sign := signQ xor signB;

		  for i in 1 to word_length loop
		    EAQ := EAQ((double_word_length -1) downto 0) & '0';

				CASE E IS
		      WHEN '0' =>
					subtraction(A, B, EA);
		      WHEN others =>
					addition(A, B, EA);
			 END CASE;

		    Q(0) := not E; -- set last bit of the quotient
		  END LOOP;
		  
		  IF(E = '1') THEN
			addition(A, B, EA);
		  END IF;
		  
		  if(sign ='1')then
		  EA := A &'0';
		  Q := std_logic_vector(-signed(unsigned(Q)));
		  end if;

		  remainder <= A;
		  quotient <= Q; --is okay

		END division;
		
		BEGIN
			ready  <= readyi;
			PROCESS
				--Set or clear condition codes based on given data
				PROCEDURE set_clear_cc(data : IN integer; SIGNAL rd : OUT word) IS
					CONSTANT LOW  : integer := -2**(word_length-1);
					CONSTANT HIGH : integer := 2**(word_length-1)-1;
						BEGIN
						IF (data<LOW) or (data>HIGH) THEN -- overflow
							ASSERT false REPORT "overflow situation in arithmetic operation" SEVERITY note;
							cc_v<='1'; cc_n<='-'; cc_z<='-'; rd<= DONTCARE;
						ELSE
							cc_v<='0'; cc_n<=BOOL2STD(data<0); cc_z<=BOOL2STD(data=0);
							rd <= std_logic_vector(to_signed(data, word_length));
						END IF;
				END set_clear_cc;
			BEGIN
				if (reset = '1') then
					readyi  <= '0';
					result1 <= (others => '0');
					result2 <= (others => '0');
					loop
						WAIT UNTIL rising_edge(clk);
						exit when reset = '0';
					end loop;
					
				END IF;
				WAIT UNTIL rising_edge(clk);
				IF (start = '1') THEN
					readyi <= '0';
							CASE inst IS
								WHEN ANDOP =>
									result1 <= op1 AND op2;
									result2 <= DONTCARE;
								WHEN OROP =>
									result1 <= op1 OR op2;
									result2 <= DONTCARE;
								WHEN ADD =>
									set_clear_cc(to_integer(signed(op1) + signed(op2)), result1);
									result2 <= DONTCARE;
								WHEN SUBOP => 
									set_clear_cc(to_integer(signed(op1) - signed(op2)), result1);
									result2 <= DONTCARE;
								WHEN DIV => 
									division(op1,op2,result2,result1);
									--result1 <= std_logic_vector(signed(op1) mod signed(op2));
									--result2 <= std_logic_vector(signed(op1) / signed(op2));
								WHEN MULT =>
									multiplication(op1,op2,result1,result2);	
								WHEN COMP =>
									IF(signed(op1) < signed(op2)) THEN
												result1 <= std_logic_vector(to_signed(1, word_length));
												cc_v <= '1';
											ELSE
												result1 <= std_logic_vector(to_signed(0, word_length));
												cc_v <= '0';
											END IF;
									result2 <= DONTCARE;
								WHEN OTHERS => 
									ASSERT false REPORT "Illegal alu instruction" SEVERITY warning;
							 END CASE;
					readyi <= '1';
				ELSE
					readyi <= '0';
				END IF;
	END PROCESS;
END behaviour;
