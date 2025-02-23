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
	input wire clk,
	input wire we, // Write enable
	input wire [DATA_WIDTH-1:0] wdata, // Write data
	input wire [ADDR_WIDTH-1:0] addr, // Read port 0 address (dedicated read)
	
	input wire pipline_enable, // interface pipline enable
	input wire interface_we, // write enable
	input wire [DATA_WIDTH-1:0] interface_wdata, // interface DRAM data
	input wire [DATA_WIDTH-1:0] interface_waddr, // interface DRAM write addr
	
	output reg [DATA_WIDTH-1:0] dout // Read port 0 data
);

(* ram_style = "block" *) reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

integer i;

initial begin
   for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
		mem[i] = 0;  // Set each memory location to zero
   end
end


initial begin
	mem[0] = 64'd4;
	mem[4] = 64'd100;
end


always @(negedge clk) begin
    // pipeline interface
	if (!pipline_enable) begin
	    if (interface_we) begin
		    mem[interface_waddr] <= interface_wdata;
		end else begin
		    dout <= mem[interface_waddr];
		end
	end
	// normal
	else begin
	    if (we) begin
		    mem[addr] <= wdata;
		end else begin
		    dout <= mem[addr];
		end
	end
end

endmodule