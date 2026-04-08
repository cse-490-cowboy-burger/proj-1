`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 06:13:52 PM
// Design Name: 
// Module Name: register_file
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// 16x16 register file
// 2 read ports (async), 1 write port (clocked)

module register_file (
	input  wire			clk,
	input  wire			reset,
	input  wire [3:0]	read_addr1,
	input  wire [3:0]	read_addr2,
	output wire [15:0]	read_data1,
	output wire [15:0]	read_data2,
	input  wire			write_en,
	input  wire [3:0]	write_addr,
	input  wire [15:0]	write_data
);

	reg [15:0] regs [0:15];

	assign read_data1 = regs[read_addr1];
	assign read_data2 = regs[read_addr2];

	integer i;

	always @(posedge clk) begin
		if (reset) begin
			for (i = 0; i < 16; i = i + 1) begin
				regs[i] <= 16'h0000;
			end
		end else if (write_en) begin
			regs[write_addr] <= write_data;
		end
	end

endmodule

