// ============================================================
// Module: register_file
// Description: 32×32-bit MIPS general-purpose register file.
//              - Two asynchronous read ports (rs, rt)
//              - One synchronous write port (clocked on negedge
//                so WB data is available within same cycle for
//                ID read — standard MIPS textbook convention)
//              - $zero (R0) is hardwired to 0
// Stage: ID (Instruction Decode) / WB (Write-Back)
// ============================================================
module register_file (
    input  wire        clk,
    input  wire        RegWrite,       // 1 = write enabled
    input  wire [4:0]  read_reg1,      // rs field
    input  wire [4:0]  read_reg2,      // rt field
    input  wire [4:0]  write_reg,      // Destination register
    input  wire [31:0] write_data,     // Data to write

    output wire [31:0] read_data1,     // Value of rs
    output wire [31:0] read_data2      // Value of rt
);

    reg [31:0] registers [0:31];

    integer j;
    initial begin
        for (j = 0; j < 32; j = j + 1)
            registers[j] = 32'b0;
    end

    // Write on negative edge (allows same-cycle read-after-write)
    always @(negedge clk) begin
        if (RegWrite && write_reg != 5'b0)
            registers[write_reg] <= write_data;
    end

    // Asynchronous reads; R0 always 0
    assign read_data1 = (read_reg1 == 5'b0) ? 32'b0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'b0) ? 32'b0 : registers[read_reg2];

endmodule
