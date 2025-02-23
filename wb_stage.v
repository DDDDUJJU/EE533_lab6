module wb_stage #(
    parameter REG_ADDR_WIDTH = 3,
    parameter MEM_ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 64
) (
    input wire clk,
    input wire reset,
    input wire pipeline_enable,

    // Logic from MEM
    input wire w_reg_en,
    input wire [DATA_WIDTH-1:0] D_in,
    input wire [REG_ADDR_WIDTH-1:0] WReg1,

    output wire wb_w_reg_en,
    output wire [DATA_WIDTH-1:0] wb_D_in,
    output wire [REG_ADDR_WIDTH-1:0] wb_WReg1
);
    reg w_reg_en_reg;
    reg [DATA_WIDTH-1:0] D_in_reg;
    reg [REG_ADDR_WIDTH-1:0] WReg1_reg;

    assign wb_w_reg_en = w_reg_en_reg;
    assign wb_D_in = D_in_reg;
    assign wb_WReg1 = WReg1_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_reg_en_reg <= 0;
            D_in_reg <= 0;
            WReg1_reg <= 0;
        end else if (pipeline_enable) begin
            w_reg_en_reg <= w_reg_en;
            D_in_reg <= D_in;
            WReg1_reg <= WReg1;
        end
    end

endmodule