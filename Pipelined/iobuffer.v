module iobuffer(
		input  [1:0]  ADDRESS,
		input  [31:0] DATAIN,
		output reg [31:0] DATAOUT,
		input  CLK, RST, SETIO,
		input  [31:0] PORT_A, PORT_B, 
		output [31:0] PORT_C, PORT_D
	);
	
	reg [31:0] PREGI [1:0];
	reg [31:0] PREGO [1:0];
	wire [31:0] PREG_wire [3:0];
	
	always@(posedge CLK or negedge RST) begin
		if (~RST) begin
			PREGI[0] <= PORT_A;
			PREGI[1] <= PORT_B;
			
			PREGO[0] <= 32'b0;
			PREGO[1] <= 32'b0;
			
		end else begin			
			// SIO: 0 = no change, 1 = set IO
			PREGI[0]  <= PORT_A;
			PREGI[1]  <= PORT_B;
			
			case(ADDRESS)
				2'b00: DATAOUT  <= PREGI[0];
				2'b01: DATAOUT  <= PREGI[1];
				2'b10: if (SETIO) PREGO[0] <= DATAIN;
				2'b11: if (SETIO) PREGO[1] <= DATAIN;
			endcase
		end
	end
	
	assign PORT_C = PREGO[0];
	assign PORT_D = PREGO[1];
endmodule 