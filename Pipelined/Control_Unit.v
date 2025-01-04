`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Isuranga Senavirathne, Yasith Silva
// 
// Create Date:    	19.10.2024 16:05:53 
// Design Name: 	 	Control Unit
// Module Name:    	Control_Unit 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			3
// Additional Comments: - Add new cases for additional / custom instructions,
//								  currently any insturction out of base set considered as NOP
//
//////////////////////////////////////////////////////////////////////////////////



module Control_Unit(
    input [31:0] instruction,  // 32-bit instruction input
	 input clk,
	 output reg MEMWRITE, ALUSRC, REGWRITE, IMMTOREG, STALLSIG,
	 output reg [1:0] ALUOP, BRANCH, REGWRITESEL
);

    always @(*) begin
	 #2;
        case (instruction[6:0])
            7'b0110011: // R-type instruction
					begin
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'b0;
						IMMTOREG     <= 1'b0;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b10;
						BRANCH       <= 2'b01;
						REGWRITESEL  <= 2'b00;
					end
				
            7'b0010011: 
					begin
					// I-type instruction (arithmetic operations)
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'b1;
						IMMTOREG     <= 1'b0;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b10;
						BRANCH       <= 2'b01;
						REGWRITESEL  <= 2'b00;
					end
					
            7'b0000011: 
					begin
						// I-type instruction (load)
						//MEMREAD      <= 1'b1; 
						ALUSRC       <= 1'b1;
						IMMTOREG     <= 1'b1;
						STALLSIG		 <= 1'b1;
						
						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b00;
						BRANCH       <= 2'b01;
						REGWRITESEL  <= 2'b01;
					end
					
            7'b1100111: 
					begin
						// I-type instruction (jalr-jump and link register)
						//MEMREAD      <= 1'bx;
						ALUSRC       <= 1'b1;
						IMMTOREG     <= 1'bx;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b11;
						BRANCH       <= 2'b10;
						REGWRITESEL  <= 2'b10;
					end
					
            7'b0100011: 
					begin
						// S-type instruction (store)
						//MEMREAD      <= 1'b0;
						ALUSRC       <= 1'b1;
						IMMTOREG     <= 1'b0;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b0;
						MEMWRITE     <= 1'b1;
						
						// 2 wire signals
						ALUOP        <= 2'b00;
						BRANCH       <= 2'b01;
						REGWRITESEL  <= 2'bxx;
					end
					
            7'b1100011: 
					begin
						// SB-type instruction (Branch)
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'b0;
						IMMTOREG     <= 1'bx;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b0;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b01;
						BRANCH       <= 2'b11;
						REGWRITESEL  <= 2'bxx;
					end
					
            7'b0110111: 
					begin
						// U-type instruction (LUI-load upper immiediate)
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'bx;
						IMMTOREG     <= 1'b1;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'bxx;		// would have to edit
						BRANCH       <= 2'b01;
						REGWRITESEL  <= 2'b00;		// have to see
					end
					
            7'b0010111: 
					begin
						// U-type instruction (AUIPC - add upper immediate to PC)
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'bx;
						IMMTOREG     <= 1'bx;
						STALLSIG		 <= 1'b0;

						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b11;
						BRANCH       <= 2'b11;
						REGWRITESEL  <= 2'b11;
					end
					
            7'b1101111: 
					begin
						// J-type instruction (JAL)
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'bx;
						IMMTOREG     <= 1'bx;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b1;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'b11;
						BRANCH       <= 2'b11;
						REGWRITESEL  <= 2'b10;
					end
            
            default: 
					begin
						// For instructions other than base set
						//MEMREAD      <= 1'bx; 
						ALUSRC       <= 1'bx;
						IMMTOREG     <= 1'bx;
						STALLSIG		 <= 1'b0;
						
						REGWRITE     <= 1'b0;
						MEMWRITE     <= 1'b0;
						
						// 2 wire signals
						ALUOP        <= 2'bxx;
						BRANCH       <= 2'b01;
						REGWRITESEL  <= 2'bxx;
					end
        endcase
    end
endmodule 