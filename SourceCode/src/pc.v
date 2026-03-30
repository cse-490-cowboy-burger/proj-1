
// program counter for our 16 bit single cycle processor
//
// just a 16 bit reg that loads next_pc every clock edge
// resets to 0 and does not compute pc+2 itself
// that happens outside in a separate adder (PC+2 adder)

module pc (
	input  wire			clk,		// clock
	input  wire			reset,		// active high sync reset
	input  wire [15:0]	next_pc,	// whatever the nextpc mux decided
	output reg  [15:0]	pc_out		// current pc value
);

	always @(posedge clk) begin
		if (reset)
			pc_out <= 16'h0000;
		else
			pc_out <= next_pc;
	end

endmodule
