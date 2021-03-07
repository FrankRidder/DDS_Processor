LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ARCHITECTURE behaviour OF mips_processor  IS
/** Needed internal memory
16 internal regesters ?
conditonal codes
program counter
imm
lo -Used in div and mult
hi -Used in div and mult
**/

/**Needed funtions
	Readmem
	Writemem
	Read to internal reg
	Write to internal reg
	Clear / set cc (condition codes)
**/

/**Processor loop:
	Read instruction from mem
	Decode instruction
	Do instruction 
**/
END behaviour;