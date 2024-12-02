module pll(
	input clkin,
	input rst,
	output clkout
	);
	
	reg [3:0] clkreg; 
	
	always@(posedge clkin or negedge rst) begin
		if (~rst) 
			clkreg <= 3'b0;
		else
			clkreg <= clkreg + 3'd1;
	end
	
	assign clkout = clkreg[2];
endmodule 