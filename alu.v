`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 02:16:23 PM
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// 16 bit alu
// 000=add  001=sub  010=sll  011=and

module alu (
	input  wire [15:0]	a,
	input  wire [15:0]	b,
	input  wire [2:0]	alu_control,
	output reg  [15:0]	result,
	output wire			zero
);

	parameter ALU_ADD = 3'b000;
	parameter ALU_SUB = 3'b001;
	parameter ALU_SLL = 3'b010;
	parameter ALU_AND = 3'b011;

	always @(*) begin
		case (alu_control)
			ALU_ADD: result = a + b;
			ALU_SUB: result = a - b;
			ALU_SLL: result = b << a[3:0];
			ALU_AND: result = a & b;
			default: result = 16'h0000;
		endcase
	end

	assign zero = (result == 16'h0000);

endmodule

