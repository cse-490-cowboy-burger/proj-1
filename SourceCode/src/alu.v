// 16-bit ALU for our single-cycle processor
//
// operations are selected by alu_control (3 bits):
//   000 = add
//   001 = subtract
//   010 = shift left logical (A << B)
//   011 = bitwise AND
//
// the alu_control signal comes from the alu_control_unit which
// combines alu_op (from main control) with the function code
// (from the instruction) to pick the right operation
//
// zero flag is set when the result is all zeros
// this is used by beq/bne in the datapath

module alu (
	input  wire [15:0]	a,			// first operand  (R[rs])
	input  wire [15:0]	b,			// second operand (R[rt/rd] or sign-extended imm)
	input  wire [2:0]	alu_control,// operation select
	output reg  [15:0]	result,		// computation result
	output wire			zero		// 1 when result == 0
);

	// alu_control encoding
	parameter ALU_ADD = 3'b000;
	parameter ALU_SUB = 3'b001;
	parameter ALU_SLL = 3'b010;
	parameter ALU_AND = 3'b011;

	always @(*) begin
		case (alu_control)
			ALU_ADD: result = a + b;					// add (signed, overflow ignored)
			ALU_SUB: result = a - b;					// sub (signed, underflow ignored)
			ALU_SLL: result = b << a[3:0];				// sll: shift b left by a bits
														// only need low 4 bits of a (max shift 15)
			ALU_AND: result = a & b;					// bitwise AND
			default: result = 16'h0000;					// safety net
		endcase
	end

	// zero flag: used by branch instructions
	assign zero = (result == 16'h0000);

endmodule
