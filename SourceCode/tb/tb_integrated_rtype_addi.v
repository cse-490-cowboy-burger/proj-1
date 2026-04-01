
// testbench for integrated r-type and addi instruction flow
//
// wires together: control_unit + alu_control_unit + alu + sign_extend + register_file
// simulates actual instruction execution without instruction memory or pc
// manually feeds in instruction fields and verify the register file state
//
// what we are checking:
//	1. add  $s1, $s2       -> $s1 = $s2 + $s1
//	2. sub  $s1, $s2       -> $s1 = $s2 - $s1
//	3. sll  $s3, $s4       -> $s3 = $s3 << $s4
//	4. and  $s5, $s6       -> $s5 = $s5 & $s6
//	5. addi $s7, $s8, 5    -> $s7 = $s8 + 5
//	6. addi $s9, $s10, -1  -> $s9 = $s10 + (-1)
//	7. addi $s7, $s8, -8   -> $s7 = $s8 + (-8)
//	8. none of the source registers got corrupted

`timescale 1ns / 1ps

module tb_integration_rtype_addi;

	// clock and reset
	reg clk;
	reg reset;

	// instruction fields (manually set per test)
	reg [3:0] opcode;
	reg [3:0] rt_rd;
	reg [3:0] rs;
	reg [3:0] funct;

	// control signals
	wire		reg_write;
	wire		mem_read;
	wire		mem_write;
	wire		alu_src;
	wire		mem_to_reg;
	wire [1:0]	alu_op;
	wire		pc_src;
	wire		target_src;

	// alu control
	wire [2:0]	alu_control;

	// alu
	wire [15:0]	alu_result;
	wire		zero_flag;

	// register file
	wire [15:0]	read_data1;
	wire [15:0]	read_data2;

	// sign extension
	wire [15:0]	sign_ext_imm;

	// mux: alu input b selection (reg value or sign extended immediate)
	wire [15:0] alu_input_b;
	assign alu_input_b = alu_src ? sign_ext_imm : read_data2;

	// mux: writeback data (alu result or memory data)
	// for r-type and addi mem_to_reg=0 so we always use alu result here
	wire [15:0] write_data;
	assign write_data = mem_to_reg ? 16'h0000 : alu_result;

	// hook up the control unit
	control_unit ctrl (
		.opcode		(opcode),
		.zero		(zero_flag),
		.reg_write	(reg_write),
		.mem_read	(mem_read),
		.mem_write	(mem_write),
		.alu_src	(alu_src),
		.mem_to_reg	(mem_to_reg),
		.alu_op		(alu_op),
		.pc_src		(pc_src),
		.target_src	(target_src)
	);

	// hook up the alu control unit
	alu_control_unit alu_ctrl (
		.alu_op		(alu_op),
		.funct		(funct),
		.alu_control(alu_control)
	);

	// hook up the alu
	alu alu_inst (
		.a			(read_data1),
		.b			(alu_input_b),
		.alu_control(alu_control),
		.result		(alu_result),
		.zero		(zero_flag)
	);

	// hook up the sign extension unit
	sign_extend sext (
		.imm_in		(funct),
		.imm_out	(sign_ext_imm)
	);

	// hook up the register file
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

	initial begin
		pass_count = 0;
		fail_count = 0;

		// reset everything
		reset = 1;
		opcode = 4'b0000;
		rt_rd = 4'd0;
		rs = 4'd0;
		funct = 4'd0;
		@(posedge clk); #1;
		reset = 0;

		// preload some registers with known values
		regfile.regs[1]  = 16'h000A;	// $s1 = 10
		regfile.regs[2]  = 16'h0003;	// $s2 = 3
		regfile.regs[3]  = 16'h005A;	// $s3 = 0x005A (for sll)
		regfile.regs[4]  = 16'h0004;	// $s4 = 4 (shift amount)
		regfile.regs[5]  = 16'h000A;	// $s5 = 0x000A (for and)
		regfile.regs[6]  = 16'h000C;	// $s6 = 0x000C (for and)
		regfile.regs[8]  = 16'h0014;	// $s8 = 20 (for addi)
		regfile.regs[10] = 16'h0005;	// $s10 = 5 (for addi)

		// test 1: add $s1, $s2 -> $s1 = R[$s2] + R[$s1] = 3 + 10 = 13
		$display("\ntest 1: add $s1, $s2");

		opcode = 4'b0000;
		rt_rd  = 4'd1;
		rs     = 4'd2;
		funct  = 4'b0000;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[1], 16'h000D, "add_s1_s2");

		// test 2: sub $s1, $s2 -> $s1 = R[$s2] - R[$s1] = 3 - 13 = -10
		// -10 in twos complement is 0xFFF6
		$display("\ntest 2: sub $s1, $s2");

		opcode = 4'b0000;
		rt_rd  = 4'd1;
		rs     = 4'd2;
		funct  = 4'b0001;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[1], 16'hFFF6, "sub_s1_s2");

		// test 3: sll $s3, $s4 -> $s3 = $s3 << $s4 = 0x005A << 4 = 0x05A0
		$display("\ntest 3: sll $s3, $s4");

		opcode = 4'b0000;
		rt_rd  = 4'd3;
		rs     = 4'd4;
		funct  = 4'b0010;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[3], 16'h05A0, "sll_s3_s4");

		// test 4: and $s5, $s6 -> $s5 = $s5 & $s6 = 0x000A & 0x000C = 0x0008
		$display("\ntest 4: and $s5, $s6");

		opcode = 4'b0000;
		rt_rd  = 4'd5;
		rs     = 4'd6;
		funct  = 4'b0011;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[5], 16'h0008, "and_s5_s6");

		// test 5: addi $s7, $s8, 5 -> $s7 = R[$s8] + 5 = 20 + 5 = 25
		$display("\ntest 5: addi $s7, $s8, 5");

		opcode = 4'b0011;
		rt_rd  = 4'd7;
		rs     = 4'd8;
		funct  = 4'b0101;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[7], 16'h0019, "addi_s7_s8_5");

		// test 6: addi $s9, $s10, -1 -> $s9 = R[$s10] + (-1) = 5 + (-1) = 4
		$display("\ntest 6: addi $s9, $s10, -1");

		opcode = 4'b0011;
		rt_rd  = 4'd9;
		rs     = 4'd10;
		funct  = 4'b1111;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[9], 16'h0004, "addi_s9_s10_neg1");

		// test 7: addi $s7, $s8, -8 -> $s7 = R[$s8] + (-8) = 20 + (-8) = 12
		$display("\ntest 7: addi $s7, $s8, -8");

		opcode = 4'b0011;
		rt_rd  = 4'd7;
		rs     = 4'd8;
		funct  = 4'b1000;
		#1;
		@(posedge clk); #1;
		check(regfile.regs[7], 16'h000C, "addi_s7_s8_neg8");

		// test 8: make sure source registers were not corrupted
		// by any of the writes above
		$display("\ntest 8: no cross corruption");

		check(regfile.regs[2],  16'h0003, "s2_intact");
		check(regfile.regs[4],  16'h0004, "s4_intact");
		check(regfile.regs[6],  16'h000C, "s6_intact");
		check(regfile.regs[8],  16'h0014, "s8_intact");
		check(regfile.regs[10], 16'h0005, "s10_intact");

		$display("\n%0d passed, %0d failed\n", pass_count, fail_count);

		$finish;
	end

endmodule
