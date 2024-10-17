module processor_main(
		input CLK
	);
	
	// Program counter
	wire [31:0] INS_ADDR, INS;
	wire [31:0] INS_ADDR_IN;
	
	ProgramCounter pc(
		.instruct_address(INS_ADDR),
		.clk(CLK),
		.instruct_address_in(INS_ADDR_IN)
   );
	
	

	
	// ---- Instruction memory ----
	
	InstructMem imem(
		.Pro_count(INS_ADDR),
		.inst_out(INS)
   );


	
	
	// ---- Control signals ----
	
	wire CTRL_BRANCH, CTRL_MEMREAD, CTRL_MEMTOREG, CTRL_MEMWRITE, CTRL_ALUSRC, CTRL_REGWRITE;
	wire [1:0] CTRL_ALUOP;
	
	///////////////////////////
	// Contol unit goes here //
	///////////////////////////
	
	
	
	// ---- Registry file ----
	
	wire [31:0] RS1_DATA, RS2_DATA, RD_DATA;
	
	Register_File regfile(
		.Read_reg01(INS[19:15]),	   // rs1 addr
		.Read_reg02(INS[24:20]),   	// rs2 addr
		.Write_reg(INS[11:7]),   		// rd  addr
		.Write_data(RD_DATA),			// data written to register
		.Read_data01(RS1_DATA),			// rs1 data
		.Read_data02(RS2_DATA),			// rs2 data
		.write_signal(CTRL_REGWRITE),	// control regwrite
		.clk(CLK)			  				// clk
	);
	
	
	
	
	// ---- Sign extension ----
	
	wire [31:0] IMM_EXT; // Sign extended / instruction correctly formatted immediate
	
	immediate_gen immgen(
		.INSTRUCTION(INS),
		.IMMEDIATE_OUT(IMM_EXT)		
	);
	
	
	

	// ---- ALU control ----
	
	wire [3:0] ALU_OPCMD;
	wire [2:0] ALU_BRANCHCMD;
	
	alu_ctrl aluctrl(
		.ALUOp(CTRL_ALUOP),
		.FUNC3(INS[14:12]),
		.FUNC7(INS[30]),
		.ALUCTRL(ALU_OPCMD),
		.BRANCHCONDITION(ALU_BRANCHCMD)
	);
	
	
	
	
	// ---- ALU ----
	
	wire [31:0] B_RS2_IMM, ALU_OUT;
	wire ALU_BRANCHFLAG;
	assign B_RS2_IMM = (CTRL_ALUSRC == 1'b0) ? RS2_DATA : IMM_EXT;
	
	alu alu(
		.A(RS1_DATA), 
		.B(B_RS2_IMM),
		.CTRL(ALU_OPCMD),
		.BRANCHCONDITION(ALU_BRANCHCMD),
		.OUT(ALU_OUT),
		.BRANCHFLAG(ALU_BRANCHFLAG)
	);
	
	
	
	
	// ---- Data memory ----
	
	wire [31:0] DMEM_OUT;
	
	DataMem dmem(
		.clk(CLK), 
		.write_en(CTRL_MEMWRITE),
		.read_en(CTRL_MEMREAD),
		.address(ALU_OUT),   	 // Address bus width is 32 bits
		.data_in(RS2_DATA),	 	 // Data bus width is 32 bits
		.data_out(DMEM_OUT)	
	);
	
	assign RD_DATA = (CTRL_MEMTOREG == 1'b1) ? DMEM_OUT : ALU_OUT;
	
	
	
	
	// ---- Address calculation ----
	
	wire [31:0] PC_ORDINARY, PC_BRANCH;
	
	cla32 add_0(.A(INS_ADDR),  .B(32'd4),  .CIN(1'b0),  .OF(),  .SUM(PC_ORDINARY),  .BAND(),  .BXOR());
	
	wire [31:0] IMM_EXT_SHIFTED;
	assign IMM_EXT_SHIFTED = IMM_EXT << 1'b1;
	
	cla32 add_1(.A(INS_ADDR),  .B(IMM_EXT_SHIFTED),  .CIN(1'b0),  .OF(),  .SUM(PC_BRANCH),  .BAND(),  .BXOR());
	
	assign INS_ADDR_IN = ((CTRL_BRANCH & ALU_BRANCHFLAG) == 1'b0) ? PC_ORDINARY : PC_BRANCH;
	
endmodule 