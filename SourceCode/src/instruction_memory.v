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
// instruction_memory.v
//
// uses big endian byte ordering:
//   mem[addr]   = high byte
//   mem[addr+1] = low byte
//
// 256 bytes by default but can be changed
// can read from mem file or hardcode
//
// the pc feeds in a byte address and then spit out the 16 bit instruction at the location
// instructions are always 2 bytes (16 bit)

module instruction_memory #(
    parameter MEM_SIZE = 256  // number of bytes in mem, 256 for now
)(
    input  wire [15:0] addr,        // input address from pc
    output wire [15:0] instruction  // output the instruction
);

    // array init, each is 8 bits wide, #mem-1 total, 255 (256) for now
    reg [7:0] mem [0:MEM_SIZE-1];

    // check if the address is within the bounds
    wire addr_valid = (addr < MEM_SIZE - 1);

    // high byte at addr low byte at addr+1
    // assign the instruction output to mem, mem+1 if its within bounds. otherwise, all 0s
    assign instruction = addr_valid ? {mem[addr], mem[addr + 1]} : 16'h0000;

    // init i for the loop
    integer i;

    // initialize memory
    // option 1: load from mem file
    // option 2: hardcode a test
    initial begin
        // zero out all mem first
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 8'h00;
        end

        // to load from a file leave this uncommented, to test locally, comment this line out
        $readmemb("program.mem", mem);
    end

endmodule
