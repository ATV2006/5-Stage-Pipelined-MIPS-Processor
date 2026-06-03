// ============================================================
// Module: forwarding_unit
// Description: Detects data hazards and selects forwarding
//              paths so the EX stage always receives the most
//              recent value of a register without stalling.
//
// Forwarding priority (EX hazard > MEM hazard):
//   ForwardA/ForwardB encoding:
//     2'b00 = No forwarding    → use ID/EX register file value
//     2'b10 = EX/MEM forward  → forward EX stage result
//     2'b01 = MEM/WB forward  → forward MEM stage result
//
// Conditions:
//   EX hazard  : EX/MEM.RegWrite && EX/MEM.Rd != 0
//                && EX/MEM.Rd == ID/EX.Rs (or Rt)
//   MEM hazard : MEM/WB.RegWrite && MEM/WB.Rd != 0
//                && EX/MEM.Rd != ID/EX.Rs (or Rt)  [not already forwarded]
//                && MEM/WB.Rd == ID/EX.Rs (or Rt)
//
// Stage: EX (Execute)
// ============================================================
module forwarding_unit (
    // Source registers of instruction in EX stage
    input  wire [4:0]  ex_rs,
    input  wire [4:0]  ex_rt,

    // Destination register of instruction in EX/MEM register
    input  wire        exmem_RegWrite,
    input  wire [4:0]  exmem_rd,

    // Destination register of instruction in MEM/WB register
    input  wire        memwb_RegWrite,
    input  wire [4:0]  memwb_rd,

    // Forwarding select signals
    output reg  [1:0]  ForwardA,       // Mux select for ALU operand A
    output reg  [1:0]  ForwardB        // Mux select for ALU operand B
);

    always @(*) begin
        // ---- ForwardA: operand from rs ----
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == ex_rs))
            ForwardA = 2'b10;          // EX/MEM hazard
        else if (memwb_RegWrite && (memwb_rd != 5'b0) && (memwb_rd == ex_rs))
            ForwardA = 2'b01;          // MEM/WB hazard
        else
            ForwardA = 2'b00;          // No hazard

        // ---- ForwardB: operand from rt ----
        if (exmem_RegWrite && (exmem_rd != 5'b0) && (exmem_rd == ex_rt))
            ForwardB = 2'b10;          // EX/MEM hazard
        else if (memwb_RegWrite && (memwb_rd != 5'b0) && (memwb_rd == ex_rt))
            ForwardB = 2'b01;          // MEM/WB hazard
        else
            ForwardB = 2'b00;          // No hazard
    end

endmodule
