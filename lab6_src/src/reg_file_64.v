`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:59:21 02/19/2025 
// Design Name: 
// Module Name:    reg_file_64 
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
module reg_file_64 #(
	parameter ADDR_WIDTH = 3, // e.g., 256 entries
	parameter DATA_WIDTH = 64
)(
	input wire clk,
	input wire we, // Write enable
	input wire [ADDR_WIDTH-1:0] waddr, // Write address
	input wire [DATA_WIDTH-1:0] wdata, // Write data

	input wire [ADDR_WIDTH-1:0] r0addr, // Read port 0 address (dedicated read)
	output reg [DATA_WIDTH-1:0] r0data, // Read port 0 data

	input wire [ADDR_WIDTH-1:0] r1addr, // Read port 1 address (shared with write)
	output reg [DATA_WIDTH-1:0] r1data // Read port 1 data
);

// Use a single dual-port BRAM.
// The ram_style attribute suggests to synthesis tools to implement this as a block RAM.
reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

// Port A is dedicated for r0 read only.
always @(negedge clk) begin
	r0data <= mem[r0addr];
end

// Port B is used for both writing and r1 read.
// NOTE: When a write (we == 1) and a read (r1addr) occur simultaneously,
// if r1addr equals waddr the BRAM in write-first mode will output wdata.
// Otherwise the read from Port B may not be reliable if the addresses differ.
always @(negedge clk) begin
	if (we) begin
		mem[waddr] <= wdata;
	end
		r1data <= mem[r1addr];
end

endmodule