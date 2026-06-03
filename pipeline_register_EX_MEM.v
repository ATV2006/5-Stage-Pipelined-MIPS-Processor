// ============================================================
// Module: pipeline_register_EX_MEM
// Description: Latches EX-stage outputs for use in MEM stage.
// Stage boundary: EX → MEM
// ============================================================
module pipeline_register_EX_MEM (
    input  wire        clk,
    input  wire        reset,

    // Control signals
    input  wire        ex_MemtoReg,
    input  wire        ex_RegWrite,
    input  wire        ex_MemRead,
    input  wire        ex_MemWrite,
    input  wire        ex_Branch,

    // Datapath values
    input  wire        ex_zero_flag,    // From ALU (used by beq)
    input  wire [31:0] ex_branch_target,// Computed branch address
    input  wire [31:0] ex_alu_result,   // ALU result / memory address
    input  wire [31:0] ex_rt_data,      // Data to write to memory (sw)
    input  wire [4:0]  ex_write_reg,    // Destination register (rd or rt)

    // MEM-stage outputs
    output reg         mem_MemtoReg,
    output reg         mem_RegWrite,
    output reg         mem_MemRead,
    output reg         mem_MemWrite,
    output reg         mem_Branch,

    output reg         mem_zero_flag,
    output reg  [31:0] mem_branch_target,
    output reg  [31:0] mem_alu_result,
    output reg  [31:0] mem_rt_data,
    output reg  [4:0]  mem_write_reg
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_MemtoReg      <= 1'b0;
            mem_RegWrite      <= 1'b0;
            mem_MemRead       <= 1'b0;
            mem_MemWrite      <= 1'b0;
            mem_Branch        <= 1'b0;
            mem_zero_flag     <= 1'b0;
            mem_branch_target <= 32'b0;
            mem_alu_result    <= 32'b0;
            mem_rt_data       <= 32'b0;
            mem_write_reg     <= 5'b0;
        end
        else begin
            mem_MemtoReg      <= ex_MemtoReg;
            mem_RegWrite      <= ex_RegWrite;
            mem_MemRead       <= ex_MemRead;
            mem_MemWrite      <= ex_MemWrite;
            mem_Branch        <= ex_Branch;
            mem_zero_flag     <= ex_zero_flag;
            mem_branch_target <= ex_branch_target;
            mem_alu_result    <= ex_alu_result;
            mem_rt_data       <= ex_rt_data;
            mem_write_reg     <= ex_write_reg;
        end
    end

endmodule
