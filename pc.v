`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 05:23:56 PM
// Design Name: 
// Module Name: pc
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


// program counter register

module pc (
	input  wire			clk,
	input  wire			reset,
	input  wire [15:0]	next_pc,
	output reg  [15:0]	pc_out
);

	always @(posedge clk) begin
		if (reset)
			pc_out <= 16'h0000;
		else
			pc_out <= next_pc;
	end

endmodule

