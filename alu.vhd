LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.processor_types.all;

ENTITY alu IS
		PORT (
				result 	: OUT doubleword;
				ready		: OUT std_logic;
				cc 		: OUT bit3;
				clk		: IN std_logic;
				start		: IN std_logic;				reset  	: IN std_logic;
				inst 		: IN bit6;
				op1		: IN word;
				op2 		: IN word);
END alu;

ARCHITECTURE behaviour OF alu IS
		SIGNAL cci 		: cc_type;
			ALIAS cc_n 	: std_logic IS cci(2); -- negative
			ALIAS cc_z 	: std_logic IS cci(1); -- zero
			ALIAS cc_v 	: std_logic IS cci(0); -- overflow/compare
		PROCESS
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

			 --Multiplication procedure
		PROCEDURE multiplication(multiplicand, multiplier : IN std_logic_vector;
			VARIABLE hi, lo : out std_logic_vector (word_length*2 -1 DOWNTO 0)) IS

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
						upper := std_logic_vector(signed(upper) + signed(multiplier)); -- maybe a single procedure for addition std_logic_vector directly?

						WHEN "10" =>
						lower := std_logic_vector(signed(upper) - signed(multiplier)); -- maybe a single procedure for substraction std_logic_vector directly?

						WHEN others => shift_vector := (others => '0');

					END CASE;
					shift_vector(double_word_length-1 DOWNTO 0) := shift_vector(double_word_length DOWNTO 1); --this is shifting right, while keeping the MSB

				END LOOP;
				hi := upper;
				lo := lower;

		END multiplication;

		-- division algorithm
		PROCEDURE division(dividend, divisor: IN std_logic_vector;
		  VARIABLE quotient, remainder: out std_logic_vector) IS

		  VARIABLE EAQ : std_logic_vector(double_word_length downto 0);
		  ALIAS E: bit IS EAQ(double_word_length);
		  ALIAS A: word IS EAQ(double_word_length - 1 downto word_length);
		  ALIAS EA: std_logic_vector(word_length downto 0) IS EAQ(double_word_length downto word_length);
		  ALIAS Q: word IS EAQ(word_length -1 downto 0);


		  begin
		    E := '0';
		    A := (others => '0');
		    Q := dividend;
		    B := divisor;

		  for i in 1 to word_length loop
		    EAQ := EAQ((double_word_length -1) downto 0) & 0; -- shift left EAQ

				CASE E IS
		      WHEN "0" => -- A >= B
		      EA := std_logic_vector(signed(A)-signed(B));
		      WHEN others => -- A < B
		      EA := std_logic_vector(signed(A)+signed(B));
		    END CASE;

		    EAQ (0) := not E; -- set last bit of the quotient
		  END LOOP;

		  CASE E IS
		    WHEN "1" => -- correction
		    A := std_logic_vector(signed(A)+signed(B));
		  END CASE;

		  remainder := A;
		  quotient := Q;

		END division;

		BEGIN
			if (reset = '1') then
				resulti 	  <= (others => '0');
				cci     <= (others => '0');
				readyi  <= '0';
				loop
					wait until rising_edge(clk);
					exit when reset = '0';
				end loop;
				
			elsif(rising_edge(clk)) then
				if (start = '1') then
					readyi <= '0';
					WHEN RTYPE =>
								CASE inst IS
									WHEN ANDOP =>
		
									WHEN OROP =>
		
									WHEN ADD =>
										result := std_logic_vector(signed(op1) + signed(op2));
									WHEN SUBOP => 
										result := std_logic_vector(signed(op1) - signed(op2));
									WHEN DIV => 

									WHEN MULT =>

									WHEN OTHERS => 
									ASSERT false REPORT "Illegal alu instruction" SEVERITY warning;
				end if;
				readyi <= '1';
			end if;
	end process;
	ready			<= readyi; --Change ready outside of the process
end behaviour;
