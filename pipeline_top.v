module pipelined_top #(
	// Descriptions:
	// Instructions: 32 bits
	// Data:         64 bits

    parameter TRACE_DEPTH        = 256,
    parameter TRACE_DEPTH_ADDR_W = 8, // Because 2^8 = 256

	parameter DATA_WIDTH = 64,
	parameter INST_DATA_WIDTH = 32, // 32-bit instructions
	parameter INST_ADDR_WIDTH = 9,  // 512-deep instruction memory (2^9 = 512)
	parameter MEM_ADDR_WIDTH  = 8,  // 256-deep data memory (2^8 = 256)
	parameter REG_ADDR_WIDTH  = 3   // 32-deep Register Files (2^3 = 8)
) (
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

	input wire clk,
	input wire reset
);

    //////////////////////////////////////////
    // Software registers
    //////////////////////////////////////////
    wire [31:0] sw_trace_read_ptr;   // from software

    //////////////////////////////////////////
    // Hardware registers
    //////////////////////////////////////////
    reg  [31:0] hw_trace_word_out_0; //  bits [31:0]
    reg  [31:0] hw_trace_word_out_1; //  bits [63:32]
    reg  [31:0] hw_trace_word_out_2; //  bits [66:64] in lower 3 bits (plus padding)

    localparam TRACE_ENTRY_WIDTH = REG_ADDR_WIDTH + DATA_WIDTH;

    reg [TRACE_ENTRY_WIDTH-1:0] trace_mem [0:TRACE_DEPTH-1];
    reg [TRACE_DEPTH_ADDR_W-1:0] trace_ptr;

    // Write to the trace_mem
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trace_ptr <= 0;
        end
        else begin
            // Only store when the pipeline indicates a successful write-back
            if (wb_w_reg_en) begin
                // Pack {address, data} into a single wide word
                trace_mem[trace_ptr] <= {wb_WReg1, wb_D_in};
                if (trace_ptr < TRACE_DEPTH - 1) begin
                    trace_ptr <= trace_ptr + 1'b1;
                end
            end
        end
    end

    // Read from the trace mem
    always @(posedge clk) begin
        if (reset) begin
            hw_trace_word_out_0 <= 0;
            hw_trace_word_out_1 <= 0;
            hw_trace_word_out_2 <= 0;
        end
        else begin
            read_word = trace_mem[ sw_trace_read_ptr[7:0] ];
            hw_trace_word_out_0 <= read_word[31:0];
            hw_trace_word_out_1 <= read_word[63:32];
            hw_trace_word_out_2 <= {29'b0, read_word[66:64]};
        end
    end

    generic_regs #(
        .UDP_REG_SRC_WIDTH (UDP_REG_SRC_WIDTH),
        .TAG               (`IDS_BLOCK_ADDR),
        .REG_ADDR_WIDTH    (`IDS_REG_ADDR_WIDTH),
        .NUM_COUNTERS      (0),
        .NUM_SOFTWARE_REGS (1),
        .NUM_HARDWARE_REGS (3)
    ) module_regs (
        // ---- Register interface I/O ----
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

        // We’re not using counters here
        .counter_updates  (),
        .counter_decrement(),

        // ---- Software Registers ----
        .software_regs ({
            sw_trace_read_ptr    // [31:0]
        }),

        // ---- Hardware Registers ----
        .hardware_regs ({
            hw_trace_word_out_2, // [31:0]
            hw_trace_word_out_1, // [31:0]
            hw_trace_word_out_0  // [31:0]
        }),

        .clk   (clk),
        .reset (reset)
    );

    // ------------------------------------------------------------------------------------
    // Software Register
    // ------------------------------------------------------------------------------------
    // reg pipeline_enable;

    // reg i_mem_we;
    // reg [INST_ADDR_WIDTH-1:0] i_mem_waddr;
    // reg [INST_DATA_WIDTH-1:0] i_mem_wdata;

    // reg d_mem_we;
    // reg [INST_ADDR_WIDTH-1:0] d_mem_waddr;
    // reg [INST_DATA_WIDTH-1:0] d_mem_wdata;

    // reg rf_we;
    // reg [INST_ADDR_WIDTH-1:0] rf_waddr;
    // reg [INST_DATA_WIDTH-1:0] rf_wdata;


    // Xilinx Testcode
    wire pipeline_enable;

    wire i_mem_we;
    reg [INST_ADDR_WIDTH-1:0] i_mem_waddr;
    reg [INST_DATA_WIDTH-1:0] i_mem_wdata;

    wire d_mem_we;
    reg [INST_ADDR_WIDTH-1:0] d_mem_waddr;
    reg [INST_DATA_WIDTH-1:0] d_mem_wdata;

    assign pipeline_enable = 1;
    assign i_mem_we = 0;
    assign d_mem_we = 0;

    // ------------------------------------------------------------------------------------
    // FETCH STAGE
    // ------------------------------------------------------------------------------------
    wire [INST_DATA_WIDTH-1:0] fetch_out_inst;

    fetch_stage #(
        .INST_ADDR_WIDTH(INST_ADDR_WIDTH),
        .INST_DATA_WIDTH(INST_DATA_WIDTH)
    ) fetch_stage_inst (
        .clk(clk),
        .reset(reset),
        .pipeline_enable(pipeline_enable),
        .we(i_mem_we), 
        .load_inst_addr(i_mem_waddr),
        .load_inst_data(i_mem_wdata),
        .fetch_out_inst(fetch_out_inst)
    );

    // ------------------------------------------------------------------------------------
    // DECODE STAGE
    // ------------------------------------------------------------------------------------
    wire id_w_mem_en;
    wire id_w_reg_en;
    wire [DATA_WIDTH-1:0] id_R1_out;
    wire [DATA_WIDTH-1:0] id_R2_out;
    wire [REG_ADDR_WIDTH-1:0] id_WReg1;

    decode_stage #(
        .INST_DATA_WIDTH(INST_DATA_WIDTH),
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) decode_stage_inst (
        .clk(clk),
        .reset(reset),
        .pipeline_enable(pipeline_enable),

        .inst(fetch_out_inst),

        // Logic from WB
        .we(wb_w_reg_en),
        .waddr(wb_WReg1),
        .wdata(wb_D_in),

        // Logic to EX Stage
        .id_w_mem_en(id_w_mem_en),
        .id_w_reg_en(id_w_reg_en),
        .id_R1_out(id_R1_out),
        .id_R2_out(id_R2_out),
        .id_WReg1(id_WReg1)
    );

    // ------------------------------------------------------------------------------------
    // EXECUTE STAGE
    // ------------------------------------------------------------------------------------
    wire ex_w_mem_en;
    wire ex_w_reg_en;
    wire [DATA_WIDTH-1:0] ex_R1_out;
    wire [DATA_WIDTH-1:0] ex_R2_out;
    wire [REG_ADDR_WIDTH-1:0] ex_WReg1;

    ex_stage #(
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) ex_stage_inst (
        .clk(clk),
        .reset(reset),
        .pipeline_enable(pipeline_enable),

        // Logic from Decode Stage
        .w_mem_en(id_w_mem_en),
        .w_reg_en(id_w_reg_en),
        .R1_in(id_R1_out),
        .R2_in(id_R2_out),
        .WReg1(id_WReg1),

        // Logic to MEM Stage
        .ex_w_mem_en(ex_w_mem_en),
        .ex_w_reg_en(ex_w_reg_en),
        .ex_R1_out(ex_R1_out),
        .ex_R2_out(ex_R2_out),
        .ex_WReg1(ex_WReg1)
    );

    // ------------------------------------------------------------------------------------
    // MEMORY STAGE
    // ------------------------------------------------------------------------------------
    wire mem_w_reg_en;
    wire [DATA_WIDTH-1:0] mem_D_out;
    wire [REG_ADDR_WIDTH-1:0] mem_WReg1;

    mem_stage #(
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
        .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) mem_stage_inst (
        .clk(clk),
        .reset(reset),
        .pipeline_enable(pipeline_enable),

        .w_mem_en(ex_w_mem_en),
        .w_reg_en(ex_w_reg_en),
        .R1_in(ex_R1_out),
        .R2_in(ex_R2_out),
        .WReg1(ex_WReg1),

        .mem_w_reg_en(mem_w_reg_en),
        .mem_D_out(mem_D_out),
        .mem_WReg1(mem_WReg1)
    );

    // ------------------------------------------------------------------------------------
    // WRITEBACK STAGE
    // ------------------------------------------------------------------------------------
    wire wb_w_reg_en;
    wire [DATA_WIDTH-1:0] wb_D_in;
    wire [REG_ADDR_WIDTH-1:0] wb_WReg1;

    wb_stage #(
        .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
        .MEM_ADDR_WIDTH(MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) wb_stage_inst (
        .clk(clk),
        .reset(reset),
        .pipeline_enable(pipeline_enable),

        .w_reg_en(mem_w_reg_en),
        .D_in(mem_D_out),
        .WReg1(mem_WReg1),

        .wb_w_reg_en(wb_w_reg_en),
        .wb_D_in(wb_D_in),
        .wb_WReg1(wb_WReg1)
    );

endmodule
