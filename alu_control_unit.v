// ============================================================
// Module: alu_control_unit
// Description: Generates a 4-bit ALU operation code based on:
//              - ALUOp[1:0] from the main control unit
//              - funct[5:0] field from R-type instructions
//
// ALUOp  | Instruction | ALU action
// -------+-------------+-----------
//  2'b00 | lw / sw     | ADD
//  2'b01 | beq         | SUB
//  2'b10 | R-type      | Decode funct
//  2'b11 | addi        | ADD
//
// funct codes (R-type):
//   100000 = add  → ALU_ADD (0010)
//   100010 = sub  → ALU_SUB (0110)
//   100100 = and  → ALU_AND (0000)
//   100101 = or   → ALU_OR  (0001)
//   101010 = slt  → ALU_SLT (0111)
//
// ALU control output encoding:
//   0000 = AND
//   0001 = OR
//   0010 = ADD
//   0110 = SUB
//   0111 = SLT
//
// Stage: EX (Execute)
// ============================================================
module alu_control_unit (
    input  wire [1:0]  ALUOp,
    input  wire [5:0]  funct,
    output reg  [3:0]  ALU_control
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALU_control = 4'b0010;   // ADD (lw/sw address)
            2'b01: ALU_control = 4'b0110;   // SUB (beq compare)
            2'b11: ALU_control = 4'b0010;   // ADD (addi)
            2'b10: begin                    // R-type: decode funct
                case (funct)
                    6'b100000: ALU_control = 4'b0010; // add
                    6'b100010: ALU_control = 4'b0110; // sub
                    6'b100100: ALU_control = 4'b0000; // and
                    6'b100101: ALU_control = 4'b0001; // or
                    6'b101010: ALU_control = 4'b0111; // slt
                    default:   ALU_control = 4'b0010; // default ADD
                endcase
            end
            default: ALU_control = 4'b0010;
        endcase
    end

endmodule
