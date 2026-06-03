// ============================================================
// Module: mips_pipelined_cpu  (TOP-LEVEL)
// Description: 5-Stage Pipelined MIPS Processor
//
//  Stages:
//    IF  – Instruction Fetch
//    ID  – Instruction Decode & Register Read
//    EX  – Execute (ALU)
//    MEM – Memory Access
//    WB  – Write-Back
//
//  Hazard handling:
//    • Load-use stall   (hazard_detection_unit)
//    • EX/MEM & MEM/WB data forwarding (forwarding_unit)
//    • Branch flush     (taken beq flushes IF and ID/EX)
// ============================================================
module mips_pipelined_cpu (
    input wire clk,
    input wire reset
);

    // ============================================================
    // Wire declarations (grouped by pipeline stage)
    // ============================================================

    // ---- IF stage ----
    wire [31:0] if_pc_current;
    wire [31:0] if_pc_plus4;
    wire [31:0] if_instruction;

    // ---- IF/ID register outputs ----
    wire [31:0] id_pc_plus4;
    wire [31:0] id_instruction;

    // ---- ID stage wires ----
    wire [5:0]  id_opcode       = id_instruction[31:26];
    wire [4:0]  id_rs           = id_instruction[25:21];
    wire [4:0]  id_rt           = id_instruction[20:16];
    wire [4:0]  id_rd           = id_instruction[15:11];
    wire [5:0]  id_funct        = id_instruction[5:0];   // not used in ID directly
    wire [15:0] id_imm16        = id_instruction[15:0];

    wire [31:0] id_read_data1;
    wire [31:0] id_read_data2;
    wire [31:0] id_sign_ext_imm;

    // Main control
    wire        id_RegDst, id_ALUSrc, id_MemtoReg;
    wire        id_RegWrite, id_MemRead, id_MemWrite, id_Branch;
    wire [1:0]  id_ALUOp;

    // Hazard control
    wire        PCWrite, IF_ID_Write, ID_EX_Flush, IF_ID_Flush;

    // ---- ID/EX register outputs ----
    wire        ex_RegDst, ex_ALUSrc, ex_MemtoReg;
    wire        ex_RegWrite, ex_MemRead, ex_MemWrite, ex_Branch;
    wire [1:0]  ex_ALUOp;
    wire [31:0] ex_pc_plus4;
    wire [31:0] ex_read_data1, ex_read_data2;
    wire [31:0] ex_sign_ext_imm;
    wire [4:0]  ex_rs, ex_rt, ex_rd;

    // ---- EX stage wires ----
    wire [3:0]  ex_ALU_control;
    wire [31:0] ex_branch_target;
    wire [31:0] ex_alu_operand_a;
    wire [31:0] ex_alu_operand_b_reg;  // after forwarding, before ALUSrc mux
    wire [31:0] ex_alu_operand_b;      // final operand B to ALU
    wire [31:0] ex_alu_result;
    wire        ex_zero_flag;
    wire [4:0]  ex_write_reg;

    // Forwarding
    wire [1:0]  ForwardA, ForwardB;

    // ---- EX/MEM register outputs ----
    wire        mem_MemtoReg, mem_RegWrite;
    wire        mem_MemRead, mem_MemWrite, mem_Branch;
    wire        mem_zero_flag;
    wire [31:0] mem_branch_target;
    wire [31:0] mem_alu_result;
    wire [31:0] mem_rt_data;
    wire [4:0]  mem_write_reg;

    // ---- MEM stage wires ----
    wire [31:0] mem_read_data_out;
    wire        branch_taken;

    // ---- MEM/WB register outputs ----
    wire        wb_MemtoReg, wb_RegWrite;
    wire [31:0] wb_read_data, wb_alu_result;
    wire [4:0]  wb_write_reg;

    // ---- WB stage ----
    wire [31:0] wb_write_data;    // Data to write back to register file

    // ---- PC next mux ----
    wire [31:0] pc_next;

    // ============================================================
    // PC next mux: branch target or PC+4
    // ============================================================
    assign branch_taken = mem_Branch & mem_zero_flag;
    assign pc_next      = branch_taken ? mem_branch_target : if_pc_plus4;

    // ============================================================
    // IF STAGE
    // ============================================================
    program_counter PC (
        .clk        (clk),
        .reset      (reset),
        .PCWrite    (PCWrite),
        .pc_next    (pc_next),
        .pc_current (if_pc_current)
    );

    pc_adder PC_PLUS4_ADDER (
        .a      (if_pc_current),
        .b      (32'd4),
        .result (if_pc_plus4)
    );

    instruction_memory INSTR_MEM (
        .address     (if_pc_current),
        .instruction (if_instruction)
    );

    // ============================================================
    // IF/ID PIPELINE REGISTER
    // ============================================================
    pipeline_register_IF_ID IF_ID_REG (
        .clk            (clk),
        .reset          (reset),
        .IF_ID_Write    (IF_ID_Write),
        .IF_ID_Flush    (IF_ID_Flush),
        .if_pc_plus4    (if_pc_plus4),
        .if_instruction (if_instruction),
        .id_pc_plus4    (id_pc_plus4),
        .id_instruction (id_instruction)
    );

    // ============================================================
    // ID STAGE
    // ============================================================
    main_control_unit CTRL (
        .opcode    (id_opcode),
        .RegDst    (id_RegDst),
        .ALUSrc    (id_ALUSrc),
        .MemtoReg  (id_MemtoReg),
        .RegWrite  (id_RegWrite),
        .MemRead   (id_MemRead),
        .MemWrite  (id_MemWrite),
        .Branch    (id_Branch),
        .ALUOp     (id_ALUOp)
    );

    register_file REG_FILE (
        .clk        (clk),
        .RegWrite   (wb_RegWrite),
        .read_reg1  (id_rs),
        .read_reg2  (id_rt),
        .write_reg  (wb_write_reg),
        .write_data (wb_write_data),
        .read_data1 (id_read_data1),
        .read_data2 (id_read_data2)
    );

    sign_extend_16to32 SIGN_EXT (
        .immediate_16 (id_imm16),
        .immediate_32 (id_sign_ext_imm)
    );

    hazard_detection_unit HAZARD_UNIT (
        .id_ex_MemRead  (ex_MemRead),
        .id_ex_rt       (ex_rt),
        .if_id_rs       (id_rs),
        .if_id_rt       (id_rt),
        .branch_taken   (branch_taken),
        .PCWrite        (PCWrite),
        .IF_ID_Write    (IF_ID_Write),
        .ID_EX_Flush    (ID_EX_Flush),
        .IF_ID_Flush    (IF_ID_Flush)
    );

    // ============================================================
    // ID/EX PIPELINE REGISTER
    // ============================================================
    pipeline_register_ID_EX ID_EX_REG (
        .clk              (clk),
        .reset            (reset),
        .ID_EX_Flush      (ID_EX_Flush),
        .id_RegDst        (id_RegDst),
        .id_ALUSrc        (id_ALUSrc),
        .id_MemtoReg      (id_MemtoReg),
        .id_RegWrite      (id_RegWrite),
        .id_MemRead       (id_MemRead),
        .id_MemWrite      (id_MemWrite),
        .id_Branch        (id_Branch),
        .id_ALUOp         (id_ALUOp),
        .id_pc_plus4      (id_pc_plus4),
        .id_read_data1    (id_read_data1),
        .id_read_data2    (id_read_data2),
        .id_sign_ext_imm  (id_sign_ext_imm),
        .id_rs            (id_rs),
        .id_rt            (id_rt),
        .id_rd            (id_rd),
        .ex_RegDst        (ex_RegDst),
        .ex_ALUSrc        (ex_ALUSrc),
        .ex_MemtoReg      (ex_MemtoReg),
        .ex_RegWrite      (ex_RegWrite),
        .ex_MemRead       (ex_MemRead),
        .ex_MemWrite      (ex_MemWrite),
        .ex_Branch        (ex_Branch),
        .ex_ALUOp         (ex_ALUOp),
        .ex_pc_plus4      (ex_pc_plus4),
        .ex_read_data1    (ex_read_data1),
        .ex_read_data2    (ex_read_data2),
        .ex_sign_ext_imm  (ex_sign_ext_imm),
        .ex_rs            (ex_rs),
        .ex_rt            (ex_rt),
        .ex_rd            (ex_rd)
    );

    // ============================================================
    // EX STAGE
    // ============================================================
    alu_control_unit ALU_CTRL (
        .ALUOp       (ex_ALUOp),
        .funct       (ex_sign_ext_imm[5:0]),  // funct field from imm[5:0]
        .ALU_control (ex_ALU_control)
    );

    // Branch target address: PC+4 + (SignExt_Imm << 2)
    pc_adder BRANCH_ADDER (
        .a      (ex_pc_plus4),
        .b      ({ex_sign_ext_imm[29:0], 2'b00}),  // left-shift imm by 2
        .result (ex_branch_target)
    );

    // Forwarding mux for operand A
    assign ex_alu_operand_a = (ForwardA == 2'b10) ? mem_alu_result  :
                              (ForwardA == 2'b01) ? wb_write_data   :
                                                    ex_read_data1;

    // Forwarding mux for operand B (before ALUSrc mux)
    assign ex_alu_operand_b_reg = (ForwardB == 2'b10) ? mem_alu_result  :
                                  (ForwardB == 2'b01) ? wb_write_data   :
                                                        ex_read_data2;

    // ALUSrc mux: immediate or register
    assign ex_alu_operand_b = ex_ALUSrc ? ex_sign_ext_imm : ex_alu_operand_b_reg;

    arithmetic_logic_unit ALU (
        .operand_a   (ex_alu_operand_a),
        .operand_b   (ex_alu_operand_b),
        .ALU_control (ex_ALU_control),
        .alu_result  (ex_alu_result),
        .zero_flag   (ex_zero_flag)
    );

    // Write-register mux: rd (R-type) or rt (I-type)
    assign ex_write_reg = ex_RegDst ? ex_rd : ex_rt;

    forwarding_unit FWD_UNIT (
        .ex_rs          (ex_rs),
        .ex_rt          (ex_rt),
        .exmem_RegWrite (mem_RegWrite),
        .exmem_rd       (mem_write_reg),
        .memwb_RegWrite (wb_RegWrite),
        .memwb_rd       (wb_write_reg),
        .ForwardA       (ForwardA),
        .ForwardB       (ForwardB)
    );

    // ============================================================
    // EX/MEM PIPELINE REGISTER
    // ============================================================
    pipeline_register_EX_MEM EX_MEM_REG (
        .clk              (clk),
        .reset            (reset),
        .ex_MemtoReg      (ex_MemtoReg),
        .ex_RegWrite      (ex_RegWrite),
        .ex_MemRead       (ex_MemRead),
        .ex_MemWrite      (ex_MemWrite),
        .ex_Branch        (ex_Branch),
        .ex_zero_flag     (ex_zero_flag),
        .ex_branch_target (ex_branch_target),
        .ex_alu_result    (ex_alu_result),
        .ex_rt_data       (ex_alu_operand_b_reg),  // forwarded rt value for sw
        .ex_write_reg     (ex_write_reg),
        .mem_MemtoReg     (mem_MemtoReg),
        .mem_RegWrite     (mem_RegWrite),
        .mem_MemRead      (mem_MemRead),
        .mem_MemWrite     (mem_MemWrite),
        .mem_Branch       (mem_Branch),
        .mem_zero_flag    (mem_zero_flag),
        .mem_branch_target(mem_branch_target),
        .mem_alu_result   (mem_alu_result),
        .mem_rt_data      (mem_rt_data),
        .mem_write_reg    (mem_write_reg)
    );

    // ============================================================
    // MEM STAGE
    // ============================================================
    data_memory DATA_MEM (
        .clk        (clk),
        .MemRead    (mem_MemRead),
        .MemWrite   (mem_MemWrite),
        .address    (mem_alu_result),
        .write_data (mem_rt_data),
        .read_data  (mem_read_data_out)
    );

    // ============================================================
    // MEM/WB PIPELINE REGISTER
    // ============================================================
    pipeline_register_MEM_WB MEM_WB_REG (
        .clk           (clk),
        .reset         (reset),
        .mem_MemtoReg  (mem_MemtoReg),
        .mem_RegWrite  (mem_RegWrite),
        .mem_read_data (mem_read_data_out),
        .mem_alu_result(mem_alu_result),
        .mem_write_reg (mem_write_reg),
        .wb_MemtoReg   (wb_MemtoReg),
        .wb_RegWrite   (wb_RegWrite),
        .wb_read_data  (wb_read_data),
        .wb_alu_result (wb_alu_result),
        .wb_write_reg  (wb_write_reg)
    );

    // ============================================================
    // WB STAGE
    // ============================================================
    // MemtoReg mux: memory data or ALU result
    assign wb_write_data = wb_MemtoReg ? wb_read_data : wb_alu_result;

endmodule
