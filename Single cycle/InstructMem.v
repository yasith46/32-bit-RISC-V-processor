//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Bimsara Nawarathne
// 
// Create Date:    	10:48:01 10/10/2024 
// Design Name: 	 	Instruction memory
// Module Name:    	InstructMem 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments: - Change initial block with the intended instruction memory,
//								  or make it read from a hex file  
//
////////////////////////////////////////////////////////////////////////////

module InstructMem(
		input clk, rst,
		input [31:0] instruct_address_in,
		output reg [31:0] instruct_address,
		output reg [31:0] inst_out   // Instruction bus width is 32 bits
   );

	(* ramstyle = "M9K" *) reg [31:0] IM [512:0];    // Data memory with 128 locations // Can extend 128 to 2^30
		
	initial begin
		IM[0]  = 32'h08000313;          	//  0: li	   t1,128
		IM[1]  = 32'h00032383;         	//  4: lw	   t2,0(t1)
		IM[2]  = 32'h00032383;          	//  8: stall
		IM[3]  = 32'h3e800093;          	//  c: li	   ra,1000
		IM[4]  = 32'h7d008113;          	// 10: addi	   sp,ra,2000
		IM[5]  = 32'hc1810293;          	// 14: addi	   t0,sp,-1000

		IM[6]  = 32'h405101b3;          	// 18: sub	   gp,sp,t0
		IM[7]  = 32'h00019463;          	// 1c: bnez	   gp,24 
		IM[8]  = 32'h00c0006f;          	// 20: j	      2c 

		IM[9]  = 32'hfff28293;          	// 24: addi	   t0,t0,-1
		IM[10] = 32'hff1ff06f;          	// 28: j	      18 

		IM[11] = 32'h12345237;          	// 2c: lui	   tp,0x12345
		IM[12] = 32'h67820213;          	// 30: addiw   tp,tp,1656
		IM[13] = 32'h00432023;          	// 34: sw	   tp,0(t1)
		IM[14] = 32'h00000013;          	// 38: nop
		IM[15] = 32'h00032f83;
		IM[16] = 32'h00032f83;
	end
	
	always @(posedge clk or negedge rst) begin
			if (rst == 1'b0) begin
				instruct_address <= 32'b0;
				inst_out <= IM[30'b0];  // No need to consider first 2 bits because they are used to address bytes seperately
			end else begin 
				instruct_address <= instruct_address_in; // Increment by 4 (word-aligned)
				inst_out <= IM[instruct_address_in[31:2]];
			end		
   end

endmodule 