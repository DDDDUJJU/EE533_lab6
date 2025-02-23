`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:06:20 02/22/2025 
// Design Name: 
// Module Name:    ALU32 
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
module ALU32 (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  alu_ctrl,
    output reg [31:0] result,
    output        zero,
    output reg    overflow
);

    localparam ALU_ADD       = 3'b000;
    localparam ALU_SUB       = 3'b001;
    localparam ALU_AND       = 3'b010;
    localparam ALU_OR        = 3'b011;
    localparam ALU_XNOR      = 3'b100;
    localparam ALU_CMP       = 3'b101;
    localparam ALU_SHIFT     = 3'b110;
    localparam ALU_SHIFT_CMP = 3'b111;

    always @(*) begin
        overflow = 1'b0;
        case (alu_ctrl[3:1])
            ALU_ADD: begin
                result = a + b;
                overflow = ((a[31] == b[31]) && (result[31] != a[31]));
            end
            ALU_SUB: begin
                result = a - b;
                overflow = ((a[31] != b[31]) && (result[31] != a[31]));
            end
            ALU_AND:
                result = a & b;
            ALU_OR:
                result = a | b;
            ALU_XNOR:
                result = ~(a ^ b);
            ALU_CMP:
                result = (a == b) ? 32'd1 : 32'd0;
            ALU_SHIFT: begin
                if (alu_ctrl[0] == 1'b0)
                    result = a << b[4:0];
                else
                    result = a >> b[4:0];
            end
            ALU_SHIFT_CMP:
                result = (((alu_ctrl[0] == 1'b0) ? (a << b[4:0]) : (a >> b[4:0])) == b) ? 32'd1 : 32'd0;
            default:
                result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule
