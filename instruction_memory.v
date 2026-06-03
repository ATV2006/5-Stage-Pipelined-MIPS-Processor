// ============================================================
// Module: instruction_memory
// Description: ROM that holds program instructions.
//              Word-addressed; returns 32-bit instruction.
//              Initialized from an internal array (modifiable
//              via $readmemh for real programs).
// Stage: IF (Instruction Fetch)
// ============================================================
module instruction_memory (
    input  wire [31:0] address,        // Byte address (PC value)
    output wire [31:0] instruction     // 32-bit MIPS instruction
);

    reg [31:0] mem [0:255];            // 256 words = 1KB instruction memory

    // -----------------------------------------------------------
    // Test program preloaded at elaboration time.
    // To load from a file uncomment:
    //   initial $readmemh("program.hex", mem);
    // -----------------------------------------------------------
    integer i;
    initial begin
        // Zero out memory first
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'b0;
            // ---- Sample MIPS test program ----
        // addi $t0, $zero, 5     -> $t0 = 5
        mem[0]  = 32'h20080005;
        // addi $t1, $zero, 3     -> $t1 = 3
        mem[1]  = 32'h20090003;
        // add  $t2, $t0, $t1     -> $t2 = 8
        mem[2]  = 32'h01095020;
        // sub  $t3, $t0, $t1     -> $t3 = 2
        mem[3]  = 32'h01095822;
        // sw   $t2, 0($zero)     -> Mem[0] = $t2
        mem[4]  = 32'hAC0A0000;
        // lw   $t4, 0($zero)     -> $t4 = Mem[0]
        mem[5]  = 32'h8C0C0000;
        // beq  $t3, $t1, 2       -> branch if $t3 == $t1 (not taken)
        mem[6]  = 32'h112B0002;
        // addi $t5, $zero, 10    -> $t5 = 10
        mem[7]  = 32'h200D000A;
        // addi $t6, $zero, 20    -> $t6 = 20
        mem[8]  = 32'h200E0014;
        // add  $t7, $t5, $t6     -> $t7 = 30
        mem[9]  = 32'h01AE7820;
        // nop (halt loop)
        mem[10] = 32'h00000000;
    end

    // Word-aligned read (byte address >> 2)
    assign instruction = mem[address[31:2]];

endmodule
