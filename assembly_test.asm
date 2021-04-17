.data
X: .word
Val: .word 101
.text
lw $10, Val

#basic funtionalities test
addi $4, $0, 4 #place 4+0 in register 4
addi $1, $0, 1 #place 4+0 in register 4
add $8, $4, $4 #place 4+4 in register 8
# change because this is 0: and  $8, $4, $2 # logic and between 4 and 8 placed in 2
or $3, $4, $8 #logic or between 4 and 8 placed in 3
ori $5, $4 , 12 #logic or between 4 and 12 placed in register 5
mult $8, $4 #multiply 8 by 4, 32 MSB in HI, 32 LSB in LO
sub $5, $8, $4 #substract 4 from 8 and place it in 5
div $8, $4 #divide 8 by 4, 32 MSB in HI, 32 LSB in LO
mflo $6 #put HI in 6
mfhi $7 #put LO in 7
lui $12, 10
slt $13, $4, $8 #if $4 < $8 than  $13 = 1 else 0

add $8, $10, $0 #register 8 is 10
Loop: # counts down from 10 to 0
sub $8, $8, $1  #register 8 --
bgez $8, Loop


beq $8, $4 four #if register 8 is 4 goto four

sw $8, X #X = 8
beq $8 $0 end #if register 8 is 0 goto end

four: 
sw $4, X #X = 4

end:
nop


#all functionalities that have to be / are being tested:
#bgez Rs, Label    # IF RF[Rs] >= RF[0] THEN PC=PC + se Imm <<2        (Note: se is sign extension)
#beq Rs, Rt, Label # IF (RF[Rs]==RF[Rt]) THEN PC=PC + se Imm<<2
#and Rd, Rs, Rt     # RF[Rd]=RF[Rs] AND RF[Rt]
#or Rd, Rs, Rt     # RF[Rd]=RF[Rs] OR RF[Rt]
#ori Rd, Rs, Imm   # RF[Rd]=RF[Rs] OR imm                              (Note: imm is zero extended)
#add Rd, Rs, Rt    # RF[Rd]=RF[Rs] + RF{Rt] 
#addi Rd, Rs, Imm  # RF[Rd]=RF[Rs] + se imm 
#sub Rd, Rs, Rt    # RF[Rd]=RF[Rs] - RF{Rt]   
#div Rs, Rt        # LO=Quotient(RF[Rs]/RF[Rt]) and HI=Remainder(RF[Rs]/RF[Rt])
#mflo Rd           # RF[Rd]=LO
#mfhi Rd           # RF[Rd]=HI
#mult Rs, Rt       # HI | LO = RF[Rs]*RF[Rt]
#slt Rd, Rs, Rt    # IF (RF[Rs] < RF[Rt]) THEN RF[Rd]=1 ELSE RF[Rd]=0  (Note: two's complement representation)  
#lui Rt, Imm       # RF[Rt]=Imm<<16 and lower 16 bits zero             (Note: imm value in upper 16 bits; lower 16 bits zero)
#lw Rt, offset(Rs) # RF[Rt]=MEM[RF[Rs] + se offset]
#sw Rt, offset(Rs) # MEM[RF[Rs] + se offset]=RF[Rt]
#nop               
