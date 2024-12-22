module pll(
	input clkin,
	input rst,
	output clkout
	);
	
	reg clkreg; 
	
	always@(posedge clkin or negedge rst) begin
		if (~rst) 
			clkreg <= 1'b0;
		else
			clkreg <= clkreg + 1'b1;
	end
	
	assign clkout = clkreg;
endmodule 