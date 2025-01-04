`timescale 1ns / 1ps

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
		IM[0]  = 32'h08000313;          	//  0: li	   r6,128		0x80
		IM[1]  = 32'h00032383;         	//  4: lw	   r7,0(r6)		
		IM[2]  = 32'h3e800093;          	//  8: li	   r1,1000		0x3e8
		IM[3]  = 32'h7d008113;          	//  c: addi	   r2,r1,2000  0x7d0
		IM[4]  = 32'hc1810293;          	// 10: addi	   r5,r2,-1000

		IM[5]  = 32'h405101b3;          	// 14: sub	   r3,r2,r5
		IM[6]  = 32'h00019463;          	// 18: bnez	   r3,20 
		IM[7]  = 32'h00c0006f;          	// 1c: j	      28 

		IM[8]  = 32'h3e828293;          	// 20: addi	   r5,r5,1000
		IM[9]  = 32'hff1ff06f;          	// 24: j	      14 

		IM[10] = 32'h12345237;          	// 28: lui	   r4,0x12345
		IM[11] = 32'h67820213;          	// 2c: addi    r4,r4,0x678
		IM[12] = 32'h00432023;          	// 30: sw	   r4,0(r6)
		IM[13] = 32'h00000013;          	// 34: nop
		
		IM[14] = 32'hfffff337;				// 38: lui		r6,0xfffff
		IM[15] = 32'h40135313;				// 3c: srai    r6,r6,1
		IM[16] = 32'h7fe30313;				// 40: addi    r6,r6,0x7fe
		IM[17] = 32'h00432023;				// 44: sw		r4,0(r6)
		IM[18] = 32'h00000013;				//	48: nop
		IM[19] = 32'h00232023;				//	4c: sw		r2,0(r6)
		IM[20] = 32'h00000013;           // 50: nop
		IM[21] = 32'h00000013;           // 54: nop
	end
	
	always @(*) begin
		#2;
		inst_out <= IM[instruct_address_in[31:2]];
	end

endmodule 