`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2026 06:45:46 PM
// Design Name: 
// Module Name: control_unit
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


// main control unit - decodes opcode into control signals

module control_unit (
	input  wire [3:0]	opcode,
	input  wire			zero,
	output reg			reg_write,
	output reg			mem_read,
	output reg			mem_write,
	output reg			alu_src,
	output reg			mem_to_reg,
	output reg  [1:0]	alu_op,
	output reg			pc_src,
	output reg			target_src
);

	parameter OP_RTYPE = 4'b0000;
	parameter OP_LW    = 4'b0001;
	parameter OP_SW    = 4'b0010;
	parameter OP_ADDI  = 4'b0011;
	parameter OP_BEQ   = 4'b0100;
	parameter OP_BNE   = 4'b0101;
	parameter OP_JMP   = 4'b0110;

	always @(*) begin
		// defaults
		reg_write	= 0;
		mem_read	= 0;
		mem_write	= 0;
		alu_src		= 0;
		mem_to_reg	= 0;
		alu_op		= 2'b00;
		pc_src		= 0;
		target_src	= 0;

		case (opcode)
			OP_LW: begin
				reg_write	= 1;
				mem_read	= 1;
				alu_src		= 1;
				mem_to_reg	= 1;
				alu_op		= 2'b00;
			end

			OP_SW: begin
				mem_write	= 1;
				alu_src		= 1;
				alu_op		= 2'b00;
			end

			OP_RTYPE: begin
				reg_write	= 1;
				alu_op		= 2'b10;
			end

			OP_ADDI: begin
				reg_write	= 1;
				alu_src		= 1;
				alu_op		= 2'b00;
			end

			OP_BEQ: begin
				alu_op		= 2'b01;
				pc_src		= zero;
			end

			OP_BNE: begin
				alu_op		= 2'b01;
				pc_src		= ~zero;
			end

			OP_JMP: begin
				pc_src		= 1;
				target_src	= 1;
			end
		endcase
	end

endmodule
