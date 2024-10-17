`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:33:08 10/10/2024 
// Design Name: 
// Module Name:    DataMem 
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
module DataMem(
    input wire clk,
    input wire write_en,
    input wire read_en,
    input wire [31:0] address,    // Address bus width is 32 bits
    input wire [31:0] data_in,   // Data bus width is 32 bits
    output wire [31:0] data_out
);

    reg [31:0] DM [127:0];       // Data memory with 128 locations, can extend upto 2^30 locations

    // Combinational read
    assign data_out = (read_en) ? DM[address[31:2]] : 32'b0;	// First two bits of the address is reserved for byte addressing

    always @(posedge clk) begin
        if (write_en && !read_en) begin
            DM[address[31:2]] <= data_in;  // Write to memory on posedge of clk when write_en is high
        end
    end
endmodule


