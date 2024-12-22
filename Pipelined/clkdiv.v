//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Yasith Silva
// 
// Create Date:    	11:29:15 17/10/2024 
// Design Name: 	 	Clock Divider
// Module Name:    	clkdiv
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			1
// Additional Comments: - Change required division
//
//////////////////////////////////////////////////////////////////////////////////

module clkdiv(
		input  CLKIN, RST,
		output CLKOUT
	);
	
	reg INT_FF0;
	
	always@(negedge RST) begin
		INT_FF0 <= 1'b0;
	end
	
	always@(posedge CLKIN) begin
		INT_FF0 <= ~INT_FF0;
	end
	
	assign CLKOUT = INT_FF0;
endmodule 