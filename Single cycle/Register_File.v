`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.10.2024 18:57:22
// Design Name: 
// Module Name: Register_File
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Register_File(
 // inputs   
    input wire[4:0] Read_reg01, // RS1 instruction value for reading register 01
    input wire [4:0] Read_reg02, // RS2 instruction value for reading register 02
    input wire [4:0] Write_reg,   // RD instruction value for writing register
    input wire [31:0] Write_data, // 32 bit data to be written to register

//outputs
    output reg [31:0] Read_data01,
    output reg [31:0] Read_data02,
    
// control signals
    input wire write_signal ,
    input wire clk
    //input wire rst
   );
   
    // Declare 32 registers, each 8 bits wide
    reg [31:0] registers [31:0]; 
    //integer i;
     // Read logic
    always @(*) begin
        Read_data01 = registers[Read_reg01];
        Read_data02 = registers[Read_reg02];
    end
     // Write logic (triggered on clock edge)
    always @(posedge clk) begin
        //if (rst) begin
            // Reset all registers to 0
            
          //  for (i = 0; i < 32; i = i + 1) begin
               // registers[i] <= 32'b0;
           // end
       // end else 
        if (write_signal) begin
            // Write to the specified register
            registers[Write_reg] <= Write_data;
        end
    end  
    
endmodule
