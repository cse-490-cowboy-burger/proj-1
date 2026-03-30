// testbench for the data memory
//
// what to check:
//	1. write a word then read it back
//	2. big endian byte order is correct (high byte at addr and low at addr+1)
//	3. mem_write=0 should not change memory
//	4. mem_read=0 should output 0
//	5. writing to one address does not mess up another
//	6. multiple words at different addresses
//	7. out of bounds write is ignored
//	8. out of bounds read returns 0
//	9. boundary address (last valid word at MEM_SIZE-2)

`timescale 1ns / 1ps

module tb_data_memory;

	// signals going into/out of data memory
	reg			clk;
	reg			mem_read;
	reg			mem_write;
	reg  [15:0]	address;
	reg  [15:0]	write_data;
	wire [15:0]	read_data;

	// hook up data memory
	data_memory uut (
		.clk		(clk),
		.mem_read	(mem_read),
		.mem_write	(mem_write),
		.address	(address),
		.write_data	(write_data),
		.read_data	(read_data)
	);

	// 10 ns clock (toggle every 5 ns)
	initial clk = 0;
	always #5 clk = ~clk;

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

	// helper to check individual bytes so we can verify endianness
	task check_byte;
		input [7:0] actual;
		input [7:0] expected;
		input [8*40-1:0] test_name;
		begin
			if (actual === expected) begin
				$display("[PASS] %0s | got 0x%02h", test_name, actual);
				pass_count = pass_count + 1;
			end else begin
				$display("[FAIL] %0s | expected 0x%02h, got 0x%02h",
					test_name, expected, actual);
				fail_count = fail_count + 1;
			end
		end
	endtask

	initial begin
		// dump waves for gtkwave
		// (just for me sam on mac comment out for vivado)
		// $dumpfile("tb_data_memory.vcd");
		// $dumpvars(0, tb_data_memory);

		pass_count = 0;
		fail_count = 0;

		// start everything idle
		mem_read	= 0;
		mem_write	= 0;
		address		= 16'h0000;
		write_data	= 16'h0000;

		// test 1: write 0xabcd to address 0x0010 then read it back
		$display("\ntest 1: basic write and read back");

		mem_write	= 1;
		address		= 16'h0010;
		write_data	= 16'hABCD;
		@(posedge clk); #1;
		mem_write = 0;

		// now read it back
		mem_read = 1;
		address  = 16'h0010;
		#1;
		check(read_data, 16'hABCD, "write_read_0010");
		mem_read = 0;

		// test 2: verify big endian byte order
		// we wrote 0xabcd to 0x0010 so:
		//	mem[0x0010] should be 0xab (high byte)
		//	mem[0x0011] should be 0xcd (low byte)
		$display("\ntest 2: big endian byte ordering");

		check_byte(uut.mem[16'h0010], 8'hAB, "high_byte_at_0010");
		check_byte(uut.mem[16'h0011], 8'hCD, "low_byte_at_0011");

		// test 3: mem_write=0 should not change anything
		$display("\ntest 3: mem_write gating");

		// try to write 0xdead to same address with mem_write off
		mem_write	= 0;
		address		= 16'h0010;
		write_data	= 16'hDEAD;
		@(posedge clk); #1;

		// should still read 0xabcd
		mem_read = 1;
		address  = 16'h0010;
		#1;
		check(read_data, 16'hABCD, "mw_gating_0010");
		mem_read = 0;

		// test 4: mem_read=0 should output 0
		$display("\ntest 4: mem_read gating");

		mem_read = 0;
		address  = 16'h0010;
		#1;
		check(read_data, 16'h0000, "mr_off_outputs_zero");

		// test 5: write to a different address and make sure
		// the first one is still intact
		$display("\ntest 5: no cross corruption");

		mem_write	= 1;
		address		= 16'h0020;
		write_data	= 16'h1234;
		@(posedge clk); #1;
		mem_write = 0;

		// check the new address
		mem_read = 1;
		address  = 16'h0020;
		#1;
		check(read_data, 16'h1234, "write_read_0020");

		// check original address still has 0xabcd
		address = 16'h0010;
		#1;
		check(read_data, 16'hABCD, "still_abcd_at_0010");
		mem_read = 0;

		// test 6: write a few words to adjacent addresses
		// making sure they dont overlap or stomp each other
		$display("\ntest 6: multiple adjacent words");

		// write 0x1111 at addr 0x0040 and 0x2222 at addr 0x0042
		// these are back to back (each word is 2 bytes)
		mem_write	= 1;
		address		= 16'h0040;
		write_data	= 16'h1111;
		@(posedge clk); #1;

		address		= 16'h0042;
		write_data	= 16'h2222;
		@(posedge clk); #1;
		mem_write = 0;

		// read both back
		mem_read = 1;
		address  = 16'h0040;
		#1;
		check(read_data, 16'h1111, "adjacent_word_0040");

		address = 16'h0042;
		#1;
		check(read_data, 16'h2222, "adjacent_word_0042");
		mem_read = 0;

		// test 7: out of bounds write should be ignored
		// memory is 256 bytes (0x00 to 0xFF) so 0x0100 is out of range
		$display("\ntest 7: out of bounds write ignored");

		// put something known at addr 0x0000 first
		mem_write	= 1;
		address		= 16'h0000;
		write_data	= 16'hAAAA;
		@(posedge clk); #1;
		mem_write = 0;

		// try writing to an address way out of bounds
		mem_write	= 1;
		address		= 16'h0100;
		write_data	= 16'hDEAD;
		@(posedge clk); #1;
		mem_write = 0;

		// make sure addr 0x0000 was not corrupted by the bad write
		mem_read = 1;
		address  = 16'h0000;
		#1;
		check(read_data, 16'hAAAA, "oob_write_no_corrupt");
		mem_read = 0;

		// test 8: out of bounds read should return 0
		$display("\ntest 8: out of bounds read returns 0");

		mem_read = 1;
		address  = 16'h0100;
		#1;
		check(read_data, 16'h0000, "oob_read_zero");
		mem_read = 0;

		// test 9: boundary address (last valid word is at MEM_SIZE - 2 = 0x00FE)
		// addr 0x00FE uses bytes 0xFE and 0xFF which are both in range
		// addr 0x00FF would need byte 0x100 which is out of range
		$display("\ntest 9: boundary addresses");

		// write to last valid word address
		mem_write	= 1;
		address		= 16'h00FE;
		write_data	= 16'hBEEF;
		@(posedge clk); #1;
		mem_write = 0;

		mem_read = 1;
		address  = 16'h00FE;
		#1;
		check(read_data, 16'hBEEF, "boundary_valid_00FE");

		// try the address right after (0x00FF) which is out of bounds
		// because it would need byte at 0x0100
		address = 16'h00FF;
		#1;
		check(read_data, 16'h0000, "boundary_invalid_00FF");
		mem_read = 0;

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
