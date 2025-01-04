`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Yasith Silva
// 
// Create Date:    	18:59:49 10/10/2024 
// Design Name: 	 	Main Arithmetic Logic Unit
// Module Name:    	alu 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments:  
//
//////////////////////////////////////////////////////////////////////////////////



module alu(
		input  [31:0] A, B,
		input  [3:0]  CTRL,
		input  [3:0]  BRANCHCONDITION,
		output reg [31:0] OUT,
		output reg BRANCHFLAG
	);
	
	reg  [31:0] A_ALU, B_ALU;
	wire [31:0] SUM, BAND, BXOR;
	reg   CIN;
	
	// CLA
	cla32 cla32_0(.A(A_ALU),  .B(B_ALU^{32{CIN}}),  .CIN(CIN),  .OF(),  .SUM(SUM),  .BAND(BAND),  .BXOR(BXOR));
				
	parameter ADD = 4'b0000,  SUB = 4'b0001,  SLL = 4'b0010, 
				 SRL = 4'b0011,  SRA = 4'b0100,  AND = 4'b0101,
				 OR  = 4'b0110,  XOR = 4'b0111,  SLT = 4'b1000, 
				 SLTU = 4'b1001;
				 
	parameter BEQ = 4'b1000, BNE = 4'b1001, BLT = 4'b1100,
				 BGE = 4'b1101, BLTU= 4'b1110, BGEU= 4'b1111,
				 JMP = 4'b1010, NON = 4'b0xxx; 
		
		
	always@(*) begin
		//#2;
		case (CTRL)
			ADD: 
				begin 
					CIN <= 1'b0;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= SUM;     
				end
				
			SUB: 
				begin 
					CIN <= 1'b1;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= SUM;	    
				end
				
			AND: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= A;     
					B_ALU <= B;	   
					OUT <= BAND;    
				end	
				
			OR:  
				begin 
					CIN <= 1'bx;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= A|B;     
				end
				
			XOR: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= BXOR;    
				end
				
			SLL: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx;	
					OUT <= A << B;  
				end
				
			SRL: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					OUT <= A >> B;  
				end
				
			SRA: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					OUT <= $signed(A) >>> B; 
				end
				
			SLT: 
				begin 
					CIN <= 1'b1;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= {31'b0, SUM[31]}; 
				end
				
			SLTU:
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					OUT <= (A < B) ? 32'b1 : 32'b0; 
				end
				
			default:	
				begin	
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					CIN	<= 1'bx; 
					OUT <= 32'bx;
				end
		endcase
		
		
		case(BRANCHCONDITION)
			BEQ:
				BRANCHFLAG <= ~|{SUM};
				
			BNE:
				BRANCHFLAG <= |{SUM};
				
			BLT:
				BRANCHFLAG <= OUT[0];
				
			BGE:
				BRANCHFLAG <= ~OUT[0];
				
			BLTU:
				BRANCHFLAG <= OUT[0];
				
			BGEU:
				BRANCHFLAG <= ~OUT[0];
				
			JMP:
				BRANCHFLAG <= 1'b1;
				
			NON:
				BRANCHFLAG <= 1'b0;
			default:
				BRANCHFLAG <= 1'b0;
		endcase
	end
				
endmodule 