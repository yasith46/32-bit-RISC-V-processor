`timescale 1ns / 1ps

module datafwd(
		input [4:0] rs1, rs2, exerd, memrd, 
		input ctrl_alusrc, clk, E_REGWRITE, M_REGWRITE, E_MEMWRITE, M_MEMWRITE,
		output reg [1:0] rs1sel, rs2sel, ddatasel
	);
	
	// rs1sel: 00 - PDE_RS1    01 - PEM_ALUOUT    10 - REGWRITE_DATA	 
	// rs2sel: 00 - PDE_RS2    01 - PEM_ALUOUT    10 - REGWRITE_DATA   11 - IMMEDIATE
	
	
	always@(posedge clk) begin
		if ((rs1 == exerd) & (E_REGWRITE | E_MEMWRITE) & (rs1 != 5'b0))
			rs1sel <= 2'b01;
		else if ((rs1 == memrd) & (M_REGWRITE | M_MEMWRITE) & (rs1 != 5'b0))
			rs1sel <= 2'b10;
		else
			rs1sel <= 2'b00;
		
		if (ctrl_alusrc)
			rs2sel <= 2'b11;
		else if ((rs2 == exerd) & (E_REGWRITE | E_MEMWRITE) & (rs2 != 5'b0))
			rs2sel <= 2'b01;
		else if ((rs2 == memrd) & (M_REGWRITE | M_MEMWRITE) & (rs2 != 5'b0))
			rs2sel <= 2'b10;
		else
			rs2sel <= 2'b00;
			
		if ((rs2 == exerd) & (E_REGWRITE | E_MEMWRITE) & (rs2 != 5'b0))
			ddatasel <= 2'b01;
		else if ((rs2 == memrd) & (M_REGWRITE | M_MEMWRITE) & (rs2 != 5'b0))
			ddatasel <= 2'b10;
		else
			ddatasel <= 2'b00;
	end
endmodule 