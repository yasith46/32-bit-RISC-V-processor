module alu(
		input  [31:0] A, B,
		input  [3:0]  CTRL,
		input  [2:0]  BRANCHCONDITION,
		output reg [31:0] OUT,
		output reg BRANCHFLAG
	);
	
	wire [7:0] COUT;
	reg  [31:0] A_ALU, B_ALU;
	wire [31:0] SUM, BAND, BXOR, BOR;
	reg   CIN;
	
	// CLA
	cla cla0(.A(A_ALU[3:0]  ), .B({B_ALU[3:0]^{4{CIN}}}  ), .CIN(CIN),     .COUT(COUT[0]), 
			   .SUM(SUM[3:0]  ), .BAND(BAND[3:0]  ), .BXOR(BXOR[3:0]  ));
				
	cla cla1(.A(A_ALU[7:4]  ), .B({B_ALU[7:4]^{4{CIN}}}  ), .CIN(COUT[0]), .COUT(COUT[1]), 
	         .SUM(SUM[7:4]  ), .BAND(BAND[7:4]  ), .BXOR(BXOR[7:4]  ));		
				
	cla cla2(.A(A_ALU[11:8] ), .B({B_ALU[11:8]^{4{CIN}}} ), .CIN(COUT[1]), .COUT(COUT[2]), 
				.SUM(SUM[11:8] ), .BAND(BAND[11:8] ), .BXOR(BXOR[11:8] ));
				
	cla cla3(.A(A_ALU[15:12]), .B({B_ALU[15:12]^{4{CIN}}}), .CIN(COUT[2]), .COUT(COUT[3]), 
				.SUM(SUM[15:12]), .BAND(BAND[15:12]), .BXOR(BXOR[15:12]));
				
	cla cla4(.A(A_ALU[19:16]), .B({B_ALU[19:16]^{4{CIN}}}), .CIN(COUT[3]), .COUT(COUT[4]), 
				.SUM(SUM[19:16]), .BAND(BAND[19:16]), .BXOR(BXOR[19:16]));
				
	cla cla5(.A(A_ALU[23:20]), .B({B_ALU[23:20]^{4{CIN}}}), .CIN(COUT[4]), .COUT(COUT[5]), 
				.SUM(SUM[23:20]), .BAND(BAND[23:20]), .BXOR(BXOR[23:20]));
				
	cla cla6(.A(A_ALU[27:24]), .B({B_ALU[27:24]^{4{CIN}}}), .CIN(COUT[5]), .COUT(COUT[6]), 
				.SUM(SUM[27:24]), .BAND(BAND[27:24]), .BXOR(BXOR[27:24]));
				
	cla cla7(.A(A_ALU[31:28]), .B({B_ALU[31:28]^{4{CIN}}}), .CIN(COUT[6]), .COUT(COUT[7]), 
				.SUM(SUM[31:28]), .BAND(BAND[31:28]), .BXOR(BXOR[31:28]));
				
	
	parameter ADD = 4'b0000,  SUB = 4'b0001,  SLL = 4'b0010, 
				 SRL = 4'b0011,  SRA = 4'b0100,  AND = 4'b0101,
				 OR  = 4'b0110,  XOR = 4'b0111,  SLT = 4'b1000, 
				 SLTU = 4'b1001;
				 
	parameter BEQ = 3'b000, BNE = 3'b001, BLT = 3'b100,
				 BGE = 3'b101, BLTU= 3'b110, BGEU= 3'b111; 
		
		
	always@(*) begin
		case (CTRL)
			ADD: 
				begin 
					CIN <= 1'b0;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= SUM;     
				end
				
			SUB: 
				begin 
					CIN <= 1'b1;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= SUM;	    
				end
				
			AND: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= A;     
					B_ALU <= B;	   
					OUT <= BAND;    
				end	
				
			OR:  
				begin 
					CIN <= 1'bx;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= A|B;     
				end
				
			XOR: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= BXOR;    
				end
				
			SLL: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx;	
					OUT <= A << B;  
				end
				
			SRL: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					OUT <= A >> B;  
				end
				
			SRA: 
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					OUT <= A >>> B; 
				end
				
			SLT: 
				begin 
					CIN <= 1'b1;  
					A_ALU <= A;     
					B_ALU <= B;     
					OUT <= {31'b0, SUM[31]}; 
				end
				
			SLTU:
				begin 
					CIN <= 1'bx;  
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					OUT <= (A < B) ? 32'b1 : 32'b0; 
				end
				
			default:	
				begin	
					A_ALU <= 32'bx; 
					B_ALU <= 32'bx; 
					CIN	<= 1'bx; 
					OUT <= 32'bx;
				end
		endcase
		
		
		case(BRANCHCONDITION)
			BEQ:
				BRANCHFLAG <= |SUM;
				
			BNE:
				BRANCHFLAG <= ~|SUM;
				
			BLT:
				BRANCHFLAG <= OUT[0];
				
			BGE:
				BRANCHFLAG <= ~OUT[0];
				
			BLTU:
				BRANCHFLAG <= OUT[0];
				
			BGEU:
				BRANCHFLAG <= ~OUT[0];
				
			default:
				BRANCHFLAG <= 1'bx;		
		endcase
	end
				
endmodule 