# LEG Processor — Instruction Set Architecture

## Overview

The LEG processor is an 8-bit microcontroller with:
- 6 general-purpose 8-bit registers (R0–R5)
- 256-byte data RAM
- 256-deep × 8-bit hardware stack
- 8-bit ALU with arithmetic, logic, shift, and comparison operations
- 8-bit I/O input and output ports
- 32-bit fixed-length instructions (4 bytes)

## Register Map

| Address | Name  | Description                    |
|---------|-------|--------------------------------|
| 0       | R0    | General-purpose / accumulator  |
| 1       | R1    | General-purpose                |
| 2       | R2    | General-purpose                |
| 3       | R3    | General-purpose                |
| 4       | R4    | General-purpose                |
| 5       | R5    | General-purpose                |
| 6       | PC    | Program counter (read-only)    |
| 7       | IN    | External input port (read-only)|

PC is read-only via general register addressing. Output port is separately addressed.

## Instruction Format

All instructions are **32 bits (4 bytes)**, fetched as 4 consecutive bytes from program memory:

```
Byte 0 (bits 31:24): Opcode / control byte
Byte 1 (bits 23:16): Operand A — register select or immediate value
Byte 2 (bits 15:8):  Operand B — register select or immediate value
Byte 3 (bits 7:0):   Extended operation / ALU select
```

PC increments by 4 after each instruction (word-aligned fetch).

## Opcode Map

### ALU Operations (Byte 0 = 0x00–0x07)

Format: `{opcode, dst_reg, src_reg_a, alu_op_byte}`

| Byte 0 | Mnemonic | Operation            | Description              |
|--------|----------|----------------------|--------------------------|
| 0x00   | ADD      | Rd = Ra + Rb         | Add two registers        |
| 0x01   | SUB      | Rd = Ra - Rb         | Subtract two registers   |
| 0x02   | AND      | Rd = Ra & Rb         | Bitwise AND              |
| 0x03   | OR       | Rd = Ra \| Rb        | Bitwise OR               |
| 0x04   | NOT      | Rd = ~Ra             | Bitwise NOT (Rb ignored) |
| 0x05   | XOR      | Rd = Ra ^ Rb         | Bitwise XOR              |
| 0x06   | SHL      | Rd = Ra << Rb        | Logical shift left       |
| 0x07   | SHR      | Rd = Ra >> Rb        | Logical shift right      |

Byte 1: Source register Ra (bits [2:0], values 0–5 for R0–R5)
Byte 2: Source register Rb (bits [2:0], values 0–5 for R0–R5)
Byte 3: Destination register Rd (bits [2:0], values 0–5 for R0–R5)
         Bit 3: Update flags (1 = update)

Flags: Zero (result == 0), Carry (for ADD/SUB overflow)

### ALU Immediate Operations (Byte 0 = 0x08–0x0F)

Format: `{opcode, imm_value, dst_reg, alu_sel}`

| Byte 0 | Mnemonic | Operation              |
|--------|----------|------------------------|
| 0x08   | ADDI     | Rd = Rd + imm          |
| 0x09   | SUBI     | Rd = Rd - imm          |
| 0x0A   | ANDI     | Rd = Rd & imm          |
| 0x0B   | ORI      | Rd = Rd \| imm         |
| 0x0C   | XORI     | Rd = Rd ^ imm          |
| 0x0D   | SHLI     | Rd = Rd << imm         |
| 0x0E   | SHRI     | Rd = Rd >> imm         |
| 0x0F   | CMPI     | Compare Rd with imm    |

Byte 1: 8-bit immediate value
Byte 2: Destination/source register Rd (bits [2:0])
Byte 3: Reserved

### Data Transfer (Byte 0 = 0x10–0x1F)

| Byte 0 | Mnemonic | Operation              | Description           |
|--------|----------|------------------------|-----------------------|
| 0x10   | LD       | Rd = [addr]            | Load from RAM         |
| 0x11   | ST       | [addr] = Rs            | Store to RAM          |
| 0x12   | LDI      | Rd = imm               | Load immediate        |
| 0x13   | MOV      | Rd = Rs                | Register-to-register  |

For LD (0x10):
  Byte 1: Address low byte
  Byte 2: Destination register Rd (bits [2:0])
  Byte 3: Address high byte (bits [2:0] for 8-bit addressing, valid range 0x00)

For ST (0x11):
  Byte 1: Address low byte
  Byte 2: Source register Rs (bits [2:0])
  Byte 3: Reserved

For LDI (0x12):
  Byte 1: 8-bit immediate value
  Byte 2: Destination register Rd (bits [2:0])
  Byte 3: Reserved

For MOV (0x13):
  Byte 1: Source register Rs (bits [2:0])
  Byte 2: Destination register Rd (bits [2:0])
  Byte 3: Reserved

### Stack Operations (Byte 0 = 0x20–0x2F)

| Byte 0 | Mnemonic | Operation              | Description           |
|--------|----------|------------------------|-----------------------|
| 0x20   | PUSH     | [SP++] = Rs            | Push register to stack|
| 0x21   | POP      | Rd = [--SP]            | Pop from stack to reg |

For PUSH (0x20):
  Byte 1: Source register Rs (bits [2:0])
  Byte 2–3: Reserved

For POP (0x21):
  Byte 1: Destination register Rd (bits [2:0])
  Byte 2–3: Reserved

### Control Flow (Byte 0 = 0x30–0x3F)

| Byte 0 | Mnemonic | Operation              | Description              |
|--------|----------|------------------------|--------------------------|
| 0x30   | JMP      | PC = addr              | Unconditional jump       |
| 0x31   | JZ       | if (Z) PC = addr       | Jump if zero flag set    |
| 0x32   | JNZ      | if (!Z) PC = addr      | Jump if zero flag clear  |
| 0x33   | JC       | if (C) PC = addr       | Jump if carry flag set   |
| 0x34   | CALL     | PUSH(PC+4); PC = addr  | Subroutine call          |
| 0x35   | RET      | PC = POP()             | Return from subroutine   |
| 0x36   | HALT     | Halt execution          | Stop processor           |

For JMP/JZ/JNZ/JC/CALL (0x30–0x34):
  Byte 1: Target address low byte
  Byte 2: Reserved
  Byte 3: Target address high byte (bits [2:0])

For RET (0x35):
  Byte 1–3: Reserved

### I/O Operations (Byte 0 = 0x50–0x5F)

| Byte 0 | Mnemonic | Operation              | Description              |
|--------|----------|------------------------|--------------------------|
| 0x50   | IN       | Rd = INPUT             | Read from input port     |
| 0x51   | OUT      | OUTPUT = Rs            | Write to output port     |
| 0x52   | OUTI     | OUTPUT = imm           | Write immediate to output|

For IN (0x50):
  Byte 1: Destination register Rd (bits [2:0])
  Byte 2–3: Reserved

For OUT (0x51):
  Byte 1: Source register Rs (bits [2:0])
  Byte 2–3: Reserved

For OUTI (0x52):
  Byte 1: 8-bit immediate value
  Byte 2–3: Reserved

## Opcode Quick Reference

```
0x00 ADD    Rd, Ra, Rb    ALU: Rd = Ra + Rb
0x01 SUB    Rd, Ra, Rb    ALU: Rd = Ra - Rb
0x02 AND    Rd, Ra, Rb    ALU: Rd = Ra & Rb
0x03 OR     Rd, Ra, Rb    ALU: Rd = Ra | Rb
0x04 NOT    Rd, Ra        ALU: Rd = ~Ra
0x05 XOR    Rd, Ra, Rb    ALU: Rd = Ra ^ Rb
0x06 SHL    Rd, Ra, Rb    ALU: Rd = Ra << Rb
0x07 SHR    Rd, Ra, Rb    ALU: Rd = Ra >> Rb
0x08 ADDI   Rd, imm       ALU: Rd = Rd + imm
0x09 SUBI   Rd, imm       ALU: Rd = Rd - imm
0x0A ANDI   Rd, imm       ALU: Rd = Rd & imm
0x0B ORI    Rd, imm       ALU: Rd = Rd | imm
0x0C XORI   Rd, imm       ALU: Rd = Rd ^ imm
0x0D SHLI   Rd, imm       ALU: Rd = Rd << imm
0x0E SHRI   Rd, imm       ALU: Rd = Rd >> imm
0x0F CMPI   Rd, imm       FLAGS = Rd - imm
0x10 LD     Rd, addr      Rd = MEM[addr]
0x11 ST     addr, Rs      MEM[addr] = Rs
0x12 LDI    Rd, imm       Rd = imm
0x13 MOV    Rd, Rs        Rd = Rs
0x20 PUSH   Rs            Stack[SP++] = Rs
0x21 POP    Rd            Rd = Stack[--SP]
0x30 JMP    addr          PC = addr
0x31 JZ     addr          if (Z) PC = addr
0x32 JNZ    addr          if (!Z) PC = addr
0x33 JC     addr          if (C) PC = addr
0x34 CALL   addr          PUSH(PC+4); PC = addr
0x35 RET                  PC = POP()
0x36 HALT                 Stop
0x50 IN     Rd            Rd = INPUT_PORT
0x51 OUT    Rs            OUTPUT_PORT = Rs
0x52 OUTI   imm           OUTPUT_PORT = imm
```

## Comparison with Original Encoding

The original LEG processor used an implicit ISA where control bits were
directly extracted from instruction bytes via Splitter8 modules and routed
to individual muxes and enable signals. This refactored ISA preserves all
hardware capabilities while providing a clean, documented encoding.

### Hardware Capability Mapping

| Capability              | Original (wire-level)              | Refactored (opcode)      |
|-------------------------|------------------------------------|--------------------------|
| ALU ADD                 | wire_31=1, wire_12[0]=0           | ADD  0x00               |
| ALU SUB                 | wire_31=1, wire_12[0]=1           | SUB  0x01               |
| ALU AND                 | wire_27=1, wire_12[0]=0           | AND  0x02               |
| ALU OR                  | wire_27=1, wire_12[0]=1           | OR   0x03               |
| ALU NOT                 | wire_14=1, wire_12[0]=0           | NOT  0x04               |
| ALU XOR                 | wire_14=1, wire_12[0]=1           | XOR  0x05               |
| ALU SHL                 | wire_15=1, wire_12[0]=0           | SHL  0x06               |
| ALU SHR                 | wire_15=1, wire_12[0]=1           | SHR  0x07               |
| Compare (LessU)         | wire_11=1 → wire_2                | Flag output             |
| Compare (Equal)         | wire_12[0]=1 → wire_10            | Flag output             |
| Register read           | Decoder3_5, Switch cascade        | Byte 1[2:0]             |
| Register write          | Decoder3_6, Decoder3_21           | Byte 2[2:0] or Byte 3[2:0]|
| RAM read                | wire_36=1, wire_61→wire_83        | LD   0x10               |
| RAM write               | wire_36=0, wire_25→wire_53        | ST   0x11               |
| Stack PUSH              | ZXE6ZXA0ZX88.PUSH=1               | PUSH 0x20               |
| Stack POP               | ZXE6ZXA0ZX88.POP=1                | POP  0x21               |
| PC jump                 | wire_27 (Counter8 save)           | JMP  0x30               |
| I/O output              | LevelOutputArch_0 (wire_19)       | OUT  0x51               |
| I/O input               | LevelInputArch_2 (wire_2)         | IN   0x50               |

## Flag Register

| Bit | Name | Description              |
|-----|------|--------------------------|
| 0   | Z    | Zero flag (result == 0)  |
| 1   | C    | Carry flag (ADD/SUB)     |

Flags are updated on ALU instructions when the flag-update bit is set.
Flags are read by conditional jump instructions.
