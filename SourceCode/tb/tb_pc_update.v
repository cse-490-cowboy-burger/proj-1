// tb_pc_update.v
// testbench for the pc update block
//
// what we are checking:
//	1. normal sequential: pc_src=0 gives pc+2
//	2. forward branch taken
//	3. backward branch taken (negative immediate)
//	4. jump forward
//	5. jump backward (negative 12 bit address)
//	6. branch not taken still gives pc+2
//	7. pc at zero gives 0x0002 in sequential case

`timescale 1ns / 1ps

module tb_pc_update;

	// signals going into/out of pc update
	reg  [15:0]	pc_in;
	reg  [15:0]	sign_ext_imm;
	reg  [11:0]	jump_addr;
	reg			pc_src;
	reg			target_src;
	wire [15:0]	next_pc;

	// hook up the pc update block
	pc_update uut (
		.pc_in			(pc_in),
		.sign_ext_imm	(sign_ext_imm),
		.jump_addr		(jump_addr),
		.pc_src			(pc_src),
		.target_src		(target_src),
		.next_pc		(next_pc)
	);

	integer pass_count;
	integer fail_count;

	// same check helper as other testbenches
	task check;
		input [15:0] actual;
		input [15:0] expected;
		input [8*40-1:0] test_name;
		begin
			if (actual === expected) begin
				$display("[PASS] %0s | got 0x%04h", test_name, actual);
				pass_count = pass_count + 1;
			end else begin
				$display("[FAIL] %0s | expected 0x%04h, got 0x%04h",
					test_name, expected, actual);
				fail_count = fail_count + 1;
			end
		end
	endtask

	initial begin
		// dump waves for gtkwave
		// (just for me sam on mac plz comment out for vivado)
		// $dumpfile("tb_pc_update.vcd");
		// $dumpvars(0, tb_pc_update);

		pass_count = 0;
		fail_count = 0;

		// start everything at 0
		pc_in			= 16'h0000;
		sign_ext_imm	= 16'h0000;
		jump_addr		= 12'h000;
		pc_src			= 0;
		target_src		= 0;

		// test 1: normal sequential (pc_src=0 should just give pc+2)
		$display("\ntest 1: normal sequential pc+2");

		pc_in	= 16'h0010;
		pc_src	= 0;
		#1;
		// 0x0010 + 2 = 0x0012
		check(next_pc, 16'h0012, "seq_from_0010");

		pc_in = 16'h0004;
		#1;
		// 0x0004 + 2 = 0x0006
		check(next_pc, 16'h0006, "seq_from_0004");

		// test 2: forward branch taken
		// pc=0x0020 and immediate=0x0003 (positive)
		// branch offset = 0x0003 << 1 = 0x0006
		// target = pc+2 + offset = 0x0022 + 0x0006 = 0x0028
		$display("\ntest 2: forward branch taken");

		pc_in			= 16'h0020;
		sign_ext_imm	= 16'h0003;
		pc_src			= 1;
		target_src		= 0;
		#1;
		check(next_pc, 16'h0028, "branch_fwd");

		// test 3: backward branch taken
		// pc=0x0020 and immediate=0xFFFE (sign extended -2)
		// branch offset = 0xFFFE << 1 = 0xFFFC (-4 in twos complement)
		// target = pc+2 + offset = 0x0022 + 0xFFFC = 0x001E
		$display("\ntest 3: backward branch taken");

		pc_in			= 16'h0020;
		sign_ext_imm	= 16'hFFFE;	// -2 sign extended to 16 bits
		pc_src			= 1;
		target_src		= 0;
		#1;
		check(next_pc, 16'h001E, "branch_bwd");

		// test 4: jump forward
		// pc=0x0010 and jump_addr=12'h00A (positive +10)
		// jump extended = 16'h000A
		// jump offset = 0x000A << 1 = 0x0014
		// target = pc+2 + offset = 0x0012 + 0x0014 = 0x0026
		$display("\ntest 4: jump forward");

		pc_in		= 16'h0010;
		jump_addr	= 12'h00A;
		pc_src		= 1;
		target_src	= 1;
		#1;
		check(next_pc, 16'h0026, "jump_fwd");

		// test 5: jump backward
		// pc=0x0020 and jump_addr=12'hFFE (-2 in 12 bit signed)
		// sign extend: 16'hFFFE
		// jump offset = 0xFFFE << 1 = 0xFFFC (-4)
		// target = pc+2 + offset = 0x0022 + 0xFFFC = 0x001E
		$display("\ntest 5: jump backward");

		pc_in		= 16'h0020;
		jump_addr	= 12'hFFE;		// -2 in 12 bit signed
		pc_src		= 1;
		target_src	= 1;
		#1;
		check(next_pc, 16'h001E, "jump_bwd");

		// test 6: branch not taken (pc_src=0 so we ignore target entirely)
		// even though we have branch/jump inputs set to stuff
		// next_pc should just be pc+2
		$display("\ntest 6: branch not taken still gives pc+2");

		pc_in			= 16'h0040;
		sign_ext_imm	= 16'h0005;
		jump_addr		= 12'h100;
		pc_src			= 0;
		target_src		= 0;
		#1;
		check(next_pc, 16'h0042, "not_taken_0040");

		// also try with target_src=1 and pc_src still 0
		target_src = 1;
		#1;
		check(next_pc, 16'h0042, "not_taken_tsrc1");

		// test 7: pc at zero sequential
		$display("\ntest 7: pc at zero");

		pc_in	= 16'h0000;
		pc_src	= 0;
		#1;
		check(next_pc, 16'h0002, "zero_seq");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
