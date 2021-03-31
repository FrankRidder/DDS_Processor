LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.memory_config.ALL;


ARCHITECTURE test OF memory IS
  ALIAS word_address : std_logic_vector(31 DOWNTO 2) IS a_bus(31 DOWNTO 2);
  SIGNAL d_busouti : std_logic_vector(31 DOWNTO 0);
  CONSTANT unknown : std_logic_vector(31 DOWNTO 0) := (OTHERS=>'X');  
  TYPE states IS (idle, rd_wr_nrdy, rd_wr_rdy);
  SIGNAL state : states := idle; -- models state of handshake protocol
BEGIN

  PROCESS
    TYPE text_segment IS ARRAY 
       (natural RANGE text_base_address/4 TO text_base_address/4+text_base_size) -- in model has each memory location 4 bytes, therefore divide by 4
       OF string(8 DOWNTO 1);
    TYPE data_segment IS ARRAY 
       (natural RANGE data_base_address/4 TO data_base_address/4+data_base_size)
       OF string(8 DOWNTO 1);
       
    VARIABLE prg:text_segment:=
           (
				-- Code         Basic                      Source
				"3c011001",--lui $1,0x00001001     5    lw $10, Val
				"8c2a0000",--lw $10,0x00000000($1)
				"20040004",--addi $4,$0,0x00000004 8    addi $4, $0, 4 #place 4+0 in register 4
				"20010001",--addi $1,$0,0x00000001 9    addi $1, $0, 1 #place 4+0 in register 4
				"00844020",--add $8,$4,$4          10   add $8, $4, $4 #place 4+4 in register 8
				"00881825",--or $3,$4,$8           12   or $3, $4, $8 #logic or between 4 and 8 placed in 3
				"3485000c",--ori $5,$4,0x0000000c  13   ori $5, $4 , 12 #logic or between 4 and 12 placed in register 5
				"01040018",--mult $8,$4            14   mult $8, $4 #multiply 8 by 4, 32 MSB in HI, 32 LSB in LO
				"01042822",--sub $5,$8,$4          15   sub $5, $8, $4 #substract 4 from 8 and place it in 5
				"0104001a",--div $8,$4             16   div $8, $4 #divide 8 by 4, 32 MSB in HI, 32 LSB in LO
				"00003012",--mflo $6               17   mflo $6 #put HI in 6
				"00003810",--mfhi $7               18   mfhi $7 #put LO in 7
				"3c0c000a",--lui $12,0x0000000a    19   lui $12, 10
				"0088682a",--slt $13,$4,$8         20   slt $13, $4, $8 #if $4 < $8 than  $13 = 1 else 0
				"01404020",--add $8,$10,$0         22   add $8, $10, $0 #register 8 is 10
				"01014022",--sub $8,$8,$1          24   sub $8, $8, $1  #register 8 --
				"0501fffe",--bgez $8,0xfffffffe    25   bgez $8, Loop
				"11040003",--beq $8,$4,0x00000003  28   beq $8, $4 four #if register 8 is 4 goto four
				"3c011001",--lui $1,0x00001001     30   sw $8, X #X = 8
				"ac280000",--sw $8,0x00000000($1)
				"11000002",--beq $8,$0,0x00000002  31   beq $8 $0 end #if register 8 is 0 foto end
				"3c011001",--lui $1,0x00001001     34   sw $4, X #X = 4
				"ac240000",--sw $4,0x00000000($1)
				"00000000",--nop                   37   nop        
				OTHERS => "00000000" 
            );
  
    VARIABLE data:data_segment:=
           ("00000007", "ffffffff", OTHERS=>"00000000");
  
    VARIABLE address:natural;  
    VARIABLE data_out:std_logic_vector(31 DOWNTO 0);
    
  BEGIN
    WAIT UNTIL rising_edge(clk);
    address:=to_integer(unsigned(word_address));
    -- check text segments
    IF (address >= text_base_address/4) AND (address <=text_base_address/4 + text_base_size) THEN  
       d_busouti <= unknown;    
      IF write='1' THEN
        prg(address):=binvec2hex(d_busin);
      ELSIF read='1' THEN
        d_busouti <= hexvec2bin(prg(address));
      END IF;
    ELSIF (address >= data_base_address/4) AND (address <=data_base_address/4 + data_base_size) THEN
      d_busouti <= unknown;
      IF write='1' THEN
        data(address):=binvec2hex(d_busin);
      ELSIF read='1' THEN
        d_busouti <= hexvec2bin(data(address));
      END IF;    
    ELSIF read='1' OR write='1' THEN  -- address not in text/data segment; read/write not valid.
      REPORT "out of memory range" SEVERITY warning;
      d_busouti <= unknown;
    END IF;
  END PROCESS;
  
  d_busout <= d_busouti WHEN state=rd_wr_rdy ELSE unknown;
  
  -- code below is used to model handshake; variable 'dly' can also be another value than 1 (in state idle) 
  handshake_protocol:PROCESS
    VARIABLE dly : natural; -- nmb of delays models delay 
  BEGIN
    WAIT UNTIL clk='1';
    CASE state IS
      WHEN idle        => IF read='1' OR write='1' THEN state<=rd_wr_nrdy; END IF; dly:=1;
      WHEN rd_wr_nrdy  => IF dly>0 THEN dly:=dly-1; ELSE state<=rd_wr_rdy; END IF;
      WHEN rd_wr_rdy   => IF read='0' AND write='0' THEN state<=idle; END IF;
    END CASE;
  END PROCESS;

  ready <= '1' WHEN state=rd_wr_rdy ELSE '0';
  
  ASSERT NOT (read='1' AND write='1') REPORT "memory: read and write are active" SEVERITY error;
  
  ASSERT (a_bus(1 DOWNTO 0)="00") OR (state=idle) REPORT "memory: not an aligned address" SEVERITY error;   
  
END test;