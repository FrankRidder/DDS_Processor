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