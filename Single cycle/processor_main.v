//////////////////////////////////////////////////////////////////////////////////
// Group: 		MetroniX 
// Designer: 		Bimsara Nawarathne, Yasith Silva
// 
// Create Date:    	11:29:15 17/10/2024 
// Design Name: 	Processor (Top module)
// Module Name:    	processor_main 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 		3
// Additional Comments: - Add inspectbuffer the fucntionality to inspect a specific 
//			  location 
//
//////////////////////////////////////////////////////////////////////////////////



module processor_main(
		input  clk, reset_n,                       // Clock signal
		output reg [31:0] inspectbuffer
	);
	 
   	wire [31:0] instruct_address, instruct_address_in, PCADD4;    // Address of the next instruction
   	wire [31:0] inst;                // The instruction from instruction memory
	wire [31:0] data_rs1;
	wire [31:0] data_rs2;

   	// Instantiate the ProgramCounter module
	ProgramCounter PC(
      		.instruct_address_in(instruct_address_in),
      		.clk(clk),
		.rst(reset_n),
		.instruct_address(instruct_address)
   	);
	
	add pcadd4(.A(instruct_address), .B(32'd4), .CIN(1'b0), .OF(), .SUM(PCADD4));

	// Instantiate the InstructMem module (assume InstructMem takes address and returns instruction)
   	InstructMem imem(
      		.Pro_count(instruct_address),  // Pass the instruction address from ProgramCounter
		.inst_out(inst)           // Fetch the instruction corresponding to the address
   	);
	 
	wire CTRL_MEMREAD, CTRL_MEMWRITE, CTRL_ALUSRC, CTRL_REGWRITE, CRTL_IMMTOREG;
	wire [1:0] CTRL_ALUOP, CTRL_BRANCH, CTRL_REGWRITESEL;
	 
	Control_Unit cu(
		.instruction(inst),
		.MEMREAD(CTRL_MEMREAD), 
		.MEMWRITE(CTRL_MEMWRITE), 
		.ALUSRC(CTRL_ALUSRC), 
		.REGWRITE(CTRL_REGWRITE), 
		.IMMTOREG(CRTL_IMMTOREG),
		.ALUOP(CTRL_ALUOP), 
		.BRANCH(CTRL_BRANCH), 
		.REGWRITESEL(CTRL_REGWRITESEL)
	);
	 
	wire [31:0] REGWRITE_DATA;
	 
	Register_File register(
		.Read_reg01(inst[19:15]),
		.Read_reg02(inst[24:20]),
		.Write_reg(inst[11:7]),
		.Write_data(REGWRITE_DATA),
		.Read_data01(data_rs1),
		.Read_data02(data_rs2),
		.write_signal(CTRL_REGWRITE),
		.clk(clk)
	);
	 
	wire [31:0] IMM_EXT; // Sign extended / instruction correctly formatted immediate
	
	immediate_gen immgen(
		.INSTRUCTION(inst),
		.IMMEDIATE_OUT(IMM_EXT)		
	); 
	
	wire [3:0] ALU_OPCMD;
	wire [2:0] ALU_BRANCHCMD;
	
	alu_ctrl aluctrl(
		.ALUOp(CTRL_ALUOP),
		.FUNC3(inst[14:12]),
		.FUNC7(inst[30]),
		.ALUCTRL(ALU_OPCMD),
		.BRANCHCONDITION(ALU_BRANCHCMD)
	);
	
	wire [31:0] B_RS2_IMM, ALU_OUT;
	wire ALU_BRANCHFLAG;
	assign B_RS2_IMM = (CTRL_ALUSRC == 1'b0) ? data_rs2 : IMM_EXT;
	
	alu alu(
		.A(data_rs1), 
		.B(B_RS2_IMM),
		.CTRL(ALU_OPCMD),
		.BRANCHCONDITION(ALU_BRANCHCMD),
		.OUT(ALU_OUT),
		.BRANCHFLAG(ALU_BRANCHFLAG)
	);
	
	
	wire [31:0] DMEM_OUT;
	
	DataMem dmem(
		.clk(clk), 
		.write_en(CTRL_MEMWRITE),
		.read_en(CTRL_MEMREAD),
		.address(ALU_OUT),   	 // Address bus width is 32 bits
		.data_in(data_rs2),	 	 // Data bus width is 32 bits
		.data_out(DMEM_OUT)	
	);
	
	wire [31:0] CAL_OUT;
	assign CAL_OUT = (CRTL_IMMTOREG == 1'b0) ? ALU_OUT : IMM_EXT;
	
	wire [31:0] PCADDIMM;	
	add pcaddimm(.A(instruct_address), .B(IMM_EXT << 1), .CIN(1'b0), .OF(), .SUM(PCADDIMM));
	
	assign REGWRITE_DATA = (CTRL_REGWRITESEL == 2'b00) ? CAL_OUT :
			       (CTRL_REGWRITESEL == 2'b01) ? DMEM_OUT : 
			       (CTRL_REGWRITESEL == 2'b10) ? PCADD4 : PCADDIMM;
								  
	assign instruct_address_in = ({(CTRL_BRANCH[1] & ALU_BRANCHFLAG), CTRL_BRANCH[0]} == 2'b00) ? PCADD4 :
				     ({(CTRL_BRANCH[1] & ALU_BRANCHFLAG), CTRL_BRANCH[0]} == 2'b01) ? PCADD4 :
				     ({(CTRL_BRANCH[1] & ALU_BRANCHFLAG), CTRL_BRANCH[0]} == 2'b10) ? ALU_OUT : PCADDIMM;
										  
	always@(clk) begin
		inspectbuffer <= DMEM_OUT;
	end

endmodule 
