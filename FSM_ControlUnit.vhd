library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM_ControlUnit is 
	
	Port(clk:           in std_logic; --clock signal
		 rst:           in std_logic; -- reset signal -> active low
		 InstrEncoding: in std_logic_vector(31 downto 0);
		 --Signal to datapath:
		 
		 RF1:           out std_logic;	--read port1 enable
		 RF2:           out std_logic;	--read port2 enable
		 WF1:           out std_logic;  --write port enable
		 
		 INP1:			out std_logic_vector(15 downto 0); --immediate
		 INP2:			out std_logic_vector(15 downto 0); --immediate
		 
		 RS1:           out std_logic_vector(4 downto 0);  --read address1
		 RS2:			out std_logic_vector(4 downto 0);  --read address2
		 RD:			out std_logic_vector(4 downto 0); -- RF write address
		 
		 EN1:           out std_logic;
		 S1:            out std_logic; --0 to select input from register, 1 to select an immediate input
		 S2:            out std_logic; --0 to select input from register, 1 to select an immediate input
		 
	 	 ALU1:          out std_logic;
		 ALU2:          out std_logic;
		 
		 EN2:           out std_logic;
		 
		 RM:            out std_logic;
		 WM:            out std_logic;
		 
		 EN3:           out std_logic;
		 S3:            out std_logic --0 to select data from the ALU output, 1 to select data from memory
	);
	
end FSM_ControlUnit;

architecture CU of FSM_ControlUnit is

	type State is (idle, stage1, stage2, stage3);
	signal present_state: State;
	
	begin 
	
		State_transition: process(clk, rst)
			begin
				if rst = '0' then
					present_state <= idle;
				elsif clk'event and clk = '1' then
					case present_state is
					
						when idle   => present_state <= stage1;
						
						when stage1 => present_state <= stage2;
						
						when stage2 => present_state <= stage3;
						
						when stage3 => present_state <= stage1;
						
					end case;					
				end if;
				
	    end process;
		
		Output_setting: process(present_state)
			begin
				
				case present_state is
				
					when idle =>
						--do nothing, everything is OFF
						EN1 <= '0';
						EN2 <= '0';
						EN3 <= '0';
						RF1 <= '0';
						RF2 <= '0';
						WF1 <= '0';
						WM  <= '0'; 
						
					when stage1 =>
					
						if InstrEncoding(31 downto 26) = "111111" then
						
							--R-type Instruction
							--control signals
							EN1 <= '1'; --enable the register file and the first stage pipe registers
							EN2 <= '0';
							EN3 <= '0'; 
							RF1 <= '1'; --enable read-port1 
							RF2 <= '1'; --enable read-port2
							WF1 <= '1';
							--addresses are provided
							RS1 <= InstrEncoding(25 downto 21);
							RS2 <= InstrEncoding(20 downto 16);
							RD  <= InstrEncoding(15 downto 11);
						else
							--I-type Instruction
							if InstrEncoding(28 downto 26) = "000" or InstrEncoding(28 downto 26) = "001" or InstrEncoding(28 downto 26) = "010" or InstrEncoding(28 downto 26) = "011" then --checking value of the 3 LSBits of the OPCODE
								--I-YYYIx YYY can be ADD, SUB, AND, OR x can be 1 or 2. ADD, SUB, AND, OR operations are Referred as ARITHM in the following statements 
								
								if InstrEncoding(29) = '0' then
									--I-ARITHMI1
									EN1  <= '1'; --enable the register file and the first stage pipe registers
									EN2  <= '0';
									EN3  <= '0'; 
									RF2  <= '1'; --enable read-port2 of the RF
									RF1  <= '0';  --disable read-port1 of the RF
									WF1  <= '1'; --enable write-port of the RF
									INP1 <= InstrEncoding(15 downto 0);  --providing the immediate input
									RS2  <= InstrEncoding(25 downto 21); --providing read address
									RD   <= InstrEncoding(20 downto 16); --providign write address
									 
								else 
									--I-ARITHMI2
									EN1  <= '1'; --enable the register file and the first stage pipe registers
									EN2  <= '0';
									EN3  <= '0'; 
									RF1  <= '1'; --enable read-port2 of the RF
									RF2  <= '0'; --disable read-port2 of the RF
									WF1  <= '1'; --enable write-port of the RF
									INP2 <= InstrEncoding(15 downto 0);  --providing the immediate input
									RS1  <= InstrEncoding(25 downto 21); --providing read address
									RD   <= InstrEncoding(20 downto 16); --providing write address
									
								end if;
							elsif InstrEncoding(28 downto 26) = "100" then
								--L_MEMx x can be 1 or 2 LOAD INSTRUCTION
								if InstrEncoding(29) = '0' then
									--L_MEM1
									EN1 <= '1'; --enable the register file and the first stage pipe registers
									EN2  <= '0';
									EN3  <= '0'; 
									RF2 <= '1'; --enable read-port2 of the RF
									RF1 <= '0'; --disable read-port1 of the RF
									WF1 <= '1'; --enable write-port of the RF
									INP1 <= InstrEncoding(15 downto 0); --providing the immediate input
									RS2  <= InstrEncoding(25 downto 21); --providing read address
									RD   <= InstrEncoding(20 downto 16); --providing write address
									
								else 
									--L_MEM2
									EN1 <= '1'; --enable the register file and the first stage pipe registers
									RF1 <= '1'; --enable read-port1 of the RF
									RF2 <= '0'; --disable read-port2 of the RF
									WF1 <= '1'; --enable write-port of the RF
									INP2 <= InstrEncoding(15 downto 0); --providing the immediate input
									RS1  <= InstrEncoding(25 downto 21); --providing read address
									RD   <= InstrEncoding(20 downto 16); --providing write address
									
								end if;
							
							elsif InstrEncoding(28 downto 26) = "101" then
								--STORE INSTRUCTION
								if InstrEncoding(30 downto 29) = "00" then
									--S_REG1 instruction
									EN1  <= '1';
									EN2  <= '0';
									EN3  <= '0'; 
									WF1  <= '1';
									RF1  <= '0';
									RF2  <= '0';
									INP1 <= InstrEncoding(15 downto 0); --value to be saved inside the register pointed by RD
									RD   <= InstrEncoding(20 downto 16); --address of the register in which to save the INP1 data
									INP2 <= (others => '0'); --used to perform a fake addition with INP1
									
								elsif InstrEncoding(30 downto 29) = "01" then
									--S_REG2 instruction
									EN1  <= '1';
									EN2  <= '0';
									EN3  <= '0'; 
									WF1  <= '1';
									RF1  <= '0';
									RF2  <= '0';
									INP2 <= InstrEncoding(15 downto 0);
									RD   <= InstrEncoding(20 downto 16); --address of the register in which to save the INP2 data
									INP1 <= (others => '0'); --used to perform a fake addition with INP2
								
								elsif InstrEncoding(30 downto 29) = "10" then
									--S_MEM2 instruction
									EN1  <= '1';
									EN2  <= '0';
									EN3  <= '0'; 
									RF1  <= '1';
									RF2  <= '1';
									WF1  <= '0';
									INP2 <= InstrEncoding(15 downto 0);
									RS1  <= InstrEncoding(25 downto 21); --address of the register containing the value which added tu INP2 gives the mem_Address in which store the content pointed by RD2
									RS2  <= InstrEncoding(20 downto 16); --address of the register containing the value which have to be stored in memory
									
								end if;
							
							elsif InstrEncoding(28 downto 26) = "110" then
								--MOV instruction
								--I exploit and I_ADD instruction forcing the immediate to 0
								EN1  <= '1'; --enable the register file and the first stage pipe registers
								EN2  <= '0';
								EN3  <= '0'; 
								RF2  <= '1'; --enable read-port2 of the RF
								RF1  <= '0';
								WF1  <= '1'; --enable write-port of the RF
								INP1 <= (others => '0'); --immediate is 0
								RS2  <= InstrEncoding(25 downto 21); --source register's address
								RD   <= InstrEncoding(20 downto 16); --destination register's address
							
							end if;
							
 						end if;
					
					when stage2 =>
					
						if InstrEncoding(31 downto 26) = "111111" then
							
							--R-type Instruction
							EN2  <= '1';
							EN1 <= '0';
							EN3 <= '0';
							S1   <= '0';
							S2   <= '0';
							ALU1 <= InstrEncoding(0);
							ALU2 <= InstrEncoding(1);
							
						else
							--I-type Instruction
							if InstrEncoding(28 downto 26) = "000" or InstrEncoding(28 downto 26) = "001" or InstrEncoding(28 downto 26) = "010" or InstrEncoding(28 downto 26) = "011" then --checking value of the 3 LSBits of the OPCODE
								--I-YYYIx YYY can be ADD, SUB, AND, OR x can be 1 or 2. ADD, SUB, AND, OR operations are Referred as ARITHM in the following statements 
								--NOTE for these operations, just the 2 LSBits are needed, so I can directly associate the value of the 2 LSBits to the value of ALU1 and ALU2 signals
								if InstrEncoding(29) = '0' then
									--I-ARITHMI1
									EN2  <= '1';
									EN1 <= '0';
									EN3 <= '0';
									S1   <= '1';
									S2   <= '0';
									ALU1 <= InstrEncoding(26);
									ALU2 <= InstrEncoding(27);
								else 
									--I-ARITHMI2
									EN2  <= '1';
									EN1 <= '0';
									EN3 <= '0';
									S1   <= '0';
									S2   <= '1';
									ALU1 <= InstrEncoding(26);
									ALU2 <= InstrEncoding(27);
									
								end if;
							elsif InstrEncoding(28 downto 26) = "100" then
								--L_MEMx x can be 1 or 2 LOAD INSTRUCTION
								
								--setting the ALU to perform an addition and enabling second stage pipe registers (common to both LOAD instr version)
								ALU1 <= '0';
								ALU2 <= '0';
								EN2  <= '1';
								EN1 <= '0';
								EN3 <= '0';
								
								if InstrEncoding(29) = '0' then
									--L_MEM1
									
									S1 <= '1'; --INP1 is used
									S2 <= '0'; --other operand coming from read-port2 of the RegFile
			
								else 
									--L_MEM2
									
									S1 <= '0'; --one operand is coming from read-port1 of the RegFile
									S2 <= '1'; --for the other operand INP2 is used 
									
								end if;
							
							elsif InstrEncoding(28 downto 26) = "101" then
								
								EN2 <= '1';
								EN1 <= '0';
								EN3 <= '0';
								--ALU set to perform an ADD in all the three version of the Store Instruction
								ALU1 <= '0';
								ALU2 <= '0';
							
								if InstrEncoding(30 downto 29) = "00" then
									--S_REG1 instruction
									S1 <= '1'; --using INP1 as source of the data to be stored
									S2 <= '1'; --INP2 forced to be 0: a fake ADD is performed 
									--In this case the ALU performs a fake ADD, in order to transfer INP1 to ALU output
									
								
								elsif InstrEncoding(30 downto 29) = "01" then
									--S_REG2 instruction
									S1 <= '1'; --INP1 forced to be 0: a fake ADD is performed 
									S2 <= '1'; --using INP2 as source of the data to be stored
									--In this case the ALU performs a fake ADD, in order to transfer INP2 to ALU output
									
								elsif InstrEncoding(30 downto 29) = "10" then
									--S_MEM2 instruction
									S1 <= '0'; --RA register used as base address
									S2 <= '1'; --INP2 used as immediate offset for the address
									--In this case the ALU performs and ADD between RA content and INP2 in order to compute the memory Address to be wrote
									
								end if;
							
							elsif InstrEncoding(28 downto 26) = "110" then
								--MOV instruction
								EN2 <= '1';
								EN1 <= '0';
								EN3 <= '0';
								--set ALU to perform an addition
								ALU1 <= '0';
								ALU2 <= '0';
								--selecting ALU inputs
								S1 <= '1'; --immediate is forced to 0 in order to perform a fake addition
								S2 <= '0'; --coming from ALU: it is the value that has to be stored inside dest register (pointed by RD content)
							
							end if;						
						end if;
					
					when stage3 =>
					
						if InstrEncoding(31 downto 26) = "111111" then
						
							--R-type Instruction
							EN3 <= '1';
							S3  <= '0'; --selecting ouptup from the ALU
							
						else
							--I-type Instruction
							if InstrEncoding(28 downto 26) = "000" or InstrEncoding(28 downto 26) = "001" or InstrEncoding(28 downto 26) = "010" or InstrEncoding(28 downto 26) = "011" then --checking value of the 3 LSBits of the OPCODE
								--I-YYYIx YYY can be ADD, SUB, AND, OR x can be 1 or 2. ADD, SUB, AND, OR operations are Referred as ARITHM in the following statements 
								--In this stage there are no differences between the two versions
								EN3 <= '1';
								EN2 <= '0';
								EN1 <= '0';
								S3 <= '0'; --selecting outpu from the ALU
								--disabling read/write memory signals
								RM <= '0';
								WM <= '0';
								
							elsif InstrEncoding(28 downto 26) = "100" then
								--L_MEMx x can be 1 or 2 LOAD INSTRUCTION
								--In this stage there are no differences between the two versions
								
								EN3 <= '1';
								EN2 <= '0';
								EN1 <= '0';
								
								RM <= '1'; --enabling read memory operation
								WM <= '0'; --write memory is not enabled
								S3 <= '1'; --selecting as output the data coming from memory
								
								
							elsif InstrEncoding(28 downto 26) = "101" then
								
								EN3 <= '1'; --common to all the three versions of the instruction
								EN2 <= '0';
								EN1 <= '0';
							
								if InstrEncoding(30 downto 29) = "00" then
									--S_REG1 instruction
									--memory is not involved in this version of the Store Instruction
									RM <= '0';
									WM <= '0';
									S3 <= '0'; --at the output I'll have the address of the memory which have been accessed (coming from ALU). However in this case the value of S3 doesn't really matter
									
								
								elsif InstrEncoding(30 downto 29) = "01" then
									--S_REG2 instruction (SAME AS S_REG1)
									--memory is not involved in this version of the Store Instruction
									RM <= '0';
									WM <= '0';
									S3 <= '0'; --at the output I'll have the address of the memory which have been accessed (coming from ALU). However in this case the value of S3 doesn't really matter
								
								elsif InstrEncoding(30 downto 29) = "10" then
									--S_MEM2 instruction
									RM <= '0'; --read memory operation is disabled
									WM <= '1'; --write memory operation is enabled
									S3 <= '0'; --at the output I'll have the address of the memory which have been accessed (coming from ALU). However in this case the value of S3 doesn't really matter
								
								end if;
							
							elsif InstrEncoding(28 downto 26) = "110" then
								--MOV instruction
								EN3 <= '1';
								EN2 <= '0';
								EN1 <= '0';
								RM  <= '0';
								WM  <= '0';
								S3  <= '0'; --at the output I'll have the copied value. However in this case the value of S3 doesn't really matter
							
							end if;	
						end if;
				
			end case;
			
		end process;

end architecture;
