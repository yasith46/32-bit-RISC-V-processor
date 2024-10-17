module cla32(
		input [31:0] A, B,
		input CIN,
		output OF,
		output [31:0] SUM, BAND, BXOR
	);
	
	wire [7:0] COUT;
	
	// CLA
	cla cla0(.A(A[3:0]  ), .B(B[3:0]), .CIN(CIN),     .COUT(COUT[0]), 
			   .SUM(SUM[3:0]  ), .BAND(BAND[3:0]  ), .BXOR(BXOR[3:0]  ));
				
	cla cla1(.A(A[7:4]  ), .B(B[7:4]), .CIN(COUT[0]), .COUT(COUT[1]), 
	         .SUM(SUM[7:4]  ), .BAND(BAND[7:4]  ), .BXOR(BXOR[7:4]  ));		
				
	cla cla2(.A(A[11:8] ), .B(B[11:8]), .CIN(COUT[1]), .COUT(COUT[2]), 
				.SUM(SUM[11:8] ), .BAND(BAND[11:8] ), .BXOR(BXOR[11:8] ));
				
	cla cla3(.A(A[15:12]), .B(B[15:12]), .CIN(COUT[2]), .COUT(COUT[3]), 
				.SUM(SUM[15:12]), .BAND(BAND[15:12]), .BXOR(BXOR[15:12]));
				
	cla cla4(.A(A[19:16]), .B(B[19:16]), .CIN(COUT[3]), .COUT(COUT[4]), 
				.SUM(SUM[19:16]), .BAND(BAND[19:16]), .BXOR(BXOR[19:16]));
				
	cla cla5(.A(A[23:20]), .B(B[23:20]), .CIN(COUT[4]), .COUT(COUT[5]), 
				.SUM(SUM[23:20]), .BAND(BAND[23:20]), .BXOR(BXOR[23:20]));
				
	cla cla6(.A(A[27:24]), .B(B[27:24]), .CIN(COUT[5]), .COUT(COUT[6]), 
				.SUM(SUM[27:24]), .BAND(BAND[27:24]), .BXOR(BXOR[27:24]));
				
	cla cla7(.A(A[31:28]), .B(B[31:28]), .CIN(COUT[6]), .COUT(COUT[7]), 
				.SUM(SUM[31:28]), .BAND(BAND[31:28]), .BXOR(BXOR[31:28]));
	
endmodule 