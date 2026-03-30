
// testbench for the control unit
//
// what we are checking:
//	1. lw opcode produces the right control signals
//	2. sw opcode produces the right control signals
//	3. unknown opcodes fall through to safe defaults (nothing writes)

`timescale 1ns / 1ps

module tb_control_unit;

	// signals going into/out of the control unit
	reg  [3:0]	opcode;
	reg			zero;
	wire		reg_write;
	wire		mem_read;
	wire		mem_write;
	wire		alu_src;
	wire		mem_to_reg;
	wire [1:0]	alu_op;
	wire		pc_src;
	wire		target_src;

	// hook up the control unit
	control_unit uut (
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

	integer pass_count;
	integer fail_count;

	// check helper (1 bit version for most control signals)
	task check1;
		input actual;
		input expected;
		input [8*40-1:0] test_name;
		begin
			if (actual === expected) begin
				$display("[PASS] %0s | got %0b", test_name, actual);
				pass_count = pass_count + 1;
			end else begin
				$display("[FAIL] %0s | expected %0b got %0b",
					test_name, expected, actual);
				fail_count = fail_count + 1;
			end
		end
	endtask

	// check helper (2 bit version for alu_op)
	task check2;
		input [1:0] actual;
		input [1:0] expected;
		input [8*40-1:0] test_name;
		begin
			if (actual === expected) begin
				$display("[PASS] %0s | got %02b", test_name, actual);
				pass_count = pass_count + 1;
			end else begin
				$display("[FAIL] %0s | expected %02b got %02b",
					test_name, expected, actual);
				fail_count = fail_count + 1;
			end
		end
	endtask

	initial begin
		// dump waves for gtkwave (comment out for vivado)
		$dumpfile("tb_control_unit.vcd");
		$dumpvars(0, tb_control_unit);

		pass_count = 0;
		fail_count = 0;

		// zero flag not used for lw/sw but set it to something known
		zero = 0;

		// test 1: lw (opcode 0001)
		// should: read memory + write to reg file + alu uses immediate
		// + writeback from memory
		$display("\ntest 1: lw opcode");

		opcode = 4'b0001;
		#1;
		check1(reg_write,	1, "lw_reg_write");
		check1(mem_read,	1, "lw_mem_read");
		check1(mem_write,	0, "lw_mem_write");
		check1(alu_src,		1, "lw_alu_src");
		check1(mem_to_reg,	1, "lw_mem_to_reg");
		check2(alu_op,		2'b00, "lw_alu_op");
		check1(pc_src,		0, "lw_pc_src");
		check1(target_src,	0, "lw_target_src");

		// test 2: sw (opcode 0010)
		// should: write to memory + alu uses immediate
		// should not write to reg file or read from memory
		$display("\ntest 2: sw opcode");

		opcode = 4'b0010;
		#1;
		check1(reg_write,	0, "sw_reg_write");
		check1(mem_read,	0, "sw_mem_read");
		check1(mem_write,	1, "sw_mem_write");
		check1(alu_src,		1, "sw_alu_src");
		check1(mem_to_reg,	0, "sw_mem_to_reg");
		check2(alu_op,		2'b00, "sw_alu_op");
		check1(pc_src,		0, "sw_pc_src");
		check1(target_src,	0, "sw_target_src");

		// test 3: unknown opcode (should produce safe defaults)
		// picking 1111 as something we havent defined
		$display("\ntest 3: unknown opcode (safe defaults)");

		opcode = 4'b1111;
		#1;
		check1(reg_write,	0, "unk_reg_write");
		check1(mem_read,	0, "unk_mem_read");
		check1(mem_write,	0, "unk_mem_write");
		check1(alu_src,		0, "unk_alu_src");
		check1(mem_to_reg,	0, "unk_mem_to_reg");
		check2(alu_op,		2'b00, "unk_alu_op");
		check1(pc_src,		0, "unk_pc_src");
		check1(target_src,	0, "unk_target_src");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
