// ============================================================
// Module: pipeline_register_IF_ID
// Description: Latches outputs of the IF stage and feeds the
//              ID stage on the next clock edge.
//              Supports stall (IF_ID_Write=0) and flush
//              (IF_ID_Flush=1) for branch/hazard control.
// Stage boundary: IF → ID
// ============================================================
module pipeline_register_IF_ID (
    input  wire        clk,
    input  wire        reset,
    input  wire        IF_ID_Write,    // 1=normal latch, 0=stall (hold)
    input  wire        IF_ID_Flush,    // 1=flush (insert bubble)
    input  wire [31:0] if_pc_plus4,    // PC+4 from IF stage
    input  wire [31:0] if_instruction, // Fetched instruction from IF stage

    output reg  [31:0] id_pc_plus4,    // Forwarded to ID stage
    output reg  [31:0] id_instruction  // Forwarded to ID stage
);

    always @(posedge clk or posedge reset) begin
        if (reset || IF_ID_Flush) begin
            id_pc_plus4    <= 32'b0;
            id_instruction <= 32'b0;   // NOP
        end
        else if (IF_ID_Write) begin
            id_pc_plus4    <= if_pc_plus4;
            id_instruction <= if_instruction;
        end
        // else: stall - hold current values
    end

endmodule
