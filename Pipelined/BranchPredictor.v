`timescale 1ns / 1ps

module BranchPredictor(
    input wire clk, BRANCHFLAG,                    // Clock signal
    input wire reset,                    // Reset signal
    input wire [31:0] branch_addr,      // Branch instruction address
    input wire branch_taken,             // Actual branch outcome (1 = taken, 0 = not taken)
    input wire [31:0] branch_target,    // Actual branch target address
    output reg predicted_taken,         // Predicted branch outcome
    output reg [31:0] predicted_addr    // Predicted next PC
);

    // Parameters
    parameter BHT_SIZE = 64;            // Size of Branch History Table (e.g., 64 entries)
    parameter BTB_SIZE = 64;            // Size of Branch Target Buffer (e.g., 64 entries)
    localparam BHT_INDEX_BITS = 6;      // Number of index bits (log2(BHT_SIZE))
    localparam BTB_INDEX_BITS = 6;      // Number of index bits (log2(BTB_SIZE))

    // Branch History Table
    reg [0:0] BHT [BHT_SIZE-1:0];       // 1-bit entries for prediction
    wire [BHT_INDEX_BITS-1:0] bht_index; // Index for the BHT

    // Branch Target Buffer
    reg [31:0] BTB [BTB_SIZE-1:0];     // 32-bit entries for target addresses
    wire [BTB_INDEX_BITS-1:0] btb_index; // Index for the BTB

    // Index extraction (lower bits of branch address)
    assign bht_index = branch_addr[BHT_INDEX_BITS+1:2];
    assign btb_index = branch_addr[BTB_INDEX_BITS+1:2];

    // Prediction logic
	 always@(*) begin
		#2;
		predicted_taken <= BHT[bht_index]; // Use the 1-bit predictor value
		predicted_addr  <= BTB[btb_index];  // Use the target address from BTB
	 end
	 
    // Integer for loop iteration (declared outside the block)
    integer i;

    // Update logic (on clock edge)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Initialize BHT entries to "not taken" (0) on reset
            for (i = 0; i < BHT_SIZE; i = i + 1) begin
                BHT[i] <= 1'b0;
            end
            // Initialize BTB entries to 0 on reset
            for (i = 0; i < BTB_SIZE; i = i + 1) begin
                BTB[i] <= 32'b0;
            end
        end else begin
				if (BRANCHFLAG) begin
					// Update BHT entry with actual outcome after branch resolution
					BHT[bht_index] <= branch_taken;
					// Update BTB entry with actual branch target address
					BTB[btb_index] <= branch_target;
				end
        end
    end

endmodule