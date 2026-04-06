// combinational block that computes the next pc value
//
// sits between the pc register and its next_pc input
// contains the pc+2 adder and all the branch/jump target logic
//
// internally:
//	1. pc+2 adder
//	2. branch offset shift left 1 (sign ext imm comes in already 16 bit)
//	3. jump offset sign extend 12->16 then shift left 1
//	4. target offset mux (branch vs jump offset)
//	5. target address adder (pc+2 + selected offset)
//	6. next pc mux (pc+2 vs target address)

module pc_update (
	input  wire [15:0]	pc_in,			// current pc from pc module
	input  wire [15:0]	sign_ext_imm,	// from sign extension unit (for branches)
	input  wire [11:0]	jump_addr,		// instr[11:0] from instruction memory
	input  wire			pc_src,			// from control unit (0=pc+2  1=target)
	input  wire			target_src,		// from control unit (0=branch  1=jump)
	output wire [15:0]	next_pc			// feeds into pc module
);

	// step 1: add 2 to current pc (each instruction is 2 bytes)
	wire [15:0] pc_plus_2 = pc_in + 16'd2;

	// step 2: branch offset is the sign extended immediate shifted left by 1
	// the shift aligns to even byte addresses since instructions are 2 bytes wide
	wire [15:0] branch_offset = sign_ext_imm << 1;

	// step 3: jump offset needs sign extension from 12 to 16 bits then shift left 1
	wire [15:0] jump_extended = {{4{jump_addr[11]}}, jump_addr};
	wire [15:0] jump_offset = jump_extended << 1;

	// step 4: pick between branch offset and jump offset
	wire [15:0] target_offset = target_src ? jump_offset : branch_offset;

	// step 5: compute the actual target address
	wire [15:0] target_addr = pc_plus_2 + target_offset;

	// step 6: pick between normal pc+2 and the branch/jump target
	assign next_pc = pc_src ? target_addr : pc_plus_2;

endmodule
