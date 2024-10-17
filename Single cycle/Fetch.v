`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:59 10/16/2024 
// Design Name: 
// Module Name:    Fetch 
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
module Fetch(
    output [31:0] instruction,       // The fetched instruction
	 output [31:0] current_procount,	 // The current program counter
    input clk                        // Clock signal
    );

    wire [31:0] instruct_address;    // Address of the next instruction
    wire [31:0] inst;                // The instruction from instruction memory

    // Instantiate the ProgramCounter module
    ProgramCounter pc(
        .instruct_address(instruct_address),
        .clk(clk)
    );

    // Instantiate the InstructMem module (assume InstructMem takes address and returns instruction)
    InstructMem imem(
        .Pro_count(instruct_address[31:0]),  // Pass the instruction address from ProgramCounter
        .inst_out(inst)           // Fetch the instruction corresponding to the address
    );

    // Output the fetched instruction and the current program counter
    assign instruction = inst;
	 assign current_procount = instruct_address[31:0];

endmodule

