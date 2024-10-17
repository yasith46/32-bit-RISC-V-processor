`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:48:01 10/10/2024 
// Design Name: 
// Module Name:    InstructMem 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module InstructMem(
		input wire [31:0] Pro_count,    // Program Counter bus width is 32 bits
		output wire [31:0] inst_out   // Instruction bus width is 32 bits
    );

		reg [31:0] IM [127:0];    // Data memory with 128 locations // Can extend 128 to 2^30
		
		// No need to consider first 2 bits because they are used to address bytes seperately
		assign inst_out = IM[Pro_count[31:2]];		// Load instruction at the given address to the output
		
		initial begin
        // Preload some instructions into instruction memory
        IM[1] = 32'h00430820; // ADD R1, R2, R3
        IM[2] = 32'h00851022; // SUB R4, R5, R6
        IM[3] = 32'h3C071064; // LOAD R7, 100
        // ... More instructions can be loaded here
    end

endmodule
