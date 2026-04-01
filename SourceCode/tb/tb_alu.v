// testbench for the alu
//
// what we are checking:
//	1. add two positive numbers
//	2. add positive and negative (signed)
//	3. add that results in zero (zero flag should be set)
//	4. add that overflows (wraps around, which is fine)
//	5. sub basic subtraction
//	6. sub resulting in zero (zero flag should be set)
//	7. sub that gives a negative result
//	8. sll by 4 (spec example)
//	9. sll by 0 (no change)
//	10. sll large shift (upper bits get discarded)
//	11. sll by 15 (only lsb survives to msb)
//	12. AND basic bitwise (spec example)
//	13. AND with zero (should give zero)
//	14. AND with 0xFFFF (identity)
//	15. AND with 0x0000 (should give zero)
//	16. unknown alu_control defaults to zero

`timescale 1ns / 1ps

module tb_alu;

	// signals going into/out of the alu
	reg  [15:0]	a;
	reg  [15:0]	b;
	reg  [2:0]	alu_control;
	wire [15:0]	result;
	wire		zero;

	// hook up the alu
	alu uut (
		.a			(a),
		.b			(b),
		.alu_control(alu_control),
		.result		(result),
		.zero		(zero)
	);

	integer pass_count;
	integer fail_count;

	// check helper for 16 bit result
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

	// check helper (1 bit version for zero flag)
	task check1;
		input actual;
		input expected;
		input [8*40-1:0] test_name;
		begin
			if (actual === expected) begin
				$display("[PASS] %0s | got %0b", test_name, actual);
				pass_count = pass_count + 1;
			end else begin
				$display("[FAIL] %0s | expected %0b, got %0b",
					test_name, expected, actual);
				fail_count = fail_count + 1;
			end
		end
	endtask

	initial begin
		pass_count = 0;
		fail_count = 0;

		// test 1: add 5 + 3 = 8
		$display("\ntest 1: add positive + positive");

		a = 16'h0005;
		b = 16'h0003;
		alu_control = 3'b000;
		#1;
		check(result, 16'h0008, "add_5_plus_3");
		check1(zero, 0, "add_5_plus_3_zero");

		// test 2: add 10 + (-3) = 7
		// -3 in twos complement is 0xFFFD
		$display("\ntest 2: add positive + negative");

		a = 16'h000A;
		b = 16'hFFFD;
		alu_control = 3'b000;
		#1;
		check(result, 16'h0007, "add_10_plus_neg3");

		// test 3: add 5 + (-5) = 0
		// zero flag should be set
		$display("\ntest 3: add resulting in zero");

		a = 16'h0005;
		b = 16'hFFFB;
		alu_control = 3'b000;
		#1;
		check(result, 16'h0000, "add_5_plus_neg5");
		check1(zero, 1, "add_zero_flag_set");

		// test 4: add 0x7FFF + 1 = 0x8000
		// overflow wraps which is fine per the spec
		$display("\ntest 4: add overflow wraps");

		a = 16'h7FFF;
		b = 16'h0001;
		alu_control = 3'b000;
		#1;
		check(result, 16'h8000, "add_overflow_wrap");

		// test 5: sub 10 - 3 = 7
		$display("\ntest 5: sub basic");

		a = 16'h000A;
		b = 16'h0003;
		alu_control = 3'b001;
		#1;
		check(result, 16'h0007, "sub_10_minus_3");
		check1(zero, 0, "sub_10_minus_3_zero");

		// test 6: sub 5 - 5 = 0
		// zero flag should be set
		$display("\ntest 6: sub resulting in zero");

		a = 16'h0005;
		b = 16'h0005;
		alu_control = 3'b001;
		#1;
		check(result, 16'h0000, "sub_5_minus_5");
		check1(zero, 1, "sub_zero_flag_set");

		// test 7: sub 3 - 10 = -7
		// -7 in twos complement is 0xFFF9
		$display("\ntest 7: sub negative result");

		a = 16'h0003;
		b = 16'h000A;
		alu_control = 3'b001;
		#1;
		check(result, 16'hFFF9, "sub_3_minus_10");

		// test 8: sll 0x005A << 4 = 0x05A0
		// this is the example from the spec
		// a = shift amount (R[rs]), b = value to shift (R[rt/rd])
		$display("\ntest 8: sll by 4 (spec example)");

		a = 16'h0004;
		b = 16'h005A;
		alu_control = 3'b010;
		#1;
		check(result, 16'h05A0, "sll_005A_by_4");

		// test 9: sll by 0 should not change anything
		$display("\ntest 9: sll by 0");

		a = 16'h0000;
		b = 16'hABCD;
		alu_control = 3'b010;
		#1;
		check(result, 16'hABCD, "sll_by_0");

		// test 10: sll 0x000F << 12 = 0xF000
		// upper bits get discarded
		$display("\ntest 10: sll large shift");

		a = 16'h000C;
		b = 16'h000F;
		alu_control = 3'b010;
		#1;
		check(result, 16'hF000, "sll_000F_by_12");

		// test 11: sll 0x0001 << 15 = 0x8000
		// only the lsb survives all the way to msb position
		$display("\ntest 11: sll by 15");

		a = 16'h000F;
		b = 16'h0001;
		alu_control = 3'b010;
		#1;
		check(result, 16'h8000, "sll_0001_by_15");

		// test 12: and 0x000A & 0x000C = 0x0008
		// this is the example from the spec
		$display("\ntest 12: and basic (spec example)");

		a = 16'h000C;
		b = 16'h000A;
		alu_control = 3'b011;
		#1;
		check(result, 16'h0008, "and_000A_000C");

		// test 13: and with 0x0000 should give zero
		$display("\ntest 13: and with zero");

		a = 16'h0000;
		b = 16'hFFFF;
		alu_control = 3'b011;
		#1;
		check(result, 16'h0000, "and_with_zero");
		check1(zero, 1, "and_zero_flag");

		// test 14: and with 0xFFFF should give the other value back
		$display("\ntest 14: and with all ones (identity)");

		a = 16'hFFFF;
		b = 16'hABCD;
		alu_control = 3'b011;
		#1;
		check(result, 16'hABCD, "and_identity");

		// test 15: and alternating bits should cancel out to zero
		// 0xAAAA = 1010... and 0x5555 = 0101...
		$display("\ntest 15: and alternating bits");

		a = 16'hAAAA;
		b = 16'h5555;
		alu_control = 3'b011;
		#1;
		check(result, 16'h0000, "and_alternating");

		// test 16: unknown alu_control should produce 0
		$display("\ntest 16: unknown alu_control (safe default)");

		a = 16'hBEEF;
		b = 16'hCAFE;
		alu_control = 3'b111;
		#1;
		check(result, 16'h0000, "default_zero");
		check1(zero, 1, "default_zero_flag");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
