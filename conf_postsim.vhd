CONFIGURATION cnf_postsim OF testbench IS
  FOR behaviour
    FOR mem:memory 
		USE ENTITY work.memory(behaviour);
    END FOR;
	 
    FOR cpu:mips_processor USE ENTITY work.mips_processor(mips_dp_ctrl);
      FOR mips_dp_ctrl
        FOR ctrl:controller USE ENTITY work.controller(behaviour);
        END FOR;
        FOR dp:datapath USE ENTITY work.datapath(cont_post);
        END FOR;
        FOR alu_i:alu USE ENTITY work.alu(behaviour);
        END FOR;
      END FOR;
    END FOR;
  END FOR;
END cnf_postsim;

CONFIGURATION cnf_comp_postsim OF testbench_instructions IS
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
	 
	 FOR instructions:mips_processor USE ENTITY work.mips_processor(mips_dp_ctrl);
      FOR mips_dp_ctrl
        FOR ctrl:controller USE ENTITY work.controller(behaviour);
        END FOR;
        FOR dp:datapath USE ENTITY work.datapath(cont_post);
        END FOR;
        FOR alu_i:alu USE ENTITY work.alu(behaviour);
        END FOR;
      END FOR;
    END FOR;

  END FOR;
END cnf_comp_postsim;