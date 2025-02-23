module mem_inst #(
	parameter ADDR_WIDTH = 9, // e.g., 512 entries
	parameter DATA_WIDTH = 32
)(
	input wire clk,
	input wire we, // Write enable
	input wire [ADDR_WIDTH-1:0] addr,  // Write address
	input wire [DATA_WIDTH-1:0] wdata, // Write data
	output reg [DATA_WIDTH-1:0] rdata  // Read data
);
	// ------------------------------------------------------------------------------------
	// Xilinx ISE Testbench
	// ------------------------------------------------------------------------------------
	// initial begin
	// 	// Initial values for the memory (example)
	// 	mem[0] = 11'b01000000010 << 21;
	// 	mem[1] = 11'b01000000011 << 21;
	// 	mem[2] = 11'b00000000000 << 21;
	// 	mem[3] = 11'b00000000000 << 21;
	// 	mem[4] = 11'b00000000000 << 21;
	// 	mem[5] = 11'b10010011000 << 21;
	// 	// Add more initialization as required
	// end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			mem[0] = 11'b01000000010 << 21;
			mem[1] = 11'b01000000011 << 21;
			mem[2] = 11'b00000000000 << 21;
			mem[3] = 11'b00000000000 << 21;
			mem[4] = 11'b00000000000 << 21;
			mem[5] = 11'b10010011000 << 21;
		end
	end

	// single-port synchronous memory
	reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];

	always @(posedge clk) begin
		if (we) begin
			mem[addr] <= wdata;
		end

		rdata <= mem[addr];
	end

endmodule