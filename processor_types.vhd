LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
PACKAGE processor_types IS
  SUBTYPE doubleword IS std_logic_vector (63 DOWNTO 0);
  SUBTYPE word IS std_logic_vector (31 DOWNTO 0);
  SUBTYPE halfword IS std_logic_vector (15 DOWNTO 0);
  SUBTYPE bit8  IS std_logic_vector  (7 DOWNTO 0);
  SUBTYPE bit6  IS std_logic_vector  (5 DOWNTO 0);
  SUBTYPE bit5  IS std_logic_vector  (4 DOWNTO 0);
  SUBTYPE bit4  IS std_logic_vector  (3 DOWNTO 0);
  SUBTYPE bit3  IS std_logic_vector  (2 DOWNTO 0);
  TYPE register_file is array (0 to 31) of word;
  
  CONSTANT double_word_length : integer := 64;
  CONSTANT word_length : integer := 32;
  CONSTANT half_word_length : integer := 16;
  

  -- instruction set opcode
  CONSTANT BGEZ:     bit6:="000001"; 
  CONSTANT BEQ:      bit6:="000100"; 
  CONSTANT ANDOP:    bit6:="100100"; --AND is reserved
  CONSTANT OROP:     bit6:="100101"; --OR is reserved  
  CONSTANT ORI:      bit6:="001101";   
  CONSTANT ADD:      bit6:="100000"; 
  CONSTANT ADDI:     bit6:="001100"; 
  CONSTANT SUBOP:    bit6:="100010"; 
  CONSTANT DIV:      bit6:="011010"; 
  CONSTANT MFLO:     bit6:="010010"; 
  CONSTANT MFHI:     bit6:="010000"; 
  CONSTANT MULT:     bit6:="011000";
  CONSTANT SLT:      bit6:="101010";
  CONSTANT LUI:      bit6:="001111";
  CONSTANT LW:       bit6:="100011";
  CONSTANT SW:       bit6:="101011";
  CONSTANT NOP:      bit6:="000000";
 
  
END processor_types;
