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
		SIGNAL cci 		: bit3;
			ALIAS cc_n 	: std_logic IS cci(2); -- negative
			ALIAS cc_z 	: std_logic IS cci(1); -- zero
			ALIAS cc_v 	: std_logic IS cci(0); -- overflow/compare
		SIGNAL readyi  : std_logic;
		BEGIN
		PROCESS
		
		--Set or clear condition codes based on given data
		PROCEDURE set_clear_cc(data : IN integer; signal rd : OUT word) IS
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
--					upper := std_logic_vector(signed(upper) + signed(multiplier)); -- maybe a single procedure for addition std_logic_vector directly?
					addition(upper, multiplier, upper);
					
					WHEN "10" => 
--					upper := std_logic_vector(signed(upper) - signed(multiplier)); -- maybe a single procedure for subtraction std_logic_vector directly?
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
		  signal quotient, remainder: out word) IS

		  VARIABLE EAQ : std_logic_vector(double_word_length downto 0);
		  ALIAS E: std_logic IS EAQ(double_word_length);
		  ALIAS A: word IS EAQ(double_word_length - 1 downto word_length);
		  ALIAS EA: std_logic_vector(word_length downto 0) IS EAQ(double_word_length downto word_length);
		  ALIAS Q: word IS EAQ(word_length -1 downto 0);
		  
		  VARIABLE B : word;

		  begin
		    E := '0';
		    A := (others => '0');
		    Q := dividend;
		    B := divisor;

		  for i in 1 to word_length loop
		    EAQ := EAQ((double_word_length -1) downto 0) & '0'; -- shift left EAQ

				CASE E IS
		      WHEN '0' => -- A >= B
				subtraction(A, B, EA);
--		      EA := std_logic_vector(signed(A)-signed(B));
		      WHEN others => -- A < B
--		      EA := std_logic_vector(signed(A)+signed(B));
				addition(A, B, EA);
			 END CASE;

		    EAQ(0) := not E; -- set last bit of the quotient
		  END LOOP;
		  
		  IF(E = '1') THEN
--		   A := std_logic_vector(signed(A)+signed(B));
			addition(A, B, A);
		  END IF;

		  remainder <= A;
		  quotient  <= Q;

		END division;

		BEGIN
			if (reset = '1') then
				cci     <= (others => '0');
				readyi  <= '0';
				result1 <= (others => '0');
				result2 <= (others => '0');
				loop
					wait until rising_edge(clk);
					exit when reset = '0';
				end loop;
				
			elsif(rising_edge(clk)) then
				if (start = '1') then
					readyi <= '0';
							CASE inst IS
								WHEN ANDOP =>
									set_clear_cc(to_integer(signed(op1 AND op2)), result1);
								WHEN OROP =>
									set_clear_cc(to_integer(signed(op1 OR op2)), result1);
								WHEN ADD =>
									set_clear_cc(to_integer(signed(op1) + signed(op2)),result1);
								WHEN SUBOP => 
									set_clear_cc(to_integer(signed(op1) - signed(op2)),result1);
								WHEN DIV => 
									division(op1,op2,result1,result2);
								WHEN MULT =>
									multiplication(op1,op2,result1,result2);									
								WHEN OTHERS => 
									ASSERT false REPORT "Illegal alu instruction" SEVERITY warning;
							 END CASE;
				end if;
				readyi <= '1';
			end if;
	end process;
	ready			<= readyi; --Change ready outside of the process
end behaviour;
