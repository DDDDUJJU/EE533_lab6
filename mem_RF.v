module mem_RF #(
	parameter ADDR_WIDTH = 3, // 8 entries
	parameter DATA_WIDTH = 64
)(
	input wire clk,
	input wire we, // Write enable
	input wire [ADDR_WIDTH-1:0] waddr, // Write address
	input wire [DATA_WIDTH-1:0] wdata, // Write data

	input wire [ADDR_WIDTH-1:0] r0addr, // Read port 0 address (dedicated read)
	output wire [DATA_WIDTH-1:0] r0data, // Read port 0 data

	input wire [ADDR_WIDTH-1:0] r1addr, // Read port 1 address (shared with write)
	output wire [DATA_WIDTH-1:0] r1data  // Read port 1 data
);
	// ------------------------------------------------------------------------------------
	// Xilinx ISE Testbench
	// ------------------------------------------------------------------------------------
	// integer i;
	// initial begin
	// 	for (i = 0; i < (1 << ADDR_WIDTH); i = i + 1) begin
	// 			mem[i] = 0;  // Set each memory location to zero
	// 	end
	// end

	always @(posedge clk or posedge reset) begin
		if (reset) begin
			mem[0] <= 0;
			mem[1] <= 0;
			mem[2] <= 0;
			mem[3] <= 0;
			mem[4] <= 0;
			mem[5] <= 0;
			mem[6] <= 0;
			mem[7] <= 0;
		end
	end

	// Use a single dual-port BRAM.
	reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

	assign r0data = mem[r0addr];
	assign r1data = mem[r1addr];

	always @(posedge clk) begin
		if (we) begin
			mem[waddr] <= wdata;
		end
	end

endmodule