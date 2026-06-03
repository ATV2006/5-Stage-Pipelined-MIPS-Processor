// ============================================================
// Module: main_control_unit
// Description: Decodes the 6-bit opcode of a MIPS instruction
//              and generates all datapath control signals.
//
// Supported instructions:
//   R-type  : add, sub, and, or, slt  (opcode = 000000)
//   addi    : opcode = 001000
//   lw      : opcode = 100011
//   sw      : opcode = 101011
//   beq     : opcode = 000100
//
// Stage: ID (Instruction Decode)
// ============================================================
module main_control_unit (
    input  wire [5:0]  opcode,

    output reg         RegDst,     // 1=rd destination, 0=rt destination
    output reg         ALUSrc,     // 1=immediate, 0=register
    output reg         MemtoReg,   // 1=memory→reg, 0=ALU→reg
    output reg         RegWrite,   // 1=enable register write
    output reg         MemRead,    // 1=enable data memory read
    output reg         MemWrite,   // 1=enable data memory write
    output reg         Branch,     // 1=beq branch instruction
    output reg  [1:0]  ALUOp       // ALU operation type hint
);

    // ALUOp encoding:
    //   2'b10 = R-type  (ALU control decodes funct field)
    //   2'b00 = add     (lw/sw: add for address)
    //   2'b01 = sub     (beq: subtract to compare)
    //   2'b11 = addi    (add immediate)

    always @(*) begin
        // Defaults (NOP / bubble)
        RegDst   = 1'b0;
        ALUSrc   = 1'b0;
        MemtoReg = 1'b0;
        RegWrite = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        Branch   = 1'b0;
        ALUOp    = 2'b00;

        case (opcode)
            6'b000000: begin  // R-type
                RegDst   = 1'b1;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b10;
            end
            6'b001000: begin  // addi
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b0;
                RegWrite = 1'b1;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b11;
            end
            6'b100011: begin  // lw
                RegDst   = 1'b0;
                ALUSrc   = 1'b1;
                MemtoReg = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end
            6'b101011: begin  // sw
                RegDst   = 1'bx;  // don't care
                ALUSrc   = 1'b1;
                MemtoReg = 1'bx;  // don't care
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b1;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end
            6'b000100: begin  // beq
                RegDst   = 1'bx;
                ALUSrc   = 1'b0;
                MemtoReg = 1'bx;
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b1;
                ALUOp    = 2'b01;
            end
            default: begin    // NOP / unsupported
                RegDst   = 1'b0;
                ALUSrc   = 1'b0;
                MemtoReg = 1'b0;
                RegWrite = 1'b0;
                MemRead  = 1'b0;
                MemWrite = 1'b0;
                Branch   = 1'b0;
                ALUOp    = 2'b00;
            end
        endcase
    end

endmodule
