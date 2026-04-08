`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 07:34:34 PM
// Design Name: 
// Module Name: data_memory
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


// byte addressed data memory, big endian
// 256 bytes, sync writes, async reads

module data_memory #(
	parameter MEM_SIZE = 256
)(
	input  wire			clk,
	input  wire			mem_read,
	input  wire			mem_write,
	input  wire [15:0]	address,
	input  wire [15:0]	write_data,
	output wire [15:0]	read_data
);

	reg [7:0] mem [0:MEM_SIZE-1];

	wire addr_valid = (address < MEM_SIZE - 1);

	// big endian: high byte at addr, low byte at addr+1
	assign read_data = (mem_read && addr_valid) ? {mem[address], mem[address + 1]} : 16'h0000;

	integer i;

	always @(posedge clk) begin
		if (mem_write && addr_valid) begin
			mem[address]     <= write_data[15:8];
			mem[address + 1] <= write_data[7:0];
		end
	end

	initial begin
		for (i = 0; i < MEM_SIZE; i = i + 1) begin
			mem[i] = 8'h00;
		end
	end

endmodule
