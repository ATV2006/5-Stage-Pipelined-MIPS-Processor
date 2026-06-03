// ============================================================
// Module: pipeline_register_MEM_WB
// Description: Latches MEM-stage outputs for use in WB stage.
// Stage boundary: MEM → WB
// ============================================================
module pipeline_register_MEM_WB (
    input  wire        clk,
    input  wire        reset,

    // Control signals
    input  wire        mem_MemtoReg,
    input  wire        mem_RegWrite,

    // Datapath values
    input  wire [31:0] mem_read_data,  // Data loaded from memory (lw)
    input  wire [31:0] mem_alu_result, // ALU result passed through
    input  wire [4:0]  mem_write_reg,  // Destination register

    // WB-stage outputs
    output reg         wb_MemtoReg,
    output reg         wb_RegWrite,
    output reg  [31:0] wb_read_data,
    output reg  [31:0] wb_alu_result,
    output reg  [4:0]  wb_write_reg
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wb_MemtoReg    <= 1'b0;
            wb_RegWrite    <= 1'b0;
            wb_read_data   <= 32'b0;
            wb_alu_result  <= 32'b0;
            wb_write_reg   <= 5'b0;
        end
        else begin
            wb_MemtoReg    <= mem_MemtoReg;
            wb_RegWrite    <= mem_RegWrite;
            wb_read_data   <= mem_read_data;
            wb_alu_result  <= mem_alu_result;
            wb_write_reg   <= mem_write_reg;
        end
    end

endmodule
