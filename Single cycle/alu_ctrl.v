//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Yasith Silva
// 
// Create Date:    	05:33:22 13/10/2024 
// Design Name: 	 	ALU Controller
// Module Name:    	alu_ctrl 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
// 
//  +--------------------------------------------------+
//  |  Instruction set                                 | 
//  +---------+--------+---------+------+-----+--------+
//  |  Inst.  |  Type  |  ALUOp  |  F3  |  F7 |  OP    |
//  +---------+--------+---------+------+-----+--------+
//  |  ADD    |   R    |   10    |  000 |   0 |  ADD   |
//  |  SUB    |   R    |   10    |  000 |   1 |  SUB   |
//  |  SLL    |   R    |   10    |  001 |   0 |  SLL   |
//  |  SLT    |   R    |   10    |  010 |   0 |  SLT   |
//  |  SLTU   |   R    |   10    |  011 |   0 |  SLTU  |
//  |  XOR    |   R    |   10    |  100 |   0 |  XOR   |
//  |  SRL    |   R    |   10    |  101 |   0 |  SRL   |  
//  |  SRA    |   R    |   10    |  101 |   1 |  SRA   | 
//  |  OR     |   R    |   10    |  110 |   0 |  OR    |
//  |  AND    |   R    |   10    |  111 |   0 |  AND   |
//  +---------+--------+---------+------+-----+--------+
//  |  ADDI   |   I    |   10    |  000 |   X |  ADD   |
//  |  SLTI   |   I    |   10    |  010 |   X |  SLT   |
//  |  SLTIU  |   I    |   10    |  011 |   X |  SLTU  |
//  |  XORI   |   I    |   10    |  100 |   X |  XOR   |
//  |  ORI    |   I    |   10    |  110 |   X |  OR    |
//  |  ANDI   |   I    |   10    |  111 |   X |  AND   |
//  |  SLLI   |   I    |   10    |  001 |   X |  SLL   |
//  |  SRLI   |   I    |   10    |  101 |   X |  SRL   |
//  |  SRAI   |   I    |   10    |  101 |   X |  SRA   |
//  +---------+--------+---------+------+-----+--------+
//  |  JALR   |   I    |   11    |  000 |   X |  ADD   |
//  +---------+--------+---------+------+-----+--------+
//  |  LUI    |   U    |   XX    |  XXX |   X |  -     |
//  |  AUIPC  |   U    |   11    |  XXX |   X |  -     |
//  |  JAL    |   UJ   |   11    |  XXX |   X |  -     |
//  +---------+--------+---------+------+-----+--------+
//  |  SB     |   S    |   00    |  000 |   X |  ADD   |
//  |  SH     |   S    |   00    |  001 |   X |  ADD   |
//  |  SW     |   S    |   00    |  010 |   X |  ADD   |
//  +---------+--------+---------+------+-----+--------+
//  |  LB     |   I    |   00    |  000 |   X |  ADD   |
//  |  LH     |   I    |   00    |  001 |   X |  ADD   |
//  |  LW     |   I    |   00    |  010 |   X |  ADD   |
//  |  LBU    |   I    |   00    |  100 |   X |  ADD   |
//  |  LHU    |   I    |   00    |  101 |   X |  ADD   |
//  +---------+--------+---------+------+-----+--------+
//  |  BEQ    |   SB   |   01    |  000 |   X |  SUB   |
//  |  BNE    |   SB   |   01    |  001 |   X |  SUB   |
//  |  BLT    |   SB   |   01    |  100 |   X |  SLT   |
//  |  BGE    |   SB   |   01    |  101 |   X |  SLT   |
//  |  BLTU   |   SB   |   01    |  110 |   X |  SLTU  |
//  |  BGEU   |   SB   |   01    |  111 |   X |  SLTU  |
//  +---------+--------+---------+------+-----+--------+
//  |  FENCE  |   I    |   00    |  000 |   X |  -     |
//  |  ECALL  |   I    |   00    |  000 |   X |  -     |
//  |  EBREAK |   I    |   00    |  000 |   X |  -     |
//  +---------+--------+---------+------+-----+--------+


module alu_ctrl(
		input [1:0] ALUOp,
		input [2:0] FUNC3,
		input FUNC7,
		output reg [3:0] ALUCTRL,
		output reg [2:0] BRANCHCONDITION
	);
	
	
	parameter ADD = 4'b0000,  SUB = 4'b0001,  SLL = 4'b0010, 
				 SRL = 4'b0011,  SRA = 4'b0100,  AND = 4'b0101,
				 OR  = 4'b0110,  XOR = 4'b0111,  SLT = 4'b1000, 
				 SLTU = 4'b1001;
				 
	
	always@(*) begin
		if (ALUOp == 2'b10) begin	// ----------------- R type / I type
			case (FUNC3)
				3'b000:
					begin
						if (FUNC7 == 1'b1)
							ALUCTRL <= SUB;
						else
							ALUCTRL <= ADD;
					end
					
				3'b001:
					ALUCTRL <= SLL;
					
				3'b010:
					ALUCTRL <= SLT;
					
				3'b011:
					ALUCTRL <= SLTU;
					
				3'b100:
					ALUCTRL <= XOR;
					
				3'b101:
					begin
						if (FUNC7 == 1'b0) 
							ALUCTRL <= SRL;
						else 
							ALUCTRL <= SRA;
					end
					
				3'b110:
					ALUCTRL <= OR;
					
				3'b111:
					ALUCTRL <= AND;
					
				default:
					ALUCTRL <= 4'bx;
					
			endcase		
		end else if (ALUOp == 2'b00) begin
			ALUCTRL <= ADD;
			
		end else if (ALUOp == 2'b01) begin
			case(FUNC3[2:1])
				2'b00:
					ALUCTRL <= SUB;
					
				2'b10:
					ALUCTRL <= SLT;
					
				2'b11:
					ALUCTRL <= SLTU;
					
				default:
					ALUCTRL <= 4'bx;
					
			endcase
		end else begin
			ALUCTRL <= 4'bx;
			
		end
		
		if (ALUOp == 2'b01) begin
			BRANCHCONDITION <= FUNC3;
		end else if (ALUOp == 2'b11) begin
			BRANCHCONDITION <= 3'b010;
		end else begin
			BRANCHCONDITION <= 3'bx;
		end
					
				
	end	
endmodule 