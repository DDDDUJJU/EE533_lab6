`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:38:27 02/19/2025 
// Design Name: 
// Module Name:    mem_wb_stage_reg 
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
module mem_wb_stage_reg #(
	parameter DATA_WIDTH = 64,
	parameter REG_ADDR_WIDTH = 3
)(
	input wire clk,
	input wire reset,
	input wire enable,

	input wire w_reg_en,
	input wire [DATA_WIDTH - 1:0] dout,
	input wire [REG_ADDR_WIDTH - 1:0] w_reg_1,
	
	output reg w_reg_en_o,
	output reg [DATA_WIDTH - 1:0] dout_o,
	output reg [REG_ADDR_WIDTH - 1:0] w_reg_1_o
);
	always @(posedge clk or posedge reset)
		if (reset) begin
			w_reg_en_o <= 0;
			dout_o <= 0;
			w_reg_1_o <= 0;
		end else if (enable) begin
			w_reg_en_o <= w_reg_en;
			dout_o <= dout;
			w_reg_1_o <= w_reg_1;
		end

endmodule
