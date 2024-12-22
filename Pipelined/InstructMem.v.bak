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
		input [31:0] instruct_address_in,
		output reg [31:0] inst_out   // Instruction bus width is 32 bits
	);

	(* ramstyle = "M9K" *) reg [31:0] IM [255:0];    // Data memory with 128 locations // Can extend 128 to 2^30
		
	initial begin
		IM[0]  = 32'h08000313;          	//  0: li	   t1,128
		IM[1]  = 32'h00032383;         	//  4: lw	   t2,0(t1)
		IM[2]  = 32'h3e800093;          	//  8: li	   ra,1000
		IM[3]  = 32'h7d008113;          	//  c: addi	   sp,ra,2000
		IM[4]  = 32'hc1810293;          	// 10: addi	   t0,sp,-1000

		IM[5]  = 32'h405101b3;          	// 14: sub	   gp,sp,t0
		IM[6]  = 32'h00019463;          	// 18: bnez	   gp,20 
		IM[7]  = 32'h00c0006f;          	// 1c: j	      28 

		IM[8]  = 32'hfff28293;          	// 20: addi	   t0,t0,-1
		IM[9]  = 32'hff1ff06f;          	// 24: j	      14 

		IM[10] = 32'h12345237;          	// 28: lui	   tp,0x12345
		IM[11] = 32'h67820213;          	// 2c: addi    tp,tp,0x678
		IM[12] = 32'h00432023;          	// 30: sw	   tp,0(t1)
		IM[13] = 32'h00000013;          	// 34: nop
		
		IM[14] = 32'hfffff337;				// 38: lui		t1,0xfffff
		IM[15] = 32'h40135313;				// 3c: srai    t1,t1,1
		IM[16] = 32'h7fe30313;				// 40: addi    t1,t1,0x7fe
		IM[17] = 32'h00432023;				// 44: sw		tp,0(t1)
		IM[18] = 32'h00000013;				//	48: nop
		IM[19] = 32'h00232023;				//	4c: sw		sp,0(t1)
	end
	
	always @(*) begin
		inst_out <= IM[instruct_address_in[31:2]];
	end

endmodule 