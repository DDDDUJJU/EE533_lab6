`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:12:52 02/19/2025 
// Design Name: 
// Module Name:    pipeline_datapath 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pipelined_cpu #(
	// Adjust widths as needed for your ISA
	parameter INST_ADDR_WIDTH = 9, // 512-deep instruction memory (2^9 = 512)
	parameter INST_DATA_WIDTH = 32, // 32-bit instructions

	parameter MEM_ADDR_WIDTH = 8, // 256-deep data memory (2^8 = 256)
	
	parameter REG_ADDR_WIDTH = 3,
	parameter DATA_WIDTH = 64
)(
	input wire global_clk,
	input wire reset,
	output reg [DATA_WIDTH:0] pipe_dout // need to be deleted, just for simulation
);

	//----------------------------------------------------------------------
	// IF Stage: Program Counter & Instruction Memory
	//----------------------------------------------------------------------
	
	
	
	// interface reg for enable
	/*need to be changed into software reg*/ reg interface_pipline_enable;
	
	initial begin
		interface_pipline_enable = 0;
	end
	
	// clock gating for enable
	wire clk = interface_pipline_enable & global_clk;
	

	// Program Counter
	reg [INST_ADDR_WIDTH-1:0] pc_current, pc_next;

	// Synchronous update of PC
	always @(posedge clk or posedge reset) begin
		if (reset)
			pc_current <= {INST_ADDR_WIDTH{1'b0}};
		else
			pc_current <= pc_next;
	end

	// Simple next-PC logic (PC + 1 if you?re fetching *words*).
	// If instructions are word-addressed, each increment is +1.
	// If byte-addressed, you might do +4 for 32-bit instructions.
	always @* begin
		pc_next = pc_current + 1;
	end

	// Instruction output from the instruction memory
	wire [INST_DATA_WIDTH-1:0] if_inst;

	// Single-port BRAM-based instruction memory
	
	
	
	// interface reg for Instruction Memory manipulation
	/*need to be changed into software reg*/ reg [INST_ADDR_WIDTH - 1 : 0] interface_ins_waddr;
	/*need to be changed into software reg*/ reg [INST_DATA_WIDTH - 1 : 0] interface_ins_wdata;
	
	
	// (32 bits wide, 512 entries, single BRAM)
	mem_inst_32 #(
		.ADDR_WIDTH (INST_ADDR_WIDTH),
		.DATA_WIDTH (INST_DATA_WIDTH)
	) I_MEM (
		.clk (global_clk),
		.we (interface_pipline_enable),
		.waddr (interface_ins_waddr),
		.wdata (interface_ins_wdata),
		.r1addr (pc_current), // word-aligned address
		.r1data (if_inst)
	);

	//----------------------------------------------------------------------
	// IF/ID Stage Register
	//----------------------------------------------------------------------

	wire [INST_DATA_WIDTH-1:0] id_inst;
	
	if_id_stage_reg #(
		.DATA_WIDTH (INST_DATA_WIDTH)
	) IF_ID_REG (
		.clk (clk),
		.reset (reset),
		.if_inst (if_inst),
		.id_inst (id_inst)
	);

	//----------------------------------------------------------------------
	// ID Stage: Decode, Register File Read, etc.
	//----------------------------------------------------------------------

	wire id_w_mem_en = id_inst[31];
	wire id_w_reg_en = id_inst[30];
	wire [REG_ADDR_WIDTH - 1:0] id_reg_1 = id_inst[29:27];
	wire [REG_ADDR_WIDTH - 1:0] id_reg_2 = id_inst[26:24];
	wire [REG_ADDR_WIDTH - 1:0] id_w_reg_1 = id_inst[23:21];

	// Outputs from register file
	wire [DATA_WIDTH-1:0] id_r1_out;
	wire [DATA_WIDTH-1:0] id_r2_out;
	
	wire wb_w_reg_en;
	wire [REG_ADDR_WIDTH - 1:0] wb_w_reg_1;
	wire [DATA_WIDTH - 1:0] wb_dout;
	
	
	reg_file_64 #(
		.ADDR_WIDTH (REG_ADDR_WIDTH),
		.DATA_WIDTH (DATA_WIDTH)
	) REG_FILE (
		.clk (clk),
		.we (wb_w_reg_en),
		.waddr (wb_w_reg_1),
		.wdata (wb_dout),
		.r0addr (id_reg_1),
		.r0data (id_r1_out),
		.r1addr (id_reg_2),
		.r1data (id_r2_out)
	);
	wire ex_w_reg_en;
	wire ex_w_mem_en;
	wire [DATA_WIDTH - 1:0] ex_r1_out;
	wire [DATA_WIDTH - 1:0] ex_r2_out;
	wire [REG_ADDR_WIDTH - 1:0] ex_w_reg_1;
	
	//----------------------------------------------------------------------
	// ID/EX Stage Register
	//----------------------------------------------------------------------

	id_ex_stage_reg #(
		.DATA_WIDTH(DATA_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
	) ID_EX_REG (
		.clk(clk),
		.reset(reset),
		.w_reg_en(id_w_reg_en),
		.w_mem_en(id_w_mem_en),
		.r1_out(id_r1_out),
		.r2_out(id_r2_out),
		.w_reg_1(id_w_reg_1),
		
		.w_reg_en_o(ex_w_reg_en),
		.w_mem_en_o(ex_w_mem_en),
		.r1_out_o(ex_r1_out),
		.r2_out_o(ex_r2_out),
		.w_reg_1_o(ex_w_reg_1)
	);
	
	
	//----------------------------------------------------------------------
	// EX Stage: bypassed - ALU to be implemented
	//----------------------------------------------------------------------
	
	wire mem_w_reg_en;
	wire mem_w_mem_en;
	wire [DATA_WIDTH - 1:0] mem_r1_out;
	wire [DATA_WIDTH - 1:0] mem_r2_out;
	wire [REG_ADDR_WIDTH - 1:0] mem_w_reg_1;
	wire [DATA_WIDTH - 1:0] mem_dout;
	
	//----------------------------------------------------------------------
	// EX/MEM Stage Register
	//----------------------------------------------------------------------

	ex_mem_stage_reg #(
		.DATA_WIDTH(DATA_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
	) EX_MEM_REG (
		.clk(clk),
		.reset(reset),
		.w_reg_en(ex_w_reg_en),
		.w_mem_en(ex_w_mem_en),
		.r1_out(ex_r1_out),
		.r2_out(ex_r2_out),
		.w_reg_1(ex_w_reg_1),
		
		.w_reg_en_o(mem_w_reg_en),
		.w_mem_en_o(mem_w_mem_en),
		.r1_out_o(mem_r1_out),
		.r2_out_o(mem_r2_out),
		.w_reg_1_o(mem_w_reg_1)
	);
	
	//----------------------------------------------------------------------
	// MEM Stage: Data Memory
	//----------------------------------------------------------------------
	
	
	// interface reg for Data Memory manipulation
	/*need to be changed into software reg*/ reg [MEM_ADDR_WIDTH - 1 : 0] interface_data_waddr;
	/*need to be changed into software reg*/ reg [DATA_WIDTH - 1 : 0] interface_data_wdata;
	/*need to be changed into software reg*/ reg interface_data_we;
	

	mem_data_64 #(
		.ADDR_WIDTH(MEM_ADDR_WIDTH),
		.DATA_WIDTH(DATA_WIDTH)
	) MEM_DATA (
		.clk(global_clk),
		.we(mem_w_mem_en),
		.wdata(mem_r2_out),
		.addr(mem_r1_out[MEM_ADDR_WIDTH - 1:0]),
		
		.pipline_enable(interface_pipline_enable),
		.interface_we(interface_data_we),
		.interface_wdata(interface_data_wdata),
		.interface_waddr(interface_data_waddr),
		
		.dout(mem_dout)
	);
	
	
	// interface reg for Data Memory read
	/*need to be changed into software reg*/ reg [DATA_WIDTH - 1 : 0] interface_data_rdata;
	
	always @(posedge global_clk) begin
		 interface_data_rdata <= mem_dout;
	end	
	
	//----------------------------------------------------------------------
	// MEM/WB Stage Register
	//----------------------------------------------------------------------

	mem_wb_stage_reg #(
		.DATA_WIDTH(DATA_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
	) MEM_WB_REG (
		.clk(clk),
		.reset(reset),
		.w_reg_en(mem_w_reg_en),
		.dout(mem_dout),
		.w_reg_1(mem_w_reg_1),
		
		.w_reg_en_o(wb_w_reg_en),
		.dout_o(wb_dout),
		.w_reg_1_o(wb_w_reg_1)
	);
	
	//----------------------------------------------------------------------
	// WB Stage: Return to ID stage
	//----------------------------------------------------------------------
	
	// need to be deleted, just for simulation
	always @(posedge clk) begin
		pipe_dout <= wb_dout;
	end
	
	
endmodule