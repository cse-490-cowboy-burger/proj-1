// alu_control_unit.v
// translates alu_op (from main control) + function code (from instruction)
// into the 3-bit alu_control signal that tells the ALU what to do
//
// alu_op encoding (from main control unit):
//   00 = add (used by lw, sw, addi)
//   01 = subtract for comparison (used by beq, bne)
//   10 = use function field (R-type instructions)
//   11 = spare / unused
//
// function code encoding (from instr[3:0], only matters when alu_op = 10):
//   0000 = add
//   0001 = sub
//   0010 = sll
//   0011 = and
//
// alu_control output encoding:
//   000 = add
//   001 = sub
//   010 = sll
//   011 = and

module alu_control_unit (
	input  wire [1:0]	alu_op,		// from main control unit
	input  wire [3:0]	funct,		// instr[3:0] function code
	output reg  [2:0]	alu_control	// goes to ALU
);

	always @(*) begin
		case (alu_op)
			2'b00: alu_control = 3'b000;	// add (lw/sw/addi address calc)
			2'b01: alu_control = 3'b001;	// sub (beq/bne comparison)

			2'b10: begin					// R-type: decode function field
				case (funct)
					4'b0000: alu_control = 3'b000;	// add
					4'b0001: alu_control = 3'b001;	// sub
					4'b0010: alu_control = 3'b010;	// sll
					4'b0011: alu_control = 3'b011;	// and
					default: alu_control = 3'b000;	// default to add
				endcase
			end

			default: alu_control = 3'b000;	// fallback
		endcase
	end

endmodule
