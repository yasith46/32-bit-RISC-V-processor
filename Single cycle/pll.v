module pll(
	input clkin,
	input rst,
	output clkout
	);
	
	reg [1:0] clkreg; 
	
	always@(posedge clkin or negedge rst) begin
		if (~rst) 
			clkreg <= 2'b0;
		else
			clkreg <= clkreg + 2'd1;
	end
	
	assign clkout = clkreg[1];
endmodule 