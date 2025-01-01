`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.01.2025 20:16:09
// Design Name: 
// Module Name: branchpred
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


module BranchPred(
    input wire clk,                     // Clock signal
    input wire reset,                   // Reset signal
    input wire [31:0] branch_addr,      // Branch instruction address
    input wire branch_taken,            // Actual branch outcome (1 = taken, 0 = not taken)
    output wire predicted_taken         // Predicted branch outcome
);

    // Parameters
    parameter BHT_SIZE = 64;            // Size of Branch History Table (e.g., 64 entries)
    localparam BHT_INDEX_BITS = 6;      // Number of index bits (log2(BHT_SIZE))

    // Branch History Table
    reg [0:0] BHT [BHT_SIZE-1:0];       // 1-bit entries for prediction
    wire [BHT_INDEX_BITS-1:0] index;    // Index for the BHT

    // Index extraction (lower bits of branch address)
    assign index = branch_addr[BHT_INDEX_BITS+1:2];

    // Prediction logic
    assign predicted_taken = BHT[index]; // Use the 1-bit predictor value

    // Integer for loop iteration (declared outside the block)
    integer i;

    // Update logic (on clock edge)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize BHT entries to "not taken" (0) on reset
            for (i = 0; i < BHT_SIZE; i = i + 1) begin
                BHT[i] <= 1'b0;
            end
        end else begin
            // Update BHT entry with actual outcome after branch resolution
            BHT[index] <= branch_taken;
        end
    end

endmodule