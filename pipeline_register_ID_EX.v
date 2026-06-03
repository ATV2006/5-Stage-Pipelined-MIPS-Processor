// ============================================================
// Module: pipeline_register_ID_EX
// Description: Latches all control signals and datapath values
//              produced in the ID stage for use in the EX stage.
//              Flush support inserts a NOP bubble (all 0s).
// Stage boundary: ID → EX
// ============================================================
module pipeline_register_ID_EX (
    input  wire        clk,
    input  wire        reset,
    input  wire        ID_EX_Flush,    // 1 = insert NOP bubble

    // ------ Control signals from ID ------
    input  wire        id_RegDst,
    input  wire        id_ALUSrc,
    input  wire        id_MemtoReg,
    input  wire        id_RegWrite,
    input  wire        id_MemRead,
    input  wire        id_MemWrite,
    input  wire        id_Branch,
    input  wire [1:0]  id_ALUOp,

    // ------ Datapath values from ID ------
    input  wire [31:0] id_pc_plus4,
    input  wire [31:0] id_read_data1,  // Register rs value
    input  wire [31:0] id_read_data2,  // Register rt value
    input  wire [31:0] id_sign_ext_imm,
    input  wire [4:0]  id_rs,
    input  wire [4:0]  id_rt,
    input  wire [4:0]  id_rd,

    // ------ EX-stage outputs ------
    output reg         ex_RegDst,
    output reg         ex_ALUSrc,
    output reg         ex_MemtoReg,
    output reg         ex_RegWrite,
    output reg         ex_MemRead,
    output reg         ex_MemWrite,
    output reg         ex_Branch,
    output reg  [1:0]  ex_ALUOp,

    output reg  [31:0] ex_pc_plus4,
    output reg  [31:0] ex_read_data1,
    output reg  [31:0] ex_read_data2,
    output reg  [31:0] ex_sign_ext_imm,
    output reg  [4:0]  ex_rs,
    output reg  [4:0]  ex_rt,
    output reg  [4:0]  ex_rd
);

    always @(posedge clk or posedge reset) begin
        if (reset || ID_EX_Flush) begin
            ex_RegDst      <= 1'b0;
            ex_ALUSrc      <= 1'b0;
            ex_MemtoReg    <= 1'b0;
            ex_RegWrite    <= 1'b0;
            ex_MemRead     <= 1'b0;
            ex_MemWrite    <= 1'b0;
            ex_Branch      <= 1'b0;
            ex_ALUOp       <= 2'b0;
            ex_pc_plus4    <= 32'b0;
            ex_read_data1  <= 32'b0;
            ex_read_data2  <= 32'b0;
            ex_sign_ext_imm<= 32'b0;
            ex_rs          <= 5'b0;
            ex_rt          <= 5'b0;
            ex_rd          <= 5'b0;
        end
        else begin
            ex_RegDst      <= id_RegDst;
            ex_ALUSrc      <= id_ALUSrc;
            ex_MemtoReg    <= id_MemtoReg;
            ex_RegWrite    <= id_RegWrite;
            ex_MemRead     <= id_MemRead;
            ex_MemWrite    <= id_MemWrite;
            ex_Branch      <= id_Branch;
            ex_ALUOp       <= id_ALUOp;
            ex_pc_plus4    <= id_pc_plus4;
            ex_read_data1  <= id_read_data1;
            ex_read_data2  <= id_read_data2;
            ex_sign_ext_imm<= id_sign_ext_imm;
            ex_rs          <= id_rs;
            ex_rt          <= id_rt;
            ex_rd          <= id_rd;
        end
    end

endmodule
