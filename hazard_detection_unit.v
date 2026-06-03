// ============================================================
// Module: hazard_detection_unit
// Description: Detects load-use data hazards that cannot be
//              resolved by forwarding alone (the load result
//              is not available until the end of MEM, one cycle
//              too late for the immediately following instruction).
//
// Detection condition:
//   ID/EX.MemRead == 1
//   AND (ID/EX.Rt == IF/ID.Rs OR ID/EX.Rt == IF/ID.Rt)
//
// When hazard detected:
//   PCWrite    = 0  → stall the PC (do not advance)
//   IF_ID_Write= 0  → stall IF/ID register (re-decode same instr)
//   ID_EX_Flush= 1  → insert NOP bubble into EX stage
//
// Branch hazard (beq detected in ID):
//   IF_ID_Flush = 1 → flush the incorrectly-fetched instruction
//   ID_EX_Flush = 1 → flush ID/EX if branch resolved early
//
// Stage: ID (Instruction Decode)
// ============================================================
module hazard_detection_unit (
    // Load-use hazard inputs
    input  wire        id_ex_MemRead,  // 1 if instruction in EX is a load
    input  wire [4:0]  id_ex_rt,       // Destination of the load (in EX)
    input  wire [4:0]  if_id_rs,       // rs of the instruction in ID
    input  wire [4:0]  if_id_rt,       // rt of the instruction in ID

    // Branch hazard inputs
    input  wire        branch_taken,   // 1 if beq resolves as taken

    // Stall / flush control outputs
    output reg         PCWrite,        // 1 = normal, 0 = stall
    output reg         IF_ID_Write,    // 1 = normal, 0 = stall
    output reg         ID_EX_Flush,    // 1 = flush (insert NOP bubble)
    output reg         IF_ID_Flush     // 1 = flush (branch taken)
);

    always @(*) begin
        // Defaults: no hazard
        PCWrite     = 1'b1;
        IF_ID_Write = 1'b1;
        ID_EX_Flush = 1'b0;
        IF_ID_Flush = 1'b0;

        // ---- Load-use hazard ----
        if (id_ex_MemRead &&
            ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt))) begin
            PCWrite     = 1'b0;    // Stall PC
            IF_ID_Write = 1'b0;    // Stall IF/ID
            ID_EX_Flush = 1'b1;    // Insert NOP into EX
        end

        // ---- Branch taken (beq resolved in ID/EX) ----
        if (branch_taken) begin
            IF_ID_Flush = 1'b1;    // Discard wrong-path fetch
            ID_EX_Flush = 1'b1;    // Discard wrong-path decode
        end
    end

endmodule
