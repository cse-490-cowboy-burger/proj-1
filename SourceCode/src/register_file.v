
// 16x16-bit register file for our 16-bit single-cycle processor
//
// has two read ports (combinational) and one write port (clocked)
// reset zeros everything out
//
// top level wiring:
//	read_addr1 -> rs       (instr[7:4])
//	read_addr2 -> rt/rd    (instr[11:8])
//	write_addr -> rt/rd    (instr[11:8]) same field as read_addr2

module register_file (
	input  wire			clk,		// clock
	input  wire			reset,		// active high sync reset
	input  wire [3:0]	read_addr1,	// rs
	input  wire [3:0]	read_addr2,	// rt/rd
	output wire [15:0]	read_data1,	// whatever is in r[rs]
	output wire [15:0]	read_data2,	// whatever is in r[rt/rd]
	input  wire			write_en,	// regwrite from control
	input  wire [3:0]	write_addr,	// which reg to write (rt/rd)
	input  wire [15:0]	write_data	// value coming from writeback mux
);

	// 16 regs 16 bits each ($s0 - $s15)
	reg [15:0] regs [0:15];

	// reads are combinational so vals show up right away
	// no need to wait for clock edge
	assign read_data1 = regs[read_addr1];
	assign read_data2 = regs[read_addr2];

	// need this for the reset loop
	integer i;

	always @(posedge clk) begin
		if (reset) begin
			// wipe all regs to 0
			for (i = 0; i < 16; i = i + 1) begin
				regs[i] <= 16'h0000;
			end
		end else if (write_en) begin
			// only actually write when write_en is high
			// otherwise everything just holds
			regs[write_addr] <= write_data;
		end
	end

endmodule
