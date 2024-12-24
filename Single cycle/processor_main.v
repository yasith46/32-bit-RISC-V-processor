//////////////////////////////////////////////////////////////////////////////////
// Group: 				MetroniX 
// Designer: 			Bimsara Nawarathne, Yasith Silva
// 
// Create Date:    	11:29:15 17/10/2024 
// Design Name: 	 	Processor (Top module)
// Module Name:    	processor_main 
// Project Name:   	32 bit Single Cycle RISC-V processor
// Target Devices: 	Altera Cyclone IV EP4CE115F29 (DE2-115)
//
// Dependencies: 
//
// Revision: 			3
// Additional Comments: - Add inspectbuffer the fucntionality to inspect a specific 
//								  location 
//
//////////////////////////////////////////////////////////////////////////////////



module processor_main(
		input  clk, reset_n,                       // Clock signal
		input  [31:0] dmem_datain, 
		output [31:0] dmem_addr, dmem_dataout,
		output dmem_rw, io_rw
   );
	 
   wire [31:0] current_instruction, next_instruction, PCADD4;    // Address of the next instruction
   wire [31:0] inst;                // The instruction from instruction memory
	wire [31:0] data_rs1;
	wire [31:0] data_rs2;
	
	reg [31:0] PC;
	reg STALLREG;
	wire CTRL_STALLSIG;
	
	// PC
	always@(posedge clk or negedge reset_n) begin
		if (~reset_n) begin
			PC <= 32'b0;
			STALLREG <= 1'b0;
		end else begin
			if (~STALLREG) begin
				PC <= next_instruction;
				STALLREG <= CTRL_STALLSIG;
			end else begin
				STALLREG <= 1'b0;
			end
		end
	end
	
	assign current_instruction = PC;
	
	add pcadd4(.A(current_instruction), .B(32'd4), .CIN(1'b0), .OF(), .SUM(PCADD4));
	
	// Instantiate the InstructMem module (assume InstructMem takes address and returns instruction)
   InstructMem imem(
		.instruct_address_in(current_instruction),
		.inst_out(inst)           // Fetch the instruction corresponding to the address
   );
	 
	//wire CTRL_MEMREAD; 
	wire CTRL_MEMWRITE, CTRL_ALUSRC, CTRL_REGWRITE, CRTL_IMMTOREG;
	wire [1:0] CTRL_ALUOP, CTRL_BRANCH, CTRL_REGWRITESEL;
	 
	Control_Unit cu(
		.instruction(inst),
		.clk(clk),
		//.MEMREAD(CTRL_MEMREAD), 
		.MEMWRITE(CTRL_MEMWRITE), 
		.ALUSRC(CTRL_ALUSRC), 
		.REGWRITE(CTRL_REGWRITE), 
		.IMMTOREG(CRTL_IMMTOREG),
		.STALLSIG(CTRL_STALLSIG),
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
	wire IOSEL;
	
	assign dmem_addr    = ALU_OUT;
	assign dmem_dataout = data_rs2;
	assign DMEM_OUT     = dmem_datain;
	
	assign IOSEL = &{ALU_OUT[31:2]};
	assign dmem_rw      = CTRL_MEMWRITE & ~IOSEL;
	assign io_rw        = CTRL_MEMWRITE & IOSEL;
	
	
	wire [31:0] CAL_OUT;
	assign CAL_OUT = (CRTL_IMMTOREG == 1'b0) ? ALU_OUT : IMM_EXT;
	
	wire [31:0] PCADDIMM;	
	add pcaddimm(.A(current_instruction), .B(IMM_EXT << 1), .CIN(1'b0), .OF(), .SUM(PCADDIMM));
	
	assign REGWRITE_DATA = (CTRL_REGWRITESEL == 2'b00) ? CAL_OUT :
								  (CTRL_REGWRITESEL == 2'b01) ? DMEM_OUT : 
								  (CTRL_REGWRITESEL == 2'b10) ? PCADD4 : PCADDIMM;
								  
	assign next_instruction = ({(CTRL_BRANCH[1] & ALU_BRANCHFLAG), CTRL_BRANCH[0]} == 2'b00) ? PCADD4 :
									  ({(CTRL_BRANCH[1] & ALU_BRANCHFLAG), CTRL_BRANCH[0]} == 2'b01) ? PCADD4 :
									  ({(CTRL_BRANCH[1] & ALU_BRANCHFLAG), CTRL_BRANCH[0]} == 2'b10) ? ALU_OUT : PCADDIMM;
endmodule 