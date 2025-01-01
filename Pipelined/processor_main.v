`timescale 1ns / 1ps

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
	
	
	reg [31:0] PFD_PC, PDE_PC, PEM_PC, PMW_PC, PFD_INST, PDE_IMM, PDE_RS1, PDE_RS2, PEM_RS2, PEM_PCADDIMM, PMW_PCADDIMM, PEM_ALUOUT, 
				  PEM_CALOUT, PMW_CALOUT, PMW_DOUT;				  
				  
	reg [2:0] PDE_F3;
	
	reg PDE_F7, PDE_CTRL_MEMWRITE, PEM_CTRL_MEMWRITE, PDE_CTRL_REGWRITE, PEM_CTRL_REGWRITE, PMW_CTRL_REGWRITE, PDE_CTRL_ALUSRC, 
		 PDE_CRTL_IMMTOREG, PEM_BRANCHFLAG, PFD_TAKENFLAG, PDE_TAKENFLAG, PEM_TAKENFLAG;
	
	reg [1:0] PDE_CTRL_ALUOP, PDE_CTRL_BRANCH, PDE_CTRL_REGWRITESEL, PEM_CTRL_BRANCH, PEM_CTRL_REGWRITESEL, PMW_CTRL_REGWRITESEL;
	
	reg [4:0] PDE_RDA, PEM_RDA, PMW_RDA;
	
	
	wire STALL, PFD_FLUSH, PDE_FLUSH, TAKENFLAG;
	
	
	
	
	// --------------------------------------------------------------------------------------------
	// FETCH STAGE
	// --------------------------------------------------------------------------------------------
	 
   wire [31:0] next_instruction, PCADD4;    // Address of the next instruction
   wire [31:0] inst;                // The instruction from instruction memory
	wire [31:0] data_rs1;
	wire [31:0] data_rs2, ALU_OUT, PCADDIMM;
	
	// BRANCH LOGIC
	// 	Taken = 1, not taken = 0
	// 	If taken and branchflag are different, take/correct-to realbranch. Otherwise let it be.
	
	wire [31:0] REALBRANCH;
	
	wire ALU_BRANCHFLAG;
	
	assign REALBRANCH = ({(PDE_CTRL_BRANCH[1] & ALU_BRANCHFLAG), PDE_CTRL_BRANCH[0]} == 2'b00) ? PDE_PC :
							  ({(PDE_CTRL_BRANCH[1] & ALU_BRANCHFLAG), PDE_CTRL_BRANCH[0]} == 2'b01) ? PDE_PC :
							  ({(PDE_CTRL_BRANCH[1] & ALU_BRANCHFLAG), PDE_CTRL_BRANCH[0]} == 2'b10) ? ALU_OUT : PCADDIMM;
							  
	add pcadd4(.A(PFD_PC), .B(32'd4), .CIN(1'b0), .OF(), .SUM(PCADD4));
	
	
	// BRANCH PREDICTION LOGIC
// Instantiate the 1-bit branch predictor
    wire predicted_taken;
    BranchPred bp (
        .clk(clk),
        .reset(reset_n),
        .branch_addr(PFD_PC),     // Use PC as branch address
        .branch_taken(ALU_BRANCHFLAG), // Actual branch outcome from ALU
        .predicted_taken(predicted_taken) // Predicted branch outcome
    );
    
    // Predicted PC for the next instruction
    assign NEXTPREDICTED = predicted_taken ? PCADDIMM : PCADD4;
    
    // Prediction flag for comparison with actual outcome
    assign TAKENFLAG = predicted_taken;
        
	assign next_instruction = (ALU_BRANCHFLAG ^ PDE_TAKENFLAG) ? REALBRANCH : NEXTPREDICTED;
	assign PFD_FLUSH = ALU_BRANCHFLAG ^ PDE_TAKENFLAG;
	assign PDE_FLUSH = ALU_BRANCHFLAG ^ PDE_TAKENFLAG;
	
   InstructMem imem(
		.instruct_address_in(PFD_PC),
		.inst_out(inst)
   );
	
	
	
	
	// --------------------------------------------------------------------------------------------
	// DECODE STAGE
	// --------------------------------------------------------------------------------------------
	
	//wire CTRL_MEMREAD; 
	wire CTRL_MEMWRITE, CTRL_ALUSRC, CTRL_REGWRITE, CRTL_IMMTOREG;
	wire [1:0] CTRL_ALUOP, CTRL_BRANCH, CTRL_REGWRITESEL;
	 
	Control_Unit cu(
		.instruction(PFD_INST),
		.clk(clk),
		//.MEMREAD(CTRL_MEMREAD), 
		.MEMWRITE(CTRL_MEMWRITE), 
		.ALUSRC(CTRL_ALUSRC), 
		.REGWRITE(CTRL_REGWRITE), 
		.IMMTOREG(CRTL_IMMTOREG),
		.STALLSIG(),
		.ALUOP(CTRL_ALUOP), 
		.BRANCH(CTRL_BRANCH), 
		.REGWRITESEL(CTRL_REGWRITESEL)
	);
	 
	wire [31:0] REGWRITE_DATA;
	 
	Register_File register(
		.Read_reg01(PFD_INST[19:15]),
		.Read_reg02(PFD_INST[24:20]),
		.Write_reg(PMW_RDA),
		.Write_data(REGWRITE_DATA),
		.Read_data01(data_rs1),
		.Read_data02(data_rs2),
		.write_signal(PMW_CTRL_REGWRITE),
		.clk(clk)
	);
	 
	wire [31:0] IMM_EXT; // Sign extended / instruction correctly formatted immediate
	
	immediate_gen immgen(
		.INSTRUCTION(PFD_INST),
		.IMMEDIATE_OUT(IMM_EXT)		
	); 
	
	
	
	
	// --------------------------------------------------------------------------------------------
	// EXECUTE STAGE
	// --------------------------------------------------------------------------------------------
	
	wire [3:0] ALU_OPCMD;
	wire [3:0] ALU_BRANCHCMD;
	
	alu_ctrl aluctrl(
		.ALUOp(PDE_CTRL_ALUOP),
		.FUNC3(PDE_F3),
		.FUNC7(PDE_F7),
		.ALUCTRL(ALU_OPCMD),
		.BRANCHCONDITION(ALU_BRANCHCMD)
	);
	
	wire [1:0] rs1sel, rs2sel;
	
	datafwd fwd(
		.rs1(PFD_INST[19:15]), 
		.rs2(PFD_INST[24:20]), 
		.exerd(PDE_RDA), 
		.memrd(PEM_RDA), 
		.ctrl_alusrc(CTRL_ALUSRC), 
		.clk(clk),
		.E_REGWRITE(PDE_CTRL_REGWRITE), 
		.M_REGWRITE(PEM_CTRL_REGWRITE),
		.rs1sel(rs1sel), 
		.rs2sel(rs2sel)
	);
	
	wire [31:0] B_RS2_IMM;
	
	wire [31:0] ALU_A, ALU_B;
	
	assign ALU_A = (rs1sel == 2'b01) ? PEM_CALOUT : (rs1sel == 2'b10) ? REGWRITE_DATA : PDE_RS1;
	assign ALU_B = (rs2sel == 2'b11) ? PDE_IMM : (rs2sel == 2'b10) ? REGWRITE_DATA : (rs2sel == 2'b01) ? PEM_CALOUT : PDE_RS2;
	
	alu alu(
		.A(ALU_A), 
		.B(ALU_B),
		.CTRL(ALU_OPCMD),
		.BRANCHCONDITION(ALU_BRANCHCMD),
		.OUT(ALU_OUT),
		.BRANCHFLAG(ALU_BRANCHFLAG)
	);
	
	
	wire [31:0] PCADDIMM_int;	
	add pcaddimm0(.A(PDE_PC), .B(PDE_IMM << 1), .CIN(1'b0), .OF(), .SUM(PCADDIMM_int));
	add pcaddimm1(.A(PCADDIMM_int), .B(~(32'd4)), .CIN(1'b1), .OF(), .SUM(PCADDIMM));
	
	wire [31:0] CAL_OUT;
	assign CAL_OUT = (PDE_CRTL_IMMTOREG == 1'b0) ? ALU_OUT : PDE_IMM;
	
	
	
	
	// --------------------------------------------------------------------------------------------
	// MEMORY STAGE
	// --------------------------------------------------------------------------------------------
	
	wire [31:0] DMEM_OUT;
	wire IOSEL;
	
	assign dmem_addr    = PEM_ALUOUT;
	assign dmem_dataout = PEM_RS2;
	assign DMEM_OUT     = dmem_datain;
	
	assign IOSEL = &{PEM_ALUOUT[31:2]};
	assign dmem_rw      = PEM_CTRL_MEMWRITE & ~IOSEL;
	assign io_rw        = PEM_CTRL_MEMWRITE & IOSEL;
	
	
	assign STALL = 1'b0;   ///// Change with the cache ------------------------------------------------------------------------------- (!)	
	
	
	
	// --------------------------------------------------------------------------------------------
	// WRITEBACK STAGE
	// --------------------------------------------------------------------------------------------
	
	assign REGWRITE_DATA = (PMW_CTRL_REGWRITESEL == 2'b00) ? PMW_CALOUT :
								  (PMW_CTRL_REGWRITESEL == 2'b01) ? PMW_DOUT : 
								  (PMW_CTRL_REGWRITESEL == 2'b10) ? PMW_PC : PMW_PCADDIMM;
								  
								  
								  
	// --------------------------------------------------------	
	// PIPELINE REGISTERS 
	// --------------------------------------------------------
	
	reg NEGEDGESTALL;
	
	always@(posedge clk or negedge reset_n) begin	
		// Boundary 1 : FX/DE
		if (~reset_n) begin
			PFD_PC   <= 32'b0;
			PFD_INST <= 32'b0;
			PFD_TAKENFLAG <= 1'b0;	
		end else	if (~STALL) begin
			if (PFD_FLUSH) begin
				PFD_PC   <= next_instruction;
				PFD_INST <= 32'b0;
				PFD_TAKENFLAG <= 1'b0;	
			end else begin
				PFD_PC   <= next_instruction;
				PFD_INST <= inst;
				PFD_TAKENFLAG <= TAKENFLAG;
			end
		end
		
		// Boundary 2 : DE/EX
		if (~reset_n) begin
			PDE_PC   <= 32'b0;
			PDE_F7   <= 1'b0;
			PDE_F3   <= 3'b0;
			PDE_IMM  <= 32'b0;
			PDE_RDA  <= 5'b0;
			PDE_RS1  <= 32'b0;
			PDE_RS2  <= 32'b0;
			PDE_TAKENFLAG		<= 1'b0;
			PDE_CRTL_IMMTOREG <= 1'b0;			// Used
			PDE_CTRL_ALUOP    <= 1'b0;
			PDE_CTRL_BRANCH   <= 2'b01;
			PDE_CTRL_REGWRITESEL <= 2'b0;
		end else if (~STALL) begin
			if (PDE_FLUSH) begin
				PDE_PC   <= 32'b0;
				PDE_F7   <= 1'b0;
				PDE_F3   <= 3'b0;
				PDE_IMM  <= 32'b0;
				PDE_RDA  <= 5'b0;
				PDE_RS1  <= 32'b0;
				PDE_RS2  <= 32'b0;				
				PDE_TAKENFLAG		<= 1'b0;
				
				PDE_CRTL_IMMTOREG <= 1'b0;			// Used
				PDE_CTRL_ALUOP    <= 1'b0;
				PDE_CTRL_BRANCH   <= 2'b01;
				PDE_CTRL_REGWRITESEL <= 2'b0;
			end else begin
				PDE_PC  <= PFD_PC;
				PDE_F7  <= PFD_INST[30];
				PDE_F3  <= PFD_INST[14:12];
				PDE_IMM <= IMM_EXT;
				PDE_RDA <= PFD_INST[11:7];
				PDE_RS1 <= data_rs1;
				PDE_RS2 <= data_rs2;
				PDE_TAKENFLAG <= PFD_TAKENFLAG;
					
				PDE_CRTL_IMMTOREG <= CRTL_IMMTOREG;			// Used
				PDE_CTRL_ALUOP    <= CTRL_ALUOP;				// Used
				PDE_CTRL_BRANCH   <= CTRL_BRANCH;	
				PDE_CTRL_REGWRITESEL <= CTRL_REGWRITESEL;
			end
		end
		
		// Boundary 3 : EX/MEM
		if (~reset_n) begin
			PEM_PC      <= 32'b0;
			PEM_PCADDIMM <= 32'b0;
			PEM_RDA		<= 5'b0;
			PEM_ALUOUT  <= 32'b0;
			PEM_BRANCHFLAG <= 1'b0;
			PEM_RS2		<= 32'b0;
			PEM_CALOUT	<= 32'b0;
			PEM_TAKENFLAG <= 1'b0;
			PEM_CTRL_BRANCH	<= 2'b01;
			PEM_CTRL_REGWRITESEL <= 2'b0;
		end else if (~STALL) begin
			PEM_PC      <= PDE_PC;
			PEM_PCADDIMM <= PCADDIMM;
			PEM_RDA		<= PDE_RDA;
			PEM_ALUOUT  <= ALU_OUT;
			PEM_BRANCHFLAG <= ALU_BRANCHFLAG;
			PEM_RS2		<= PDE_RS2;
			PEM_CALOUT	<= CAL_OUT;
			PEM_TAKENFLAG <= PDE_TAKENFLAG;
			
			PEM_CTRL_BRANCH	<= PDE_CTRL_BRANCH;
			PEM_CTRL_REGWRITESEL <= PDE_CTRL_REGWRITESEL;
		end
		
		// Boundary 4 : MEM/WB
		if (~reset_n) begin
			PMW_PC       <= 32'b0;
			PMW_PCADDIMM <= 32'b0;
			PMW_RDA      <= 5'b0;
			PMW_CALOUT   <= 32'b0;
			PMW_DOUT     <= 32'b0;
			PMW_CTRL_REGWRITESEL <= 2'b0;
		end else if (~STALL) begin
			PMW_PC       <= PEM_PC;
			PMW_PCADDIMM <= PEM_PCADDIMM;
			PMW_RDA      <= PEM_RDA;
			PMW_CALOUT   <= PEM_CALOUT;
			PMW_DOUT     <= DMEM_OUT;
				
			PMW_CTRL_REGWRITESEL <= PEM_CTRL_REGWRITESEL;
		end
		
		if (~reset_n)
			NEGEDGESTALL <= 1'b0;
		else
			NEGEDGESTALL <= STALL;
			
	end
	
	
	always@(negedge clk or negedge reset_n) begin
		// Boundary 2 : DE/EX
		if (~reset_n) begin
			PDE_CTRL_MEMWRITE <= 1'b0; 
			PDE_CTRL_REGWRITE <= 1'b0; 
		end else if (~NEGEDGESTALL) begin
			PDE_CTRL_MEMWRITE <= CTRL_MEMWRITE; 
			PDE_CTRL_REGWRITE <= CTRL_REGWRITE; 
		end
		
		// Boundary 3 : EX/MEM
		if (~reset_n) begin
			PEM_CTRL_MEMWRITE <= 1'b0;
			PEM_CTRL_REGWRITE <= 1'b0;
		end else if (~NEGEDGESTALL) begin
			PEM_CTRL_MEMWRITE <= PDE_CTRL_MEMWRITE;
			PEM_CTRL_REGWRITE <= PDE_CTRL_REGWRITE;
		end
		
		// Boundary 4 : MEM/WB
		if (~reset_n) begin
			PMW_CTRL_REGWRITE <= 1'b0;
		end else if (~NEGEDGESTALL) begin
			PMW_CTRL_REGWRITE <= PEM_CTRL_REGWRITE;
		end
	end
								  
endmodule 