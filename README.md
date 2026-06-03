# 5-Stage Pipelined MIPS Processor
### Implemented in Verilog HDL
---
## 📁 File Structure
| File | Description |
|------|-------------|
| `mips_pipelined_cpu.v` | **Top-level module** — wires all stages together |
| `program_counter.v` | PC register with stall support (PCWrite) |
| `pc_adder.v` | 32-bit adder used for PC+4 and branch target |
| `instruction_memory.v` | 256-word ROM, preloaded test program |
| `pipeline_register_IF_ID.v` | IF→ID pipeline register (stall + flush) |
| `register_file.v` | 32×32 register file, negedge write |
| `sign_extend_16to32.v` | 16→32 bit sign extension |
| `main_control_unit.v` | Opcode decoder, generates all control signals |
| `hazard_detection_unit.v` | Load-use stall + branch flush logic |
| `pipeline_register_ID_EX.v` | ID→EX pipeline register (flush support) |
| `alu_control_unit.v` | ALUOp + funct → 4-bit ALU opcode |
| `arithmetic_logic_unit.v` | ADD, SUB, AND, OR, SLT + Zero flag |
| `forwarding_unit.v` | EX/MEM and MEM/WB forwarding muxes |
| `pipeline_register_EX_MEM.v` | EX→MEM pipeline register |
| `data_memory.v` | 256-word synchronous write / async read RAM |
| `pipeline_register_MEM_WB.v` | MEM→WB pipeline register |
| **`mips_pipelined_cpu_tb.v`** | **Self-checking testbench** |

---

## 🧠 Architecture Overview

```
        ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
   CLK  │  IF  │──▶│  ID  │──▶│  EX  │──▶│ MEM  │──▶│  WB  │
  RESET │      │   │      │   │      │   │      │   │      │
        └──────┘   └──────┘   └──────┘   └──────┘   └──────┘
          PC         RegFile    ALU       DataMem    RegWrite
          InstMem    Control    FwdUnit   BranchMux
          PC+4       SignExt    HazUnit
        ──────────────────────────────────────────────────────
                 IF/ID       ID/EX      EX/MEM    MEM/WB
               (pipeline registers between stages)
```

### Hazard Handling
| Hazard | Detection | Resolution |
|--------|-----------|------------|
| Load-use data hazard | `hazard_detection_unit` | Stall 1 cycle (PCWrite=0, IF_ID_Write=0, insert NOP) |
| EX/MEM data hazard | `forwarding_unit` | Forward EX result directly to ALU |
| MEM/WB data hazard | `forwarding_unit` | Forward WB result directly to ALU |
| Branch (beq) | `hazard_detection_unit` | Flush IF + ID/EX on taken branch |

---

## ✅ Supported ISA

| Type | Instructions |
|------|-------------|
| R-type | `add`, `sub`, `and`, `or`, `slt` |
| I-type | `addi`, `lw`, `sw`, `beq` |

