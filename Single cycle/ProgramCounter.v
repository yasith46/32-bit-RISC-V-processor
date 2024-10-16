`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:39:23 10/16/2024 
// Design Name: 
// Module Name:    ProgramCounter 
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

// Jumping case also has to be implemented here
module ProgramCounter(
    output reg [31:0] instruct_address, // Declare as reg since it's updated in an always block
    input clk
    );

    initial begin
        instruct_address = 32'b0; // Initialize to zero for now. The compiler will point it to the right place initially
    end

    always @(posedge clk) begin
        instruct_address <= instruct_address + 32'd4; // Increment by 4 (word-aligned)
    end

endmodule

