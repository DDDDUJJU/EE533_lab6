`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:08:32 02/19/2025 
// Design Name: 
// Module Name:    mem_inst_32
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
module mem_inst_32 #(
	parameter ADDR_WIDTH = 9, // e.g., 256 entries
	parameter DATA_WIDTH = 32
)(
	input wire clk,
	input wire we, // Write enable
	input wire [ADDR_WIDTH-1:0] waddr, // Write address
	input wire [DATA_WIDTH-1:0] wdata, // Write data

	input wire [ADDR_WIDTH-1:0] r1addr, // Read port 1 address (shared with write)
	output reg [DATA_WIDTH-1:0] r1data // Read port 1 data
);

// Use a single dual-port BRAM.
// The ram_style attribute suggests to synthesis tools to implement this as a block RAM.
 reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

// Port B is used for both writing and r1 read.
// NOTE: When a write (we == 1) and a read (r1addr) occur simultaneously,
// if r1addr equals waddr the BRAM in write-first mode will output wdata.
// Otherwise the read from Port B may not be reliable if the addresses differ.
always @(posedge clk) begin
	if (we) begin
		mem[waddr] <= wdata;
	end
		r1data <= mem[r1addr];
end

endmodule