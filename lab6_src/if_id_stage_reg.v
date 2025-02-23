`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:14:26 02/19/2025 
// Design Name: 
// Module Name:    if_id_stage_reg 
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
module if_id_stage_reg #(
	parameter DATA_WIDTH = 32
) (
	input wire clk,
	input wire reset,
	input wire [DATA_WIDTH - 1:0] if_inst,

	output reg [DATA_WIDTH - 1:0] id_inst

);

always @(posedge clk or posedge reset)
	if (reset) begin
		id_inst <= {DATA_WIDTH{1'b0}};
	end else begin
		id_inst <= if_inst;
end


endmodule
