`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 04:02:48 PM
// Design Name: 
// Module Name: sign_extend
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


// sign extends 4 bit immediate to 16 bits

module sign_extend (
	input  wire [3:0]	imm_in,
	output wire [15:0]	imm_out
);

	assign imm_out = {{12{imm_in[3]}}, imm_in};

endmodule

