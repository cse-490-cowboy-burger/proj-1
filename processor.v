`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/06/2026 10:01:08 AM
// Design Name: 
// Module Name: processor
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


// top level processor

module processor (
	input  wire			clk,
	input  wire			reset,
	output wire [15:0]	pc_out
);


	// wires
	wire [15:0]	pc_current;
	wire [15:0]	next_pc;
	wire [15:0]	instruction;

	// decode fields
	wire [3:0]	opcode		= instruction[15:12];
	wire [3:0]	rt_rd		= instruction[11:8];
	wire [3:0]	rs			= instruction[7:4];
	wire [3:0]	funct_imm	= instruction[3:0];
	wire [11:0]	jump_addr	= instruction[11:0];

	wire		reg_write;
	wire		mem_read;
	wire		mem_write;
	wire		alu_src;
	wire		mem_to_reg;
	wire [1:0]	alu_op;
	wire		pc_src;
	wire		target_src;

	wire [2:0]	alu_control;
	wire [15:0]	alu_result;
	wire		zero;

	wire [15:0]	read_data1;
	wire [15:0]	read_data2;

	wire [15:0]	sign_ext_imm;

	wire [15:0]	mem_read_data;

	wire [15:0]	alu_input_b;
	wire [15:0]	write_data;

	assign pc_out = pc_current;

	// modules

	pc pc_inst (
		.clk		(clk),
		.reset		(reset),
		.next_pc	(next_pc),
		.pc_out		(pc_current)
	);

	pc_update pc_update_inst (
		.pc_in			(pc_current),
		.sign_ext_imm	(sign_ext_imm),
		.jump_addr		(jump_addr),
		.pc_src			(pc_src),
		.target_src		(target_src),
		.next_pc		(next_pc)
	);

	instruction_memory imem (
		.addr			(pc_current),
		.instruction	(instruction)
	);

	control_unit ctrl (
		.opcode		(opcode),
		.zero		(zero),
		.reg_write	(reg_write),
		.mem_read	(mem_read),
		.mem_write	(mem_write),
		.alu_src	(alu_src),
		.mem_to_reg	(mem_to_reg),
		.alu_op		(alu_op),
		.pc_src		(pc_src),
		.target_src	(target_src)
	);

	alu_control_unit alu_ctrl (
		.alu_op		(alu_op),
		.funct		(funct_imm),
		.alu_control(alu_control)
	);

	register_file regfile (
		.clk		(clk),
		.reset		(reset),
		.read_addr1	(rs),
		.read_addr2	(rt_rd),
		.read_data1	(read_data1),
		.read_data2	(read_data2),
		.write_en	(reg_write),
		.write_addr	(rt_rd),
		.write_data	(write_data)
	);

	sign_extend sext (
		.imm_in		(funct_imm),
		.imm_out	(sign_ext_imm)
	);

	mux2to1 alu_src_mux (
		.in0		(read_data2),
		.in1		(sign_ext_imm),
		.sel		(alu_src),
		.out		(alu_input_b)
	);

	alu alu_inst (
		.a			(read_data1),
		.b			(alu_input_b),
		.alu_control(alu_control),
		.result		(alu_result),
		.zero		(zero)
	);

	data_memory dmem (
		.clk		(clk),
		.mem_read	(mem_read),
		.mem_write	(mem_write),
		.address	(alu_result),
		.write_data	(read_data2),
		.read_data	(mem_read_data)
	);

	mux2to1 wb_mux (
		.in0		(alu_result),
		.in1		(mem_read_data),
		.sel		(mem_to_reg),
		.out		(write_data)
	);

endmodule

