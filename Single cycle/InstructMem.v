//////////////////////////////////////////////////////////////////////////////////
// Group: 		MetroniX 
// Designer:		Bimsara Nawarathne
// 
// Create Date:    	10:48:01 10/10/2024 
// Design Name:  	Instruction memory
// Module Name:    	InstructMem 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments: - Change initial block with the intended instruction memory,
//			  or make it read from a hex file  
//
//////////////////////////////////////////////////////////////////////////////////



module InstructMem(
		input wire [31:0] Pro_count,    // Program Counter bus width is 32 bits
		output wire [31:0] inst_out   // Instruction bus width is 32 bits
	);

	reg [31:0] IM [127:0];    // Data memory with 128 locations // Can extend 128 to 2^30
		
	// No need to consider first 2 bits because they are used to address bytes seperately
	assign inst_out = IM[Pro_count[31:2]];		// Load instruction at the given address to the output
		
	initial begin
		IM[1] = 32'h3e800093;		//		li	ra,1000
		IM[2] = 32'h7d008113;    	//   	addi	sp,ra,2000
		IM[3] = 32'hc1810193;    	//   	addi	gp,sp,-1000
		IM[4] = 32'h83018213;   	//		addi	tp,gp,-2000
		IM[5] = 32'h3e820293;    	//   	addi	t0,tp,1000 # 3e8 <_sstack+0x334>
		IM[6] = 32'h08000313;    	//   	li	t1,128
		IM[7] = 32'h00430313;    	//		addi	t1,t1,4
		IM[8] = 32'h405303b3;    	//   	sub	t2,t1,t0
		IM[9] = 32'h00732023;    	//   	sw	t2,0(t1)
		IM[10] = 32'h00032403;   	//   	lw	s0,0(t1)
	end

endmodule 
