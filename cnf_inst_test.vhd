CONFIGURATION cnf_inst_test OF testbench_instructions IS
  FOR behaviour
    FOR mem_beh:memory 
		USE ENTITY work.memory(test);
    END FOR;
	 
	 FOR mem_inst:memory 
		USE ENTITY work.memory(test);
    END FOR;
	 
    FOR behaviour:mips_processor 
		USE ENTITY work.mips_processor(behaviour);
    END FOR;
	 
	 FOR instructions:mips_processor 
		USE ENTITY work.mips_processor(instructions);
    END FOR;

  END FOR;
END cnf_inst_test;

CONFIGURATION cnf_aprox_test OF testbench_instructions IS
  FOR behaviour
    FOR mem_beh:memory 
		USE ENTITY work.memory(behaviour);
    END FOR;
	 
	 FOR mem_inst:memory 
		USE ENTITY work.memory(behaviour);
    END FOR;
	 
    FOR behaviour:mips_processor 
		USE ENTITY work.mips_processor(behaviour);
    END FOR;
	 
	 FOR instructions:mips_processor 
		USE ENTITY work.mips_processor(instructions);
    END FOR;

  END FOR;
END cnf_aprox_test;

CONFIGURATION cnf_dp_test OF testbench_instructions IS
  FOR behaviour
    FOR mem_beh:memory 
		USE ENTITY work.memory(behaviour);
    END FOR;
	 
	 FOR mem_inst:memory 
		USE ENTITY work.memory(behaviour);
    END FOR;
	 
    FOR behaviour:mips_processor 
		USE ENTITY work.mips_processor(behaviour);
    END FOR;
	 
	 FOR instructions:mips_processor 
		USE ENTITY work.mips_processor(mips_dp_ctrl);
    END FOR;

  END FOR;
END cnf_dp_test;