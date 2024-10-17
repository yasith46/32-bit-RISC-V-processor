`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:03:04 10/16/2024
// Design Name:   Fetch
// Module Name:   E:/ISE Projects/Processor/Fetch_tb.v
// Project Name:  Processor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Fetch
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Fetch_tb;

    reg clk;
    wire [31:0] instruction;
	 wire [31:0]	pro_count;

    // Instantiate the Fetch module
    Fetch fetch(
        .instruction(instruction),
		  .current_procount(pro_count),
        .clk(clk)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with 10-time units period
    end

    // Simulation
    initial begin
        // Monitor the output
        $monitor("Time = %0t, Instruction = %h, Program Coounter = %h", $time, instruction, pro_count);

        // Run the simulation for 100 time units
        #100;

        $stop; // Stop simulation
    end

endmodule


