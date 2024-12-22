module top(
		input  fpgaclk, reset_n,                       // Clock signal
		output [6:0] seg0, seg1, seg2, seg3, seg4, seg5, seg6, seg7,
		input  [31:0] switch,
		output clkled
	);
	
	wire clk;
	
	pll pll0(
			.clkin(fpgaclk),
			.rst(reset_n),
			.clkout(clk)
	);
	
	wire dmem_rw, io_rw;
	wire [31:0] dmem_addr, dmem_dataout, dmem_datain, ibuf_datain, dmbf_datain;
	
	processor_main CPU(
		.clk(clk), 
		.reset_n(reset_n),  
		.dmem_addr(dmem_addr),
		.dmem_datain(dmbf_datain),
		.dmem_dataout(dmem_dataout),
		.dmem_rw(dmem_rw),
		.io_rw(io_rw)
	);
	
	wire [31:0] DMEM_OUT;
	
	DataMem dmem(
		.clk(clk), 
		.write_en(dmem_rw),
		.address(dmem_addr),   	 // Address bus width is 32 bits
		.data_in(dmem_dataout),	 	 // Data bus width is 32 bits
		.data_out(dmem_datain)	
	);
	
	wire [31:0] PORT0;
	
	iobuffer io(
		.ADDRESS(dmem_addr[1:0]),
		.DATAIN(dmem_dataout),
		.DATAOUT(ibuf_datain),
		.CLK(clk), 
		.RST(reset_n),
		.SETIO(io_rw), 
		.PORT_A(switch),
		.PORT_B(),
		.PORT_C(PORT0),
		.PORT_D()
	);
	
	assign dmbf_datain = (~io_rw) ? dmem_datain : ibuf_datain;
	
	display disp0(.DISPLAYWIRE(PORT0[3:0]),   .SEG(seg0));
	display disp1(.DISPLAYWIRE(PORT0[7:4]),   .SEG(seg1));
	display disp2(.DISPLAYWIRE(PORT0[11:8]),  .SEG(seg2));
	display disp3(.DISPLAYWIRE(PORT0[15:12]), .SEG(seg3));
	display disp4(.DISPLAYWIRE(PORT0[19:16]), .SEG(seg4));
	display disp5(.DISPLAYWIRE(PORT0[23:20]), .SEG(seg5));
	display disp6(.DISPLAYWIRE(PORT0[27:24]), .SEG(seg6));
	display disp7(.DISPLAYWIRE(PORT0[31:28]), .SEG(seg7));
	
	assign clkled = clk;
	
endmodule 