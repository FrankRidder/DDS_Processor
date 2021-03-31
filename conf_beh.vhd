CONFIGURATION cnf_beh_test OF testbench IS
  FOR behaviour
    FOR mem:memory 
		USE ENTITY work.memory(test);
    END FOR;
	 
    FOR cpu:mips_processor 
		USE ENTITY work.mips_processor(behaviour);
    END FOR;

  END FOR;
END cnf_beh_test;

CONFIGURATION cnf_beh_aprox OF testbench IS
  FOR behaviour
    FOR mem:memory 
		USE ENTITY work.memory(behaviour);
    END FOR;
	 
    FOR cpu:mips_processor 
		USE ENTITY work.mips_processor(behaviour);
    END FOR;

  END FOR;
END cnf_beh_aprox;