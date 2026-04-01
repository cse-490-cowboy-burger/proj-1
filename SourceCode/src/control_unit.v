// main control unit for 16bit single cycle processor
//
// right now this only handles lw and sw
// everything else gets safe defaults (no writes to anything)
// other instructions will get added later as the team builds them out
//
// opcode reference:
//	lw    = 4'b0001
//	sw    = 4'b0010
//	rtype = 4'b0000 (uses funct field for add/sub/etc)
//	addi  = 4'b0011
//	beq   = 4'b0100
//	bne   = 4'b0101
//	jmp   = 4'b0110
//
// alu_op encoding:
//	00 = add (used by lw sw addi)
//	01 = subtract for comparison (used by beq bne)
//	10 = use function field (used by r type)
//	11 = spare

module control_unit (
	input  wire [3:0]	opcode,		// instr[15:12]
	input  wire			zero,		// alu zero flag (for branches later)
	output reg			reg_write,	// write to register file
	output reg			mem_read,	// read from data memory (lw)
	output reg			mem_write,	// write to data memory (sw)
	output reg			alu_src,	// 0 = reg value  1 = sign ext immediate
	output reg			mem_to_reg,	// 0 = alu result  1 = memory data
	output reg  [1:0]	alu_op,		// goes to alu control unit
	output reg			pc_src,		// 0 = pc+2  1 = branch/jump target
	output reg			target_src	// 0 = branch offset  1 = jump offset
);

	parameter OP_LW    = 4'b0001;
	parameter OP_SW    = 4'b0010;
	// parameter OP_RTYPE = 4'b0000;
	// parameter OP_ADDI  = 4'b0011;
	// parameter OP_BEQ   = 4'b0100;
	// parameter OP_BNE   = 4'b0101;
	// parameter OP_JMP   = 4'b0110;

	always @(*) begin
		// safe defaults: do nothing
		// no reg writes no mem writes just go to next instruction
		reg_write	= 0;
		mem_read	= 0;
		mem_write	= 0;
		alu_src		= 0;
		mem_to_reg	= 0;
		alu_op		= 2'b00;
		pc_src		= 0;
		target_src	= 0;

		case (opcode)
			OP_LW: begin
				reg_write	= 1;		// write loaded word back to reg file
				mem_read	= 1;		// reading from data memory
				alu_src		= 1;		// use immediate as alu input (for addr calc)
				mem_to_reg	= 1;		// writeback comes from mem not alu
				alu_op		= 2'b00;	// alu does add (base + offset)
			end

			OP_SW: begin
				mem_write	= 1;		// writing to data memory
				alu_src		= 1;		// use immediate as alu input (for addr calc)
				alu_op		= 2'b00;	// alu does add (base + offset)
			end

			// OP_RTYPE: begin

			// end

			// OP_ADDI: begin
			
			// end

			// OP_BEQ: begin

			// end

			// OP_BNE: begin

			// end

			// OP_JMP: begin

			// end

			// everything else falls through / does nothing
		endcase
	end

endmodule
