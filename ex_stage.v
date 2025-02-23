module ex_stage #(
    parameter REG_ADDR_WIDTH = 3,
    parameter DATA_WIDTH = 64
) (
    input wire clk,
    input wire reset,
    input wire pipeline_enable,

    // Logic from ID
    input wire w_mem_en,
    input wire w_reg_en,
    input wire [DATA_WIDTH-1:0] R1_in,
    input wire [DATA_WIDTH-1:0] R2_in,
    input wire [REG_ADDR_WIDTH-1:0] WReg1,

    // Logic to MEM
    output wire ex_w_mem_en,
    output wire ex_w_reg_en,
    output wire [DATA_WIDTH-1:0] ex_R1_out,
    output wire [DATA_WIDTH-1:0] ex_R2_out,
    output wire [REG_ADDR_WIDTH-1:0] ex_WReg1
);

    reg w_mem_en_reg;
    reg w_reg_en_reg;
    reg [DATA_WIDTH-1:0] R1_in_reg;
    reg [DATA_WIDTH-1:0] R2_in_reg;
    reg [REG_ADDR_WIDTH-1:0] WReg1_reg;

    assign ex_w_mem_en = w_mem_en_reg;
    assign ex_w_reg_en = w_reg_en_reg;
    assign ex_R1_out = R1_in_reg;
    assign ex_R2_out = R2_in_reg;
    assign ex_WReg1 = WReg1_reg;

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

endmodule
