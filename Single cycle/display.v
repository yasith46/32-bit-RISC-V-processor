module display(
		input  [3:0] DISPLAYWIRE,
		output reg [6:0]  SEG
	);
	
	always@(*) begin
		case (DISPLAYWIRE)
			4'b0000: SEG <= 7'b1000000; // 0
			4'b0001: SEG <= 7'b1111001; // 1
			4'b0010: SEG <= 7'b0100100; // 2
			4'b0011: SEG <= 7'b0110000; // 3
			4'b0100: SEG <= 7'b0011001; // 4
			4'b0101: SEG <= 7'b0010010; // 5
			4'b0110: SEG <= 7'b0000010; // 6
			4'b0111: SEG <= 7'b1111000; // 7
			4'b1000: SEG <= 7'b0000000; // 8
			4'b1001: SEG <= 7'b0011000; // 9
			4'b1010: SEG <= 7'b0001000; // A
			4'b1011: SEG <= 7'b0000011; // b
			4'b1100: SEG <= 7'b1000110; // C
			4'b1101: SEG <= 7'b0100001; // d
			4'b1110: SEG <= 7'b0000110; // E
			4'b1111: SEG <= 7'b0001110; // F
			default: SEG <= 7'b1111111;
		endcase
	end
endmodule 
