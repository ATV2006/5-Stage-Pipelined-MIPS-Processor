// ============================================================
// Module: pc_adder
// Description: Computes PC + 4 (sequential next instruction)
//              or PC + 4 + (SignExt_Imm << 2) for branch target.
// Stage: IF / EX
// ============================================================
module pc_adder (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] result
);

    assign result = a + b;

endmodule
