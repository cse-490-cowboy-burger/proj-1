`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 12:21:29 AM
// Design Name: 
// Module Name: instruction_memory
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


// pc feeds in a byte address and then spit out the 16 bit instruction at the location
// instructions are always 2 bytes (16 bit)

module instruction_memory #(
    parameter MEM_SIZE = 256  // byte size, 256
)(
    input  wire [15:0] addr,
    output wire [15:0] instruction
);

    // mem array
    reg [7:0] mem [0:MEM_SIZE-1];

    wire addr_valid = (addr < MEM_SIZE - 1);

    // addr, addr+1 for big endian
    // output is 0s if oob
    assign instruction = addr_valid ? {mem[addr], mem[addr + 1]} : 16'h0000;

    integer i;

    
    initial begin
    
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 8'h00;
        end

        // instructions can be run below, or via mem file
        $readmemb("program.mem", mem);
    end

endmodule