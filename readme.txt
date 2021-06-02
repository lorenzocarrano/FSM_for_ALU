Here's the FSM implementation in VHDL language and a Testbench.
Some useful .do files are provided to make the ModelSim simulation easier and quicker.
In order to simulate, in ModelSim promt execute the file CU_simulation.do

Complete Instruction Set:

  R-Type instructions:
    – ADD RA,RB,RC (meaning R[RC] = R[RA] + R[RB]);
    – SUB RA,RB,RC (meaning R[RC] = R[RA] - R[RB]);
    – AND RA,RB,RC (meaning R[RC] = R[RA] AND R[RB]); – OR RA,RB,RC (meaning R[RC] = R[RA] OR R[RB]);
  I-Type instructions:
    – ADDI1 RA,RB,INP1 (meaning R[RB] = R[RA] + INP1);
    – SUBI1 RA,RB,INP1 (meaning R[RB] = R[RA] - INP1);
    – ANDI1 RA,RB,INP1 (meaning R[RB] = R[RA] AND INP1);
    – ORI1 RA,RB,INP1 (meaning R[RB] = R[RA] OR INP1);
    – ADDI2 RA,RB,INP2 (meaning R[RB] = R[RA] + INP2);
    – SUBI2 RA,RB,INP2 (meaning R[RB] = R[RA] - INP2);
    – ANDI2 RA,RB,INP2 (meaning R[RB] = R[RA] AND INP2);
    – ORI2 RA,RB,INP2 (meaning R[RB] = R[RA] OR INP2);
    – MOV RA,RB (meaning R[RB] = R[RA]) - The value of the immediate must be equal to 0;
    – S_REG1 RB,INP1 (meaning R[RD] = INP1) - Save the value INP1 in the register file, RA field is not used;
    – S_REG2 RB,INP2 (meaning R[RD] = INP2) - Save the value INP2 in the register file, RA field is not used;
    – S_MEM2 RA,RB,INP2 (meaning MEM[R[RA]+INP2] = R[RB]) - The content of the register RB is saved in a memory cell, whose address is calculated adding the                                                               content of the register RA to the value INP2;
    – L_MEM1 RA,RB,INP1 (meaning R[RB] = MEM[R[RA]+INP1]) - The content of the memory cell, whose address is calculated adding the content of the register RA                                                               to the value INP1, is saved in the register RB;
    – L_MEM2 RA,RB,INP2 (meaning R[RB] = MEM[R[RA]+INP2]) - The content of the memory cell, whose address is calculated adding the content of the register RA                                                               to the value INP2, is saved in the register RB;

In the following the encoding used to implement the CU_FSM and its Testbench. Provided simulation's pdf files follow this encoding rule.
R-type instructions:

	OPCODE is 111111
	
	to encode R-type instructions the 2 LSbits of FUNC fields have been used:
	00 ADD
	01 SUB
	10 AND
	11 OR

I-type instructions
	
	3 LSbits of the OPCODE used to encode ADD, SUB, AND, OR, LOAD, STORE, MOV
	
	for ADD, SUB, AND, OR, LOAD the 4th LSB have been used to encode I1 and I2 version (or _MEM1 and _MEM2 version for LOAD). If it is 0 it is I1 (or _MEM1), otherwise it is I2 (or _MEM2)
	
	for STORE the 5th and 4th have been used: 
		00 STORE_REG1
		01 STORE_REG2
		10 STORE_MEM2
