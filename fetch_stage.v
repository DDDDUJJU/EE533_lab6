module fetch_stage #(
    parameter INST_ADDR_WIDTH = 9,
    parameter INST_DATA_WIDTH = 32
) (
    input wire clk,
    input wire reset,
    input wire pipeline_enable,
    input wire we,
    input wire [INST_ADDR_WIDTH-1:0] load_inst_addr,
    input wire [INST_DATA_WIDTH-1:0] load_inst_data,
    output wire [INST_DATA_WIDTH-1:0] fetch_out_inst
);
    // ------------------------------------------------------------------------------------
    // Program Counter
    // ------------------------------------------------------------------------------------
    reg [INST_ADDR_WIDTH-1:0] pc, pc_next;

	always @(posedge clk or posedge reset) begin
		if (reset)
			pc <= {INST_ADDR_WIDTH{1'b0}};
		else if (pipeline_enable)
			pc <= pc_next;
	end

    always @(*) begin
		pc_next = pc + 1;
	end

    // ------------------------------------------------------------------------------------
    // Instruction Memory
    // ------------------------------------------------------------------------------------
    wire [INST_ADDR_WIDTH-1:0] imem_addr;
    assign imem_addr = (we) ? load_inst_addr : pc;

    mem_inst #(
        .ADDR_WIDTH(INST_ADDR_WIDTH),
		.DATA_WIDTH(INST_DATA_WIDTH)
    ) I_MEM (
        .clk(clk),
		.we(we),
        .reset(reset),
		.addr(imem_addr),
		.wdata(load_inst_data),
		.rdata(fetch_out_inst)
    );

endmodule
