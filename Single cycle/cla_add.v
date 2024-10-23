//////////////////////////////////////////////////////////////////////////////////
// Group: 		MetroniX 
// Designer: 		Yasith Silva
// 
// Create Date:    	18:43:07  22/10/2024 
// Design Name:  	CLA without AND XOR outputs
// Module Name:    	cla_add 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 		1
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////



module cla_add(
		input  [3:0] A, B,
		input  CIN,
		output COUT,
		output [3:0] SUM
	);
	
	// For carry calculation
	
	wire [3:0] P, G; 
	assign P = A ^ B;
	assign G = A & B;
	
	wire [3:0] CARRY;
	
	assign CARRY[0] = G[0] | (P[0] & CIN);																															// CARRY[0]
	assign CARRY[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & CIN);																							// CARRY[1]
	assign CARRY[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & CIN);													// CARRY[2]
	assign CARRY[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & CIN); // CARRY[3]
	
	
	assign COUT  = CARRY[3];
	
	// Adder
	assign SUM = P ^ {CARRY[2:0], CIN};
endmodule 
