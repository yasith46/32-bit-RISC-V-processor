//////////////////////////////////////////////////////////////////////////////////
// Group: 		MetroniX 
// Designer: 		Bimsara Nawarathne, Yasith Silva
// 
// Create Date:    	20:39:23 10/16/2024 
// Design Name:  	Program Counter
// Module Name:    	ProgramCounter 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 		3
// Additional Comments:  
//
//////////////////////////////////////////////////////////////////////////////////



module ProgramCounter(
		input clk, rst,
		input [31:0] instruct_address_in,
		output reg [31:0] instruct_address
	);

	initial begin
        	instruct_address = 32'b0; // Initialize to zero for now. The compiler will point it to the right place initially
    	end

    	always @(posedge clk or negedge rst) begin
		if (rst == 1'b0) begin
			instruct_address <= 32'b0;
		end else begin 
			instruct_address <= instruct_address_in; // Increment by 4 (word-aligned)
		end
    	end

endmodule 
