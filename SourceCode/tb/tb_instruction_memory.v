`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 12:48:34 AM
// Design Name: 
// Module Name: tb_instruction_memory
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


`timescale 1ns / 1ps

module tb_instruction_memory;

    reg  [15:0] addr;
    wire [15:0] instruction;

    instruction_memory uut (
        .addr        (addr),
        .instruction (instruction)
    );

    initial begin
        // read first instruction at address 0
        addr = 0;
        #10;
        $display("addr=%0d  instruction=%h", addr, instruction);

        addr = 2;
        #10;
        $display("addr=%0d  instruction=%h", addr, instruction);

        addr = 4;
        #10;
        $display("addr=%0d  instruction=%h", addr, instruction);

        $finish;
    end

endmodule