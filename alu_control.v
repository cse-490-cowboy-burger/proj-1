`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 02:34:37 PM
// Design Name: 
// Module Name: alu_control
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


// decodes alu_op + funct into alu_control for the alu

module alu_control_unit (
	input  wire [1:0]	alu_op,
	input  wire [3:0]	funct,
	output reg  [2:0]	alu_control
);

	always @(*) begin
		case (alu_op)
			2'b00: alu_control = 3'b000;	// add (lw/sw/addi)
			2'b01: alu_control = 3'b001;	// sub (beq/bne)

			2'b10: begin					// r-type: use funct
				case (funct)
					4'b0000: alu_control = 3'b000;	// add
					4'b0001: alu_control = 3'b001;	// sub
					4'b0010: alu_control = 3'b010;	// sll
					4'b0011: alu_control = 3'b011;	// and
					default: alu_control = 3'b000;
				endcase
			end

			default: alu_control = 3'b000;
		endcase
	end

endmodule

