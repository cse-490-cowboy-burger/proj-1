// testbench for the alu control unit
//
// what we are checking:
//	1. alu_op=00 always outputs add regardless of funct
//	2. alu_op=01 always outputs sub regardless of funct
//	3. alu_op=10 with funct=0000 gives add
//	4. alu_op=10 with funct=0001 gives sub
//	5. alu_op=10 with funct=0010 gives sll
//	6. alu_op=10 with funct=0011 gives and
//	7. alu_op=10 with unknown funct defaults to add

`timescale 1ns / 1ps

module tb_alu_control_unit;

	// signals going into/out of the alu control unit
	reg  [1:0]	alu_op;
	reg  [3:0]	funct;
	wire [2:0]	alu_control;

	// hook up the alu control unit
	alu_control_unit uut (
		.alu_op		(alu_op),
		.funct		(funct),
		.alu_control(alu_control)
	);

	integer pass_count;
	integer fail_count;

	// check helper (3 bit version for alu_control)
	task check3;
		input [2:0] actual;
		input [2:0] expected;
		input [8*40-1:0] test_name;
		begin
			if (actual === expected) begin
				$display("[PASS] %0s | got %03b", test_name, actual);
				pass_count = pass_count + 1;
			end else begin
				$display("[FAIL] %0s | expected %03b, got %03b",
					test_name, expected, actual);
				fail_count = fail_count + 1;
			end
		end
	endtask

	initial begin
		pass_count = 0;
		fail_count = 0;

		// test 1: alu_op=00 (lw/sw/addi) -> add regardless of funct
		$display("\ntest 1: alu_op=00 -> add");

		alu_op = 2'b00;
		funct = 4'b0000;
		#1;
		check3(alu_control, 3'b000, "aluop00_funct0000");

		funct = 4'b1111;
		#1;
		check3(alu_control, 3'b000, "aluop00_funct1111");

		// test 2: alu_op=01 (beq/bne) -> sub regardless of funct
		$display("\ntest 2: alu_op=01 -> sub");

		alu_op = 2'b01;
		funct = 4'b0000;
		#1;
		check3(alu_control, 3'b001, "aluop01_funct0000");

		funct = 4'b1111;
		#1;
		check3(alu_control, 3'b001, "aluop01_funct1111");

		// test 3: alu_op=10 funct=0000 -> add
		$display("\ntest 3: r-type add (funct=0000)");

		alu_op = 2'b10;
		funct = 4'b0000;
		#1;
		check3(alu_control, 3'b000, "rtype_add");

		// test 4: alu_op=10 funct=0001 -> sub
		$display("\ntest 4: r-type sub (funct=0001)");

		funct = 4'b0001;
		#1;
		check3(alu_control, 3'b001, "rtype_sub");

		// test 5: alu_op=10 funct=0010 -> sll
		$display("\ntest 5: r-type sll (funct=0010)");

		funct = 4'b0010;
		#1;
		check3(alu_control, 3'b010, "rtype_sll");

		// test 6: alu_op=10 funct=0011 -> and
		$display("\ntest 6: r-type and (funct=0011)");

		funct = 4'b0011;
		#1;
		check3(alu_control, 3'b011, "rtype_and");

		// test 7: alu_op=10 unknown funct -> defaults to add
		// picking 1010 as something we havent defined
		$display("\ntest 7: r-type unknown funct (default add)");

		funct = 4'b1010;
		#1;
		check3(alu_control, 3'b000, "rtype_unknown_funct");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
