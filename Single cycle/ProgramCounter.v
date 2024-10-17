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
    input clk,
	 input [31:0] instruct_address_in
    );

    always @(posedge clk) begin
        instruct_address <= instruct_address_in;
    end

endmodule

