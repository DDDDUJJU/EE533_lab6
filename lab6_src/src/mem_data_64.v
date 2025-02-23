`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:59:21 02/19/2025 
// Design Name: 
// Module Name:    mem_data_64 
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
module mem_data_64 #(
	parameter ADDR_WIDTH = 8, // e.g., 256 entries
	parameter DATA_WIDTH = 64
)(
	input wire clka, // write clock, neg
	input wire clkb, // read clock, pos
	input wire we, // Write enable

	input wire [DATA_WIDTH-1:0] wdata, // Write data
	input wire [ADDR_WIDTH-1:0] waddr, // Read port 0 address (dedicated read)
	
	input wire [ADDR_WIDTH-1:0] raddr, // interface DRAM read addr
	input wire [DATA_WIDTH-1:0] rdata,
	
	output reg [DATA_WIDTH-1:0] dout
);


reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

always @(negedge clka) begin
	if (we) begin
		mem[waddr] <= wdata;
	end
end

always @(posedge clkb) begin
	if (raddr != {ADDR_WIDTH{1'b1}}) begin
		dout <= mem[raddr];
	end else begin
		dout <= {DATA_WIDTH{1'b0}};
	end
end

endmodule