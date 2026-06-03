// ============================================================
// Module: program_counter
// Description: Holds and updates the Program Counter (PC).
//              Supports stall (PCWrite=0) and normal increment.
// Stage: IF (Instruction Fetch)
// ============================================================
module program_counter (
    input  wire        clk,
    input  wire        reset,
    input  wire        PCWrite,       // 0 = stall (hold PC), 1 = update
    input  wire [31:0] pc_next,       // Next PC value (PC+4 or branch target)
    output reg  [31:0] pc_current     // Current PC output
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc_current <= 32'b0;
        else if (PCWrite)
            pc_current <= pc_next;
        // else: hold (stall)
    end

endmodule
