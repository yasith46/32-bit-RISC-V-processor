module pll(
	input clkin,
	input rst,
	output clkout
	);
	
	reg [24:0] clkreg; 
	
	always@(posedge clkin or negedge rst) begin
		if (~rst) 
			clkreg <= 25'b0;
		else
			clkreg <= clkreg + 25'b1;
	end
	
	assign clkout = clkreg[22];
endmodule 