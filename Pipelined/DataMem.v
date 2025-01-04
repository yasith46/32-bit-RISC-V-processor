`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Bimsara Nawarathne
// 
// Create Date:    	08:33:08 10/10/2024 
// Design Name: 	 	Data memory
// Module Name:    	DataMem 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments: - Change initial block with the intended data memory,
//								  or make it read from a hex file  
//
//////////////////////////////////////////////////////////////////////////////////



module DataMem(
		input wire clk,
		input wire write_en,
		//input wire read_en,
		input wire [31:0] address,    // Address bus width is 32 bits
		input wire [31:0] data_in,   // Data bus width is 32 bits
		output reg [31:0] data_out
	);

   (* ramstyle = "M9K" *) reg [31:0] DM [255:0];       // Data memory with 128 locations, can extend upto 2^30 locations

   // Combinational read
   
   always @(negedge clk) begin
		if (write_en) begin
			//#2;
			DM[address[31:2]] <= data_in;  // Write to memory on posedge of clk when write_en is high
      end else begin
			//#2;
			data_out <= DM[address[31:2]];	// First two bits of the address is reserved for byte addressing
		end
   end
	 
	initial begin
		DM[31] = 32'h0012ffea;
		DM[32] = 32'hdeadbeef;
		DM[33] = 32'haffecced;
	end
endmodule 