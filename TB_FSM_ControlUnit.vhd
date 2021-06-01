library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TB_FSM_ControlUnit is
end TB_FSM_ControlUnit;

architecture TEST of TB_FSM_ControlUnit is 

	signal Instruction:  std_logic_vector(31 downto 0);
	signal clock, reset: std_logic;
	signal RF1:          std_logic;	--read port1 enable
    signal RF2:          std_logic;	--read port2 enable
    signal WF1:          std_logic;  --write port enable
			 
    signal INP1:	     std_logic_vector(15 downto 0); --immediate
    signal INP2:	     std_logic_vector(15 downto 0); --immediate
	 
	signal RS1, RS2:     std_logic_vector(4 downto 0);  --read address1
		 
	signal RD:			 std_logic_vector(4 downto 0); -- RF data input			 
	signal EN1, S1, S2, ALU1, ALU2, EN2, RM, WM, EN3, S3:   std_logic;
		 
	
	

	component FSM_ControlUnit is 
	
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
	
	end component;
	
	begin
	
		reset <= '1';
				 
		clk_gen: process
		begin
			clock <= '0';
			wait for 1 ns;
			clock <= '1';
			wait for 1 ns;
		end process;
		
		Instruction <= "11111100011000010001000000000000", 			   -- it means ADD R3, R1, R2 ----> R2 <= R3  +   R1
		               "11111100011000010001000000000001" after 7  ns, -- it means SUB R3, R1, R2 ----> R2 <= R3  -   R1
		               "11111100010000010001000000000010" after 13 ns, -- it means AND R2, R1, R2 ----> R2 <= R2  AND R1
		               "11111100010000010010000000000011" after 19 ns, -- it means OR  R2, R1, R4 ----> R4 <= R2  OR  R1
		               --I-instructions
		               "00000000001000100000000000000011" after 25 ns, -- it means ADDI1 R1,R2,  3_d ---> R2 <= R1 + 3_d	3_d is INP1
		               "00100000001000100000000000000011" after 31 ns, -- it means ADDI2 R1,R2,3_d ---> R2 <= MEM[R1 + 3_d]	3_d is INP2
		               "00100100001000100000000000000011" after 37 ns, -- it means SUBI2 R1,R2,3_d ---> R2 <= R1 - 3_d	3_d is INP2
		               "00110000001000100000000000000011" after 43 ns, -- it means L_REG2  R1,R2,3_d ---> R2 <= R1 - 3_d	3_d is INP2
		               "00010000001000100000000000000011" after 49 ns, -- it means L_REG1  R1,R2,3_d ---> R2 <= R1 - 3_d	3_d is INP1
		               "01010100001000100000000000000011" after 55 ns, -- it means S_MEM2  R1,R2,3_d ---> MEM[R1 + 3_d] <= R2 3_d is INP2
		               "00010100001000100000000000000111" after 61 ns, -- it means S_REG1  R2,7_d --->    R2 <= 7_d       7_d is INP1  
		               "00011000001000100000000000000111" after 67 ns; -- it means MOV  R1, R2    --->    R2 <= R1        the immediate is not used: it is always forced to 0 to perform MOV
		               
		              
		              
		               --it should be simulated for 73 ns to test all the written instructions
		               --to simulate every transaction of Instruction signal, I have to simulate for 6ns * Instruction_values + 1ns (first ns is spent to wait the front edge of the clock to exit from idle)
		               --Instruction can change every 6 ns (3 clock cycles)
		               
		               
		               --I have to fill previous statement with other values in order to test I-instructions
		
		U: FSM_ControlUnit Port Map(InstrEncoding => Instruction,
									clk  =>  clock,
									rst  =>  reset,
									RF1  =>  RF1,
									RF2  =>  RF2, 
									WF1  =>  WF1,
									INP1 =>  INP1,
									INP2 =>  INP2,
									RS1  =>  RS1,
									RS2  =>  RS2,
									RD   =>  RD,
									EN1  =>  EN1,
									S1   =>  S1,
									S2   =>  S2,
								 	ALU1 =>  ALU1,
									ALU2 =>  ALU2,
									EN2  =>  EN2,
									RM   =>  RM,
									WM   =>  WM,
									EN3  =>  EN3,
									S3   =>  S3
						   );

end TEST;
