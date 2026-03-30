// data_memory.v
// byte addressed data memory for our 16 bit single cycle processor
//
// stores bytes individually but lw/sw always work on 16 bit words
// uses big endian byte ordering:
//	mem[addr]   = high byte
//	mem[addr+1] = low byte
//
// 256 bytes by default (parameterized so we can change it later)
// sync writes on posedge clk
// async (combinational) reads
//
// word accesses need addr and addr+1 to both be in range
// so the highest valid word address is MEM_SIZE - 2
// anything out of bounds gets ignored on writes and reads back as 0

module data_memory #(
	parameter MEM_SIZE = 256		// number of bytes
)(
	input  wire			clk,		// clock
	input  wire			mem_read,	// from control unit (lw)
	input  wire			mem_write,	// from control unit (sw)
	input  wire [15:0]	address,	// byte address from alu result
	input  wire [15:0]	write_data,	// r[rt/rd] value for sw
	output wire [15:0]	read_data	// word read out for lw
);

	// byte array - each entry is 8 bits
	reg [7:0] mem [0:MEM_SIZE-1];

	// address is valid if both addr and addr+1 fit inside the array
	wire addr_valid = (address < MEM_SIZE - 1);

	// read is combinational (no clock needed)
	// big endian: high byte at address and low byte at address+1
	// outputs 0 if mem_read is off or address is out of bounds
	assign read_data = (mem_read && addr_valid) ? {mem[address], mem[address + 1]} : 16'h0000;

	// need this for the init loop
	integer i;

	// write is clocked
	// only writes if address is actually in range
	always @(posedge clk) begin
		if (mem_write && addr_valid) begin
			// big endian store: high byte first then low byte
			mem[address]     <= write_data[15:8];
			mem[address + 1] <= write_data[7:0];
		end
	end

	// zero out all memory at startup
	initial begin
		for (i = 0; i < MEM_SIZE; i = i + 1) begin
			mem[i] = 8'h00;
		end
	end

endmodule
