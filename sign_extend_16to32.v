// ============================================================
// Module: sign_extend_16to32
// Description: Sign-extends a 16-bit immediate field from a
//              MIPS I-type instruction to a 32-bit value.
// Stage: ID (Instruction Decode)
// ============================================================
module sign_extend_16to32 (
    input  wire [15:0] immediate_16,   // Raw 16-bit immediate from instruction
    output wire [31:0] immediate_32    // Sign-extended 32-bit result
);

    assign immediate_32 = {{16{immediate_16[15]}}, immediate_16};

endmodule
