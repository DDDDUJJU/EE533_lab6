`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:35:53 02/19/2025 
// Design Name: 
// Module Name:    ex_mem_stage_reg 
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
module ex_mem_stage_reg #(
	parameter DATA_WIDTH = 64,
	parameter REG_ADDR_WIDTH = 3
)(
	input wire clk,
	input wire reset,
	input wire enable,

	input wire w_reg_en,
	input wire w_mem_en,
	input wire [DATA_WIDTH - 1:0] r1_out,
	input wire [DATA_WIDTH - 1:0] r2_out,
	input wire [REG_ADDR_WIDTH - 1:0] w_reg_1,
	
	output reg w_reg_en_o,
	output reg w_mem_en_o,
	output reg [DATA_WIDTH - 1:0] r1_out_o,
	output reg [DATA_WIDTH - 1:0] r2_out_o,
	output reg [REG_ADDR_WIDTH - 1:0] w_reg_1_o
);

	always @(posedge clk or posedge reset)
		if (reset) begin
			w_reg_en_o <= 0;
			w_mem_en_o <= 0;
			r1_out_o <= 0;
			r2_out_o <= 0;
			w_reg_1_o <= 0;
		end else if (enable) begin
			w_reg_en_o <= w_reg_en;
			w_mem_en_o <= w_mem_en;
			r1_out_o <= r1_out;
			r2_out_o <= r2_out;
			w_reg_1_o <= w_reg_1;
		end


endmodule
