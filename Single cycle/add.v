//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Yasith Silva
// 
// Create Date:    	18:46:59  22/10/2024 
// Design Name: 	 	32 Network of CLA w/o XOR or AND outputs
// Module Name:    	add 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments:  
//
//////////////////////////////////////////////////////////////////////////////////



module add(
		input [31:0] A, B,
		input CIN,
		output OF,
		output [31:0] SUM
	);
	
	wire [7:0] COUT;
	
	// CLA
	cla_add cla0(.A(A[3:0]  ),	.B(B[3:0]),	.CIN(CIN),	.COUT(COUT[0]),	  .SUM(SUM[3:0]  ));
	cla_add cla1(.A(A[7:4]  ), 	.B(B[7:4]), 	.CIN(COUT[0]), 	.COUT(COUT[1]),	  .SUM(SUM[7:4]  ));					
	cla_add cla2(.A(A[11:8] ), 	.B(B[11:8]), 	.CIN(COUT[1]), 	.COUT(COUT[2]),   .SUM(SUM[11:8] ));
	cla_add cla3(.A(A[15:12]), 	.B(B[15:12]),	.CIN(COUT[2]),  .COUT(COUT[3]),   .SUM(SUM[15:12]));
	cla_add cla4(.A(A[19:16]), 	.B(B[19:16]), 	.CIN(COUT[3]), 	.COUT(COUT[4]),   .SUM(SUM[19:16]));
	cla_add cla5(.A(A[23:20]), 	.B(B[23:20]), 	.CIN(COUT[4]), 	.COUT(COUT[5]),   .SUM(SUM[23:20]));	
	cla_add cla6(.A(A[27:24]), 	.B(B[27:24]), 	.CIN(COUT[5]),  .COUT(COUT[6]),   .SUM(SUM[27:24]));	
	cla_add cla7(.A(A[31:28]), 	.B(B[31:28]),   .CIN(COUT[6]), 	.COUT(COUT[7]),   .SUM(SUM[31:28]));
				
	assign OF = COUT[7];
	
endmodule 
