// ============================================================
// Module: data_memory
// Description: Single-cycle 32-bit word-addressable data memory.
//              - Synchronous write (on posedge clk)
//              - Asynchronous read
//              Size: 256 words (1 KB)
// Stage: MEM (Memory Access)
// ============================================================
module data_memory (
    input  wire        clk,
    input  wire        MemRead,        // 1 = read enable
    input  wire        MemWrite,       // 1 = write enable
    input  wire [31:0] address,        // Byte address
    input  wire [31:0] write_data,     // Data to write (sw)
    output wire [31:0] read_data       // Data read (lw)
);

    reg [31:0] mem [0:255];            // 256 × 32-bit = 1 KB

    integer k;
    initial begin
        for (k = 0; k < 256; k = k + 1)
            mem[k] = 32'b0;
    end

    // Synchronous write
    always @(posedge clk) begin
        if (MemWrite)
            mem[address[31:2]] <= write_data;
    end

    // Asynchronous read
    assign read_data = MemRead ? mem[address[31:2]] : 32'b0;

endmodule
