library ieee;
use ieee.std_logic_1164.all;
package control_names is
  -- Change this to make it bigger or smaller
  type control_signals is
     (enable_imm, enable_low, enable_hi, enable_rt, enable_rd, read_reg, 
	  read_mem, write_reg, write_mem, pc_incr, pc_imm);

  -- do not change the following type declaration
  type control_bus is array (control_signals) of std_logic;  
  
  function ctlr2std(i:control_bus) return std_logic_vector;
  function std2ctlr(i:std_logic_vector) return control_bus;  
  
end control_names;

package body control_names is
  function ctlr2std(i:control_bus) return std_logic_vector is
    variable res : std_logic_vector(0 to control_bus'length-1);
  begin
    res := (others=>'0');
    for lp in control_signals'left to control_signals'right loop
      if i(lp)='1' then res(control_signals'POS(lp)):='1'; end if;
    end loop;
    return res;
  end function ctlr2std;

  function std2ctlr(i:std_logic_vector) return control_bus is
    variable res : control_bus;
  begin
    res := (others => '0');
    for lp in i'range loop
      if i(lp)='1' then res(control_signals'VAL(lp)):='1'; end if;
    end loop;
    return res;
  end function std2ctlr; 

end control_names;