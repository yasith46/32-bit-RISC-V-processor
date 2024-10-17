// 
//  +--------------------------------------------------------------------------------------------+
//  |  Instruction set (Which use imm. gen.)                                                     |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+
//  |  Inst.  |  Type  |  ALUOp  |  F3  |  F7 |  Immediate location   |  Format                  |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+
//  |  ADDI   |   I    |   10    |  000 |   X |    [31:20]            | [11:0]                   |
//  |  SLTI   |   I    |   10    |  010 |   X |    [31:20]            | [11:0]                   |
//  |  SLTIU  |   I    |   10    |  011 |   X |    [31:20]            | [11:0]                   |
//  |  XORI   |   I    |   10    |  100 |   X |    [31:20]            | [11:0]                   |
//  |  ORI    |   I    |   10    |  110 |   X |    [31:20]            | [11:0]                   |
//  |  ANDI   |   I    |   10    |  111 |   X |    [31:20]            | [11:0]                   |
//  |  SLLI   |   I    |   10    |  001 |   X |    [24:20] (no ext)   | [4:0]                    |
//  |  SRLI   |   I    |   10    |  101 |   X |    [24:20] (no ext)   | [4:0]                    |
//  |  SRAI   |   I    |   10    |  101 |   X |    [24:20] (no ext)   | [4:0]                    |
//  |  JALR   |   I    |   10    |  000 |   X |    [31:20]            | [11:0]                   |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+
//  |  LUI    |   U    |   XX    |  XXX |   X |    [31:12]   (up)     | [31:12]                  |
//  |  AUIPC  |   U    |   XX    |  XXX |   X |    [31:12]   (up)     | [31:12]                  |
//  |  JAL    |   UJ   |   XX    |  XXX |   X |    [31:12]   (up)     | [20][10:1][11][19:12]    |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+
//  |  SB     |   S    |   00 (?)|  000 |   X |    [31:25][11:7]      | [11:5][4:0]              |
//  |  SH     |   S    |   00 (?)|  001 |   X |    [31:25][11:7]      | [11:5][4:0]              |
//  |  SW     |   S    |   00 (?)|  010 |   X |    [31:25][11:7]      | [11:5][4:0]              |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+
//  |  LB     |   I    |   00 (?)|  000 |   X |    [31:20]            | [11:0]                   |
//  |  LH     |   I    |   00 (?)|  001 |   X |    [31:20]            | [11:0]                   |
//  |  LW     |   I    |   00 (?)|  010 |   X |    [31:20]            | [11:0]                   |
//  |  LBU    |   I    |   00 (?)|  100 |   X |    [31:20]            | [11:0]                   |
//  |  LHU    |   I    |   00 (?)|  101 |   X |    [31:20]            | [11:0]                   |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+
//  |  BEQ    |   SB   |   01    |  000 |   X |    [31:25][11:7]      | [12][10:5][4:1][11]      |
//  |  BNE    |   SB   |   01    |  001 |   X |    [31:25][11:7]      | [12][10:5][4:1][11]      |
//  |  BLT    |   SB   |   01    |  100 |   X |    [31:25][11:7]      | [12][10:5][4:1][11]      |
//  |  BGE    |   SB   |   01    |  101 |   X |    [31:25][11:7]      | [12][10:5][4:1][11]      |
//  |  BLTU   |   SB   |   01    |  110 |   X |    [31:25][11:7]      | [12][10:5][4:1][11]      |
//  |  BGEU   |   SB   |   01    |  111 |   X |    [31:25][11:7]      | [12][10:5][4:1][11]      |
//  +---------+--------+---------+------+-----+-----------------------+--------------------------+

module immediate_gen(
		input  [31:0] INSTRUCTION,
		output reg [31:0] IMMEDIATE_OUT
	);
	
	always@(*) begin
		case(INSTRUCTION[6:0])				
			7'b0110111:							// LUI
				begin
					IMMEDIATE_OUT[31:12] <= INSTRUCTION[31:21];
					IMMEDIATE_OUT[11:0]  <= 12'b0;
				end
			
			7'b0010111:							// AUIPC
				begin
					IMMEDIATE_OUT[31:12] <= INSTRUCTION[31:21];
					IMMEDIATE_OUT[11:0]  <= 12'b0;
				end
				
			7'b1101111:							// JAL
				begin
					IMMEDIATE_OUT[31:20] <= {12{INSTRUCTION[31]}};
					IMMEDIATE_OUT[19:12] <= INSTRUCTION[19:12];
					IMMEDIATE_OUT[11]    <= INSTRUCTION[20];
					IMMEDIATE_OUT[10:1]  <= INSTRUCTION[30:21];
					IMMEDIATE_OUT[0]     <= 1'b0;
				end
				
			7'b1100111:							// JALR
				begin
					IMMEDIATE_OUT[31:12] <= {20{INSTRUCTION[31]}};
					IMMEDIATE_OUT[11:0]  <= INSTRUCTION[31:20];
				end
				
			7'b0010011:							// SLLI / SRLI / SRAI
				begin
					if ((INSTRUCTION[14:12] == 001)|(INSTRUCTION[14:12] == 001)) begin
						// SLLI / SRLI / SRAI
						IMMEDIATE_OUT[31:5]  <= 27'b0;
						IMMEDIATE_OUT[4:0]   <= INSTRUCTION[24:20];
						
					end else begin
						// Other I type
						IMMEDIATE_OUT[31:12] <= {12{INSTRUCTION[31]}};
						IMMEDIATE_OUT[11:0]  <= INSTRUCTION[31:20];
					end						
				end
				
			7'b0100011:		// Store
				begin
					IMMEDIATE_OUT[31:12] <= {20{INSTRUCTION[31]}};
					IMMEDIATE_OUT[11:5]  <= INSTRUCTION[31:25];
					IMMEDIATE_OUT[4:0]   <= INSTRUCTION[11:7];
				end
				
			7'b0000011:		// Load
				begin
					IMMEDIATE_OUT[31:12] <= {20{INSTRUCTION[31]}};
					IMMEDIATE_OUT[11:0]  <= INSTRUCTION[31:20];
				end
				
			7'b1100011:		// Branch
				begin
					IMMEDIATE_OUT[31:13] <= {19{INSTRUCTION[31]}};
					IMMEDIATE_OUT[12]    <= INSTRUCTION[31];
					IMMEDIATE_OUT[11]    <= INSTRUCTION[7];
					IMMEDIATE_OUT[10:5]  <= INSTRUCTION[30:25];
					IMMEDIATE_OUT[4:1]   <= INSTRUCTION[11:8];
					IMMEDIATE_OUT[0]     <= 1'b0;
				end
				
			default:
				IMMEDIATE_OUT[31:0] <= 32'bx;
				
		endcase
	end
endmodule 