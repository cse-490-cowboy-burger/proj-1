// testbench for the register file
//
// what to check:
//	1. reset zeros out all 16 regs
//	2. write something then read it back
//	3. read two different regs at the same time
//	4. write_en=0 should not change anything
//	5. overwrite a reg with a new value
//	6. writing one reg does not mess up another

`timescale 1ns / 1ps

module tb_register_file;

	// signals going into/out of reg file
	reg			clk;
	reg			reset;
	reg  [3:0]	read_addr1;
	reg  [3:0]	read_addr2;
	wire [15:0]	read_data1;
	wire [15:0]	read_data2;
	reg			write_en;
	reg  [3:0]	write_addr;
	reg  [15:0]	write_data;

	// hook up reg file
	register_file uut (
		.clk		(clk),
		.reset		(reset),
		.read_addr1	(read_addr1),
		.read_addr2	(read_addr2),
		.read_data1	(read_data1),
		.read_data2	(read_data2),
		.write_en	(write_en),
		.write_addr	(write_addr),
		.write_data	(write_data)
	);

	// 10 ns clock (toggle every 5 ns)
	initial clk = 0;
	always #5 clk = ~clk;

	integer pass_count;
	integer fail_count;

	// little helper that compares actual vs expected and prints pass/fail
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

	integer i;

	initial begin
		// dump waves so we can look at them in gtkwave if needed
		// this is mostly for me (sam) b/c i am doing this on mac
		// should be commented out when moving to vivado
		// $dumpfile("tb_register_file.vcd");
		// $dumpvars(0, tb_register_file);

		pass_count = 0;
		fail_count = 0;

		// start everything at 0
		reset		= 0;
		write_en	= 0;
		read_addr1	= 4'd0;
		read_addr2	= 4'd0;
		write_addr	= 4'd0;
		write_data	= 16'h0000;

		// test 1: make sure reset actually clears everything
		$display("\ntest 1: reset clears all registers");

		reset = 1;
		@(posedge clk); #1;
		reset = 0;

		// sweep through all 16 regs and check theyre 0
		for (i = 0; i < 16; i = i + 1) begin
			read_addr1 = i[3:0];
			#1;
			check(read_data1, 16'h0000, "reset_reg");
		end

		// test 2: write 0xbeef to r3 then read it back
		$display("\ntest 2: write then read back");

		write_en	= 1;
		write_addr	= 4'd3;
		write_data	= 16'hBEEF;
		@(posedge clk); #1;
		write_en = 0;

		read_addr1 = 4'd3;
		#1;
		check(read_data1, 16'hBEEF, "write_read_r3");

		// test 3: read r3 and r7 at same time on both ports
		$display("\ntest 3: dual port read");

		// put something in r7 first
		write_en	= 1;
		write_addr	= 4'd7;
		write_data	= 16'h1234;
		@(posedge clk); #1;
		write_en = 0;

		read_addr1 = 4'd3;
		read_addr2 = 4'd7;
		#1;
		check(read_data1, 16'hBEEF, "dual_read_port1_r3");
		check(read_data2, 16'h1234, "dual_read_port2_r7");

		// test 4: try writing with write_en off (nothing should change)
		$display("\ntest 4: write enable gating");

		write_en	= 0;
		write_addr	= 4'd3;
		write_data	= 16'hDEAD;
		@(posedge clk); #1;

		// r3 should still be 0xbeef
		read_addr1 = 4'd3;
		#1;
		check(read_data1, 16'hBEEF, "wen_gating_r3");

		// test 5: overwrite r3 with something new
		$display("\ntest 5: overwrite");

		write_en	= 1;
		write_addr	= 4'd3;
		write_data	= 16'hCAFE;
		@(posedge clk); #1;
		write_en = 0;

		read_addr1 = 4'd3;
		#1;
		check(read_data1, 16'hCAFE, "overwrite_r3");

		// test 6: make sure r7 wasnt touched by any of the r3 writes
		$display("\ntest 6: no cross corruption");

		read_addr1 = 4'd7;
		#1;
		check(read_data1, 16'h1234, "no_corrupt_r7");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
