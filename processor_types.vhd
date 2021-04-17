LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE processor_types IS
  SUBTYPE double_word IS std_logic_vector (63 DOWNTO 0);
  SUBTYPE word IS std_logic_vector (31 DOWNTO 0);
  SUBTYPE halfword IS std_logic_vector (15 DOWNTO 0);
  SUBTYPE bit8  IS std_logic_vector  (7 DOWNTO 0);
  SUBTYPE bit6  IS std_logic_vector  (5 DOWNTO 0);
  SUBTYPE bit5  IS std_logic_vector  (4 DOWNTO 0);
  SUBTYPE bit4  IS std_logic_vector  (3 DOWNTO 0);
  SUBTYPE bit3  IS std_logic_vector  (2 DOWNTO 0);
  SUBTYPE bit2  IS std_logic_vector  (1 DOWNTO 0);
  TYPE register_file is array (0 to 31) of word;
  
  CONSTANT word_length : natural := 32;
  CONSTANT double_word_length : natural := word_length*2;
  CONSTANT half_word_length : natural := word_length/2;
  

  -- instruction set opcode
  CONSTANT RTYPE:		bit6:="000000";
  CONSTANT BGEZ:     bit6:="000001"; 
  CONSTANT BEQ:      bit6:="000100"; 
  CONSTANT ORI:      bit6:="001101";
  CONSTANT ADDI:     bit6:="001000";  
  CONSTANT LUI:      bit6:="001111";
  CONSTANT LW:       bit6:="100011";
  CONSTANT SW:       bit6:="101011";
  
  --function code of opcode R-Type + COMP for ALU
  CONSTANT ANDOP:    bit6:="100100"; --AND is reserved
  CONSTANT OROP:     bit6:="100101"; --OR is reserved     
  CONSTANT ADD:      bit6:="100000"; 
  CONSTANT SUBOP:    bit6:="100010"; 
  CONSTANT DIV:      bit6:="011010"; 
  CONSTANT MFLO:     bit6:="010010"; 
  CONSTANT MFHI:     bit6:="010000";
  CONSTANT MULT:     bit6:="011000";
  CONSTANT SLT:      bit6:="101010";
  CONSTANT COMP:		bit6:="111111";
  
  --nop instruction
  CONSTANT NOP:      word:="00000000000000000000000000000000";
  
 
  
END processor_types;
