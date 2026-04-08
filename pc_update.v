`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2026 11:01:26 AM
// Design Name: 
// Module Name: pc_update
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


// computes next pc value
// handles pc+2, branch offsets, and jump offsets

module pc_update (
	input  wire [15:0]	pc_in,
	input  wire [15:0]	sign_ext_imm,
	input  wire [11:0]	jump_addr,
	input  wire			pc_src,
	input  wire			target_src,
	output wire [15:0]	next_pc
);

	wire [15:0] pc_plus_2 = pc_in + 16'd2;

	wire [15:0] branch_offset = sign_ext_imm << 1;

	wire [15:0] jump_extended = {{4{jump_addr[11]}}, jump_addr};
	wire [15:0] jump_offset = jump_extended << 1;

	wire [15:0] target_offset = target_src ? jump_offset : branch_offset;
	wire [15:0] target_addr = pc_plus_2 + target_offset;

	assign next_pc = pc_src ? target_addr : pc_plus_2;

endmodule

