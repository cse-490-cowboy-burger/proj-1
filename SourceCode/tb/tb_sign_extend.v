// testbench for the sign extension unit
//
// what we are checking:
//	1. positive value (msb=0) gets zero extended
//	2. negative value -1 (1111) gets sign extended to 0xFFFF
//	3. zero stays zero
//	4. max positive +7 (0111)
//	5. min negative -8 (1000)
//	6. positive 1 (0001)
//	7. negative -2 (1110)

`timescale 1ns / 1ps

module tb_sign_extend;

	// signals going into/out of the sign extension unit
	reg  [3:0]	imm_in;
	wire [15:0]	imm_out;

	// hook up the sign extension unit
	sign_extend uut (
		.imm_in		(imm_in),
		.imm_out	(imm_out)
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

		pass_count = 0;
		fail_count = 0;

		// test 1: positive 5 (0101) -> 0x0005
		$display("\ntest 1: positive 5");

		imm_in = 4'b0101;
		#1;
		check(imm_out, 16'h0005, "sign_ext_pos_5");

		// test 2: negative -1 (1111) -> 0xFFFF
		$display("\ntest 2: negative -1");

		imm_in = 4'b1111;
		#1;
		check(imm_out, 16'hFFFF, "sign_ext_neg_1");

		// test 3: zero (0000) -> 0x0000
		$display("\ntest 3: zero");

		imm_in = 4'b0000;
		#1;
		check(imm_out, 16'h0000, "sign_ext_zero");

		// test 4: max positive +7 (0111) -> 0x0007
		$display("\ntest 4: max positive +7");

		imm_in = 4'b0111;
		#1;
		check(imm_out, 16'h0007, "sign_ext_pos_7");

		// test 5: min negative -8 (1000) -> 0xFFF8
		$display("\ntest 5: min negative -8");

		imm_in = 4'b1000;
		#1;
		check(imm_out, 16'hFFF8, "sign_ext_neg_8");

		// test 6: positive 1 (0001) -> 0x0001
		$display("\ntest 6: positive 1");

		imm_in = 4'b0001;
		#1;
		check(imm_out, 16'h0001, "sign_ext_pos_1");

		// test 7: negative -2 (1110) -> 0xFFFE
		$display("\ntest 7: negative -2");

		imm_in = 4'b1110;
		#1;
		check(imm_out, 16'hFFFE, "sign_ext_neg_2");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
