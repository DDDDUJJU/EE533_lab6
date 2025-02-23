module decode_stage #(
    parameter INST_DATA_WIDTH = 32,
    parameter REG_ADDR_WIDTH = 3,
    parameter DATA_WIDTH = 64
) (
    input wire clk,
    input wire reset,
    input wire pipeline_enable,

    // Logic from IF
    input wire [INST_DATA_WIDTH-1:0] inst,

    // Logic from WB
    input wire we,
    input wire [REG_ADDR_WIDTH-1:0] waddr,
    input wire [DATA_WIDTH-1:0] wdata,

    // Logic to EX Stage
    output wire id_w_mem_en,
    output wire id_w_reg_en,
    output wire [DATA_WIDTH-1:0] id_R1_out,
    output wire [DATA_WIDTH-1:0] id_R2_out,
    output wire [REG_ADDR_WIDTH-1:0] id_WReg1
);

    reg [INST_DATA_WIDTH-1:0] inst_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            inst_reg <= 0;
        end else if (pipeline_enable) begin
            inst_reg <= inst;
        end
    end

    assign id_w_mem_en = inst_reg[31];
    assign id_w_reg_en = inst_reg[30];
    assign id_WReg1 = inst_reg[23:21];  // Essentially Write back Target Register

    wire [REG_ADDR_WIDTH-1:0] id_reg_1 = inst_reg[29:27];
    wire [REG_ADDR_WIDTH-1:0] id_reg_2 = inst_reg[26:24];

    mem_RF #(
        .ADDR_WIDTH(REG_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) REG_FILE (
        .clk(clk),
        .we(we),
        .reset(reset),
        .waddr(waddr),
        .wdata(wdata),
        .r0addr(id_reg_1),
        .r0data(id_R1_out),
        .r1addr(id_reg_2),
        .r1data(id_R2_out)
    );

endmodule
