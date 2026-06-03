// ============================================================
// Module: arithmetic_logic_unit
// Description: 32-bit MIPS ALU supporting:
//   AND, OR, ADD, SUB, SLT (set-less-than)
//   Outputs result and Zero flag (used by beq).
//
// ALU control encoding:
//   0000 = AND
//   0001 = OR
//   0010 = ADD
//   0110 = SUB  (A - B using 2's complement)
//   0111 = SLT  (result = 1 if A < B, else 0)
//
// Stage: EX (Execute)
// ============================================================
module arithmetic_logic_unit (
    input  wire [31:0] operand_a,      // First operand (rs or forwarded)
    input  wire [31:0] operand_b,      // Second operand (rt or immediate)
    input  wire [3:0]  ALU_control,    // Operation select

    output reg  [31:0] alu_result,     // Computed result
    output wire        zero_flag       // 1 if result == 0 (for beq)
);

    assign zero_flag = (alu_result == 32'b0);

    always @(*) begin
        case (ALU_control)
            4'b0000: alu_result = operand_a & operand_b;                        // AND
            4'b0001: alu_result = operand_a | operand_b;                        // OR
            4'b0010: alu_result = operand_a + operand_b;                        // ADD
            4'b0110: alu_result = operand_a - operand_b;                        // SUB
            4'b0111: alu_result = ($signed(operand_a) < $signed(operand_b))     // SLT
                                  ? 32'b1 : 32'b0;
            default: alu_result = 32'b0;
        endcase
    end

endmodule
