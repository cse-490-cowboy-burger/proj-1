// testbench for the program counter
//
// what to check:
//	1. reset sets pc to 0
//	2. pc loads next_pc on each clock edge
//	3. pc can load a few different values in a row
//	4. reset works even after pc has been running

`timescale 1ns / 1ps

module tb_pc;

	// signals going into/out of the pc
	reg			clk;
	reg			reset;
	reg  [15:0]	next_pc;
	wire [15:0]	pc_out;

	// hook up the pc
	pc uut (
		.clk		(clk),
		.reset		(reset),
		.next_pc	(next_pc),
		.pc_out		(pc_out)
	);

	// 10 ns clock (toggle every 5 ns)
	initial clk = 0;
	always #5 clk = ~clk;

	integer pass_count;
	integer fail_count;

	// same check helper as the reg file tb
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
		// should be commented out for vivado
		// $dumpfile("tb_pc.vcd");
		// $dumpvars(0, tb_pc);

		pass_count = 0;
		fail_count = 0;

		// start everything at 0
		reset	= 0;
		next_pc	= 16'h0000;

		// test 1: reset should force pc to 0
		$display("\ntest 1: reset");

		reset = 1;
		@(posedge clk); #1;
		check(pc_out, 16'h0000, "reset_to_zero");
		reset = 0;

		// test 2: simulate normal pc+2 stepping
		// in the real datapath the pc+2 adder feeds next_pc
		// here we just do it manually
		$display("\ntest 2: sequential increments");

		next_pc = 16'h0002;
		@(posedge clk); #1;
		check(pc_out, 16'h0002, "load_0002");

		next_pc = 16'h0004;
		@(posedge clk); #1;
		check(pc_out, 16'h0004, "load_0004");

		next_pc = 16'h0006;
		@(posedge clk); #1;
		check(pc_out, 16'h0006, "load_0006");

		// test 3: jump to some random address
		// this is what would happen on a branch or jmp
		$display("\ntest 3: non sequential load");

		next_pc = 16'h0040;
		@(posedge clk); #1;
		check(pc_out, 16'h0040, "jump_to_0040");

		// test 4: hit reset while pc has a non zero value
		$display("\ntest 4: reset after running");

		reset = 1;
		@(posedge clk); #1;
		check(pc_out, 16'h0000, "reset_mid_run");
		reset = 0;

		// and make sure it picks back up normally after
		next_pc = 16'h0002;
		@(posedge clk); #1;
		check(pc_out, 16'h0002, "resume_after_reset");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
