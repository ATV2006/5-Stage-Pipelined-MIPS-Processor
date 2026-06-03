// ============================================================
// Module: mips_pipelined_cpu_tb  (TESTBENCH)
// Description: Self-checking testbench for the 5-Stage
//              Pipelined MIPS Processor.
//
//  Test program executed (preloaded in instruction_memory):
//    addi $t0, $zero, 5     ; $t0 = 5
//    addi $t1, $zero, 3     ; $t1 = 3
//    add  $t2, $t0, $t1     ; $t2 = 8   (forwarding: EX/MEM → EX)
//    sub  $t3, $t0, $t1     ; $t3 = 2   (forwarding: MEM/WB → EX)
//    sw   $t2, 0($zero)     ; Mem[0] = 8
//    lw   $t4, 0($zero)     ; $t4 = 8   (load-use stall expected)
//    beq  $t3, $t1, +2      ; not taken ($t3=2 ≠ $t1=3)
//    addi $t5, $zero, 10    ; $t5 = 10
//    addi $t6, $zero, 20    ; $t6 = 20
//    add  $t7, $t5, $t6     ; $t7 = 30
//
//  Expected register results (MIPS ABI):
//    $t0 ($8)  = 5
//    $t1 ($9)  = 3
//    $t2 ($10) = 8
//    $t3 ($11) = 2
//    $t4 ($12) = 8  (loaded from memory)
//    $t5 ($13) = 10
//    $t6 ($14) = 20
//    $t7 ($15) = 30
//
//  Clock period: 10 ns
// ============================================================
`timescale 1ns / 1ps

module mips_pipelined_cpu_tb;

    // ---- DUT signals ----
    reg  clk;
    reg  reset;

    // ---- Instantiate DUT ----
    mips_pipelined_cpu DUT (
        .clk   (clk),
        .reset (reset)
    );

    // ---- Clock generation: 10 ns period ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Task: check register value ----
    task check_register;
        input [4:0]  reg_num;
        input [31:0] expected;
        input [63:0] description;  // up to 8 chars
        reg   [31:0] actual;
        begin
            actual = DUT.REG_FILE.registers[reg_num];
            if (actual === expected)
                $display("  PASS  R%0d (%s) = %0d", reg_num, description, actual);
            else
                $display("  FAIL  R%0d (%s) = %0d (expected %0d)",
                         reg_num, description, actual, expected);
        end
    endtask

    // ---- Simulation ----
    integer cycle;
    initial begin
        // ---- Setup waveform dump (Vivado / ModelSim compatible) ----
        $dumpfile("mips_pipeline_waveform.vcd");
        $dumpvars(0, mips_pipelined_cpu_tb);

        // ---- Reset ----
        reset = 1;
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;

        $display("==============================================");
        $display("  5-Stage Pipelined MIPS Processor Testbench ");
        $display("==============================================");
        $display("  Reset released. Running program...");
        $display("");

        // ---- Run enough cycles for the 10-instruction program
        //      (10 instr × ~5 cycles + pipeline drain) ----
        for (cycle = 0; cycle < 35; cycle = cycle + 1) begin
            @(posedge clk); #1;
            $display("  Cycle %2d | PC = 0x%08h | IF_instr = 0x%08h | PC+4 instr = 0x%08h",
                     cycle,
                     DUT.if_pc_current,
                     DUT.id_instruction,
                     DUT.if_instruction);
        end

        // ---- Allow WB to settle ----
        @(posedge clk); #1;
        @(posedge clk); #1;

        // ---- Check results ----
        $display("");
        $display("---- Register File Check ----");
        check_register(8,  32'd5,  "t0     ");
        check_register(9,  32'd3,  "t1     ");
        check_register(10, 32'd8,  "t2     ");
        check_register(11, 32'd2,  "t3     ");
        check_register(12, 32'd8,  "t4(lw) ");
        check_register(13, 32'd10, "t5     ");
        check_register(14, 32'd20, "t6     ");
        check_register(15, 32'd30, "t7     ");

        $display("");
        $display("---- Data Memory Check ----");
        if (DUT.DATA_MEM.mem[0] === 32'd8)
            $display("  PASS  Mem[0] = %0d", DUT.DATA_MEM.mem[0]);
        else
            $display("  FAIL  Mem[0] = %0d (expected 8)", DUT.DATA_MEM.mem[0]);

        $display("");
        $display("  Simulation complete.");
        $display("==============================================");
        $finish;
    end

    // ---- Timeout watchdog ----
    initial begin
        #2000;
        $display("TIMEOUT: simulation ran too long.");
        $finish;
    end

endmodule