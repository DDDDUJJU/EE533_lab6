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
module pipeline_datapath #(
	parameter INST_ADDR_WIDTH = 9, // 512-deep instruction memory (2^9 = 512)
	parameter INST_DATA_WIDTH = 32, // 32-bit instructions

	parameter MEM_ADDR_WIDTH = 8, // 256-deep data memory (2^8 = 256)
	
	parameter REG_ADDR_WIDTH = 3,
	parameter DATA_WIDTH = 64,

	parameter UDP_REG_SRC_WIDTH = 2,
	parameter CTRL_WIDTH = DATA_WIDTH / 8
)(
	input  [DATA_WIDTH-1:0]  in_data,
	input  [CTRL_WIDTH-1:0]  in_ctrl,
	input                    in_wr,
	output                   in_rdy,

	output reg [DATA_WIDTH-1:0]  out_data,
	output reg [CTRL_WIDTH-1:0]  out_ctrl,
	output reg                 	 out_wr,
	input                    	out_rdy,
	// --- Register interface
	input                               reg_req_in,
	input                               reg_ack_in,
	input                               reg_rd_wr_L_in,
	input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
	input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
	input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

	output                              reg_req_out,
	output                              reg_ack_out,
	output                              reg_rd_wr_L_out,
	output [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_out,
	output [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_out,
	output [UDP_REG_SRC_WIDTH-1:0]      reg_src_out,

	input clk,
	input reset
);

	// Bypassing all signals
	assign in_rdy = 1;
	always @(*) begin
		out_ctrl = in_ctrl;
		out_data = in_data;
		out_wr = in_wr;
	end

	//----------------------------------------------------------------------
	// IF Stage: Program Counter & Instruction Memory
	//----------------------------------------------------------------------
	
	// Program Counter
	reg [INST_ADDR_WIDTH-1:0] pc_current, pc_next;

	wire [INST_DATA_WIDTH-1:0] if_inst;

	// Software registers
	wire [31:0] interface_pipeline_enable;
	wire [31:0] interface_ins_addrin;
	wire [INST_DATA_WIDTH - 1 : 0] interface_ins_wdata;

	reg int_pipe_en;

	reg int_ins_we;
	reg [INST_ADDR_WIDTH - 1:0] int_ins_waddr;
	reg [INST_DATA_WIDTH - 1:0] int_ins_wdata;
	
	// Latch interface input
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			int_ins_we <= 0;
			int_ins_waddr <= 0;
			int_ins_wdata <= 0;
			int_pipe_en <= 0;
		end else begin
			int_ins_we <= interface_ins_addrin[31];
			int_ins_waddr <= interface_ins_addrin[INST_ADDR_WIDTH - 1:0];
			int_ins_wdata <= interface_ins_wdata;
			int_pipe_en <= interface_pipeline_enable[0];
		end
	end

	mem_inst_32 #(
		.ADDR_WIDTH (INST_ADDR_WIDTH),
		.DATA_WIDTH (INST_DATA_WIDTH)
	) I_MEM (
		.clk (clk),
		.we (int_ins_we),
		.waddr (int_ins_waddr),
		.wdata (int_ins_wdata),
		.r1addr (pc_current), // word-aligned address
		.r1data (if_inst)
	);

	// Synchronous update of PC
	always @(posedge clk or posedge reset) begin
		if (reset)
			pc_current <= {INST_ADDR_WIDTH{1'b0}};
		else if (int_pipe_en)
			pc_current <= pc_next;
	end

	always @(*) begin
		pc_next = pc_current + 1;
	end

	//----------------------------------------------------------------------
	// IF/ID Stage Register
	//----------------------------------------------------------------------

	wire [INST_DATA_WIDTH-1:0] id_inst;
	
	if_id_stage_reg #(
		.DATA_WIDTH (INST_DATA_WIDTH)
	) IF_ID_REG (
		.clk (clk),
		.reset (reset),
		.enable (int_pipe_en),
		.if_inst (if_inst),
		.id_inst (id_inst)
	);

	//----------------------------------------------------------------------
	// ID Stage: Decode, Register File Read, etc.
	//----------------------------------------------------------------------

	// Decoding instruction
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
	
	//----------------------------------------------------------------------
	// ID/EX Stage Register
	//----------------------------------------------------------------------

	wire ex_w_reg_en;
	wire ex_w_mem_en;
	wire [DATA_WIDTH - 1:0] ex_r1_out;
	wire [DATA_WIDTH - 1:0] ex_r2_out;
	wire [REG_ADDR_WIDTH - 1:0] ex_w_reg_1;

	id_ex_stage_reg #(
		.DATA_WIDTH(DATA_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
	) ID_EX_REG (
		.clk(clk),
		.reset(reset),
		.enable (int_pipe_en),

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
	
	//----------------------------------------------------------------------
	// EX/MEM Stage Register
	//----------------------------------------------------------------------

	wire mem_w_reg_en;
	wire mem_w_mem_en;
	wire [DATA_WIDTH - 1:0] mem_r1_out;
	wire [DATA_WIDTH - 1:0] mem_r2_out;
	wire [REG_ADDR_WIDTH - 1:0] mem_w_reg_1;

	ex_mem_stage_reg #(
		.DATA_WIDTH(DATA_WIDTH),
		.REG_ADDR_WIDTH(REG_ADDR_WIDTH)
	) EX_MEM_REG (
		.clk(clk),
		.reset(reset),
		.enable (int_pipe_en),

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
	
	// Software registers
	// interface reg for Data Memory read
	wire [31:0] interface_data_wdata_0;
	wire [31:0] interface_data_wdata_1;
	wire [31:0] interface_data_addrin;
	// Hardware registers
	reg [31:0] interface_data_rdata_0;
	reg [31:0] interface_data_rdata_1;

	reg int_we;
	reg int_re;
	reg [MEM_ADDR_WIDTH - 1:0] int_addr;
	reg int_wdata;

	// Latch interface input
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			int_we <= 0;
			int_re <= 0;
			int_addr <= 0;
			int_wdata <= 0;
		end else begin
			int_we <= interface_data_addrin[31];
			int_re <= interface_data_addrin[30];
			int_addr <= interface_data_addrin[MEM_ADDR_WIDTH - 1:0];
			int_wdata <= {interface_data_wdata_1,interface_data_wdata_0};
		end
	end

	wire mem_we;
	wire [DATA_WIDTH - 1:0] mem_dout;
	wire [MEM_ADDR_WIDTH - 1:0] mem_raddr;
	wire [MEM_ADDR_WIDTH - 1:0] mem_waddr;
	wire [DATA_WIDTH-1:0] mem_wdata;
	
	// Muxing data mem inputs
	assign mem_we = int_we || mem_w_mem_en;
	assign mem_raddr = int_re ? int_addr : mem_r1_out;
	assign mem_waddr = int_we ? int_addr : mem_r1_out;
	assign mem_wdata = int_we ? {interface_data_wdata_1,interface_data_wdata_0} : mem_r2_out;

	mem_data_64 #(
		.DATA_WIDTH(DATA_WIDTH),
		.ADDR_WIDTH(MEM_ADDR_WIDTH)
	) MEM_DATA (
		.clka(clk),
		.clkb(clk),
		.raddr(mem_raddr),
		.waddr(mem_waddr),
		.wdata(mem_wdata),
		.dout(mem_dout),
		.we(mem_we)
	);

	always @(posedge clk or posedge reset) begin
	 if (reset) begin
		interface_data_rdata_0 <= 0;
		interface_data_rdata_1 <= 0;
	 end
	 else begin
	   interface_data_rdata_0 <= mem_dout[31:0];
	   interface_data_rdata_1 <= mem_dout[63:32];
	 end
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
		.enable (int_pipe_en),

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
	

	//----------------------------------------------------------------------
	// NetFPGA register interface 
	//----------------------------------------------------------------------
	
	 generic_regs #(
      .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
      .TAG               (`PIPELINE_BLOCK_ADDR),      // custom block tag
      .REG_ADDR_WIDTH    (`PIPELINE_REG_ADDR_WIDTH),
      .NUM_COUNTERS      (0),
      .NUM_SOFTWARE_REGS (6),
      .NUM_HARDWARE_REGS (2)
   ) module_regs (
      .reg_req_in       (reg_req_in),
      .reg_ack_in       (reg_ack_in),
      .reg_rd_wr_L_in   (reg_rd_wr_L_in),
      .reg_addr_in      (reg_addr_in),
      .reg_data_in      (reg_data_in),
      .reg_src_in       (reg_src_in),

      .reg_req_out      (reg_req_out),
      .reg_ack_out      (reg_ack_out),
      .reg_rd_wr_L_out  (reg_rd_wr_L_out),
      .reg_addr_out     (reg_addr_out),
      .reg_data_out     (reg_data_out),
      .reg_src_out      (reg_src_out),

      // counters
      .counter_updates  (),
      .counter_decrement(),

      // Software registers
      .software_regs ({
		 interface_data_addrin,
		 interface_data_wdata_1,
		 interface_data_wdata_0,
		 interface_ins_wdata,
		 interface_ins_addrin,
		 interface_pipeline_enable
      }),

      // Hardware registers
      .hardware_regs ({
         interface_data_rdata_1,
		 interface_data_rdata_0
      }),

      .clk              (clk),
      .reset            (reset)
   );
	
endmodule