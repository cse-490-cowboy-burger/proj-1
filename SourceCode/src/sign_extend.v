// sign_extend.v
// sign extension unit for 16-bit single-cycle processor
//
// I-type instructions have a 4-bit immediate (instr[3:0])
// this needs to be sign-extended to 16 bits before the ALU can use it
//
// the sign bit is the MSB of the immediate field
// if the sign bit is 1, we fill the upper bits with 1s
// if the sign bit is 0, we fill the upper bits with 0s
//
// examples:
//   4'b0101 (5)  -> 16'h0005
//   4'b1111 (-1) -> 16'hFFFF
//   4'b1000 (-8) -> 16'hFFF8

module sign_extend (
	input  wire [3:0]	imm_in,		// 4-bit immediate from instruction
	output wire [15:0]	imm_out		// 16-bit sign-extended result
);

	// replicate the sign bit (imm_in[3]) into the upper 12 bits
	assign imm_out = {{12{imm_in[3]}}, imm_in};

endmodule
