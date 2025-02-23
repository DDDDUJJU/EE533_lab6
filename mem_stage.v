module mem_stage #(
    parameter REG_ADDR_WIDTH = 3,
    parameter MEM_ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64
) (
    input wire clk,
    input wire reset,
    input wire pipeline_enable,

    // Logic from EX
    input wire w_mem_en,
    input wire w_reg_en,
    input wire [DATA_WIDTH-1:0] R1_in,
    input wire [DATA_WIDTH-1:0] R2_in,
    input wire [REG_ADDR_WIDTH-1:0] WReg1,

    // Logic to WB
    output wire mem_w_reg_en,
    output wire [DATA_WIDTH-1:0] mem_D_out,
    output wire [REG_ADDR_WIDTH-1:0] mem_WReg1
);
    reg w_mem_en_reg;
    reg w_reg_en_reg;
    reg [DATA_WIDTH-1:0] R1_in_reg;
    reg [DATA_WIDTH-1:0] R2_in_reg;
    reg [REG_ADDR_WIDTH-1:0] WReg1_reg;

    assign mem_w_reg_en = w_reg_en_reg;
    assign mem_WReg1 = WReg1_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_mem_en_reg <= 0;
            w_reg_en_reg <= 0;
            R1_in_reg <= 0;
            R2_in_reg <= 0;
            WReg1_reg <= 0;
        end else if (pipeline_enable) begin
            w_mem_en_reg <= w_mem_en;
            w_reg_en_reg <= w_reg_en;
            R1_in_reg <= R1_in;
            R2_in_reg <= R2_in;
            WReg1_reg <= WReg1;
        end
    end

    mem_data #(
        .ADDR_WIDTH(MEM_ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) D_MEM (
        .clk(clk),
        .we(w_mem_en_reg),
        .reset(reset),
        .addr(R1_in_reg),
        .wdata(R2_in_reg),
        .rdata(mem_D_out)
    );

endmodule

