// =============================================================================
// Module     : leg_decoder
// Description: Instruction decoder for LEG processor
//              Decodes 32-bit instructions into control signals
// =============================================================================
// Instruction format (32 bits = 4 bytes):
//   Byte 0 (i_inst[7:0]):   Opcode
//   Byte 1 (i_inst[15:8]):  Operand A (register / immediate low)
//   Byte 2 (i_inst[23:16]): Operand B (register / immediate high)
//   Byte 3 (i_inst[31:24]): Extended (ALU op select / flags)
// Ports:
//   clk           - System clock
//   rst_n         - Active-low synchronous reset
//   i_inst        - 32-bit instruction word
//   i_flag_z      - Zero flag from ALU
//   i_flag_c      - Carry flag from ALU
//   o_alu_op      - ALU operation select (3 bits)
//   o_reg_raddr_a - Register read address A (3 bits)
//   o_reg_raddr_b - Register read address B (3 bits)
//   o_reg_waddr   - Register write address (3 bits)
//   o_reg_we      - Register write enable
//   o_ram_we      - RAM write enable
//   o_ram_re      - RAM read enable
//   o_stack_push  - Stack push enable
//   o_stack_pop   - Stack pop enable
//   o_pc_jump     - PC jump enable
//   o_pc_jump_cond- PC conditional jump (uses flags)
//   o_imm_sel     - Select immediate for ALU operand B
//   o_result_sel  - Write-back source: 00=ALU, 01=RAM, 10=Stack, 11=Input/Imm
//   o_io_we       - I/O write enable
//   o_flag_update - Update ALU flags
//   o_halt        - Halt processor
// =============================================================================

module leg_decoder (
    input  wire         clk,
    input  wire         rst_n,
    input  wire [31:0]  i_inst,
    input  wire         i_flag_z,
    input  wire         i_flag_c,

    output reg  [2:0]   o_alu_op,
    output reg  [2:0]   o_reg_raddr_a,
    output reg  [2:0]   o_reg_raddr_b,
    output reg  [2:0]   o_reg_waddr,
    output reg          o_reg_we,
    output reg          o_ram_we,
    output reg          o_ram_re,
    output reg          o_stack_push,
    output reg          o_stack_pop,
    output reg          o_pc_jump,
    output reg          o_pc_jump_cond,
    output reg          o_imm_sel,
    output reg  [1:0]   o_result_sel,
    output reg          o_io_we,
    output reg          o_flag_update,
    output reg          o_halt
);

    // Opcode definitions
    localparam OP_ADD  = 8'h00;
    localparam OP_SUB  = 8'h01;
    localparam OP_AND  = 8'h02;
    localparam OP_OR   = 8'h03;
    localparam OP_NOT  = 8'h04;
    localparam OP_XOR  = 8'h05;
    localparam OP_SHL  = 8'h06;
    localparam OP_SHR  = 8'h07;
    localparam OP_ADDI = 8'h08;
    localparam OP_SUBI = 8'h09;
    localparam OP_ANDI = 8'h0A;
    localparam OP_ORI  = 8'h0B;
    localparam OP_XORI = 8'h0C;
    localparam OP_SHLI = 8'h0D;
    localparam OP_SHRI = 8'h0E;
    localparam OP_CMPI = 8'h0F;
    localparam OP_LD   = 8'h10;
    localparam OP_ST   = 8'h11;
    localparam OP_LDI  = 8'h12;
    localparam OP_MOV  = 8'h13;
    localparam OP_PUSH = 8'h20;
    localparam OP_POP  = 8'h21;
    localparam OP_JMP  = 8'h30;
    localparam OP_JZ   = 8'h31;
    localparam OP_JNZ  = 8'h32;
    localparam OP_JC   = 8'h33;
    localparam OP_CALL = 8'h34;
    localparam OP_RET  = 8'h35;
    localparam OP_HALT = 8'h36;
    localparam OP_IN   = 8'h50;
    localparam OP_OUT  = 8'h51;
    localparam OP_OUTI = 8'h52;

    // Result source encoding
    localparam RES_ALU   = 2'b00;
    localparam RES_RAM   = 2'b01;
    localparam RES_STACK = 2'b10;
    localparam RES_IMM   = 2'b11;

    // ALU op encoding
    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_NOT = 3'b100;
    localparam ALU_XOR = 3'b101;
    localparam ALU_SHL = 3'b110;
    localparam ALU_SHR = 3'b111;

    wire [7:0] opcode;
    wire [7:0] byte1, byte2, byte3;
    assign opcode = i_inst[7:0];
    assign byte1  = i_inst[15:8];
    assign byte2  = i_inst[23:16];
    assign byte3  = i_inst[31:24];

    always @(*) begin
        // Defaults: NOP behavior
        o_alu_op       = ALU_ADD;
        o_reg_raddr_a  = 3'd0;
        o_reg_raddr_b  = 3'd0;
        o_reg_waddr    = 3'd0;
        o_reg_we       = 1'b0;
        o_ram_we       = 1'b0;
        o_ram_re       = 1'b0;
        o_stack_push   = 1'b0;
        o_stack_pop    = 1'b0;
        o_pc_jump      = 1'b0;
        o_pc_jump_cond = 1'b0;
        o_imm_sel      = 1'b0;
        o_result_sel   = RES_ALU;
        o_io_we        = 1'b0;
        o_flag_update  = 1'b0;
        o_halt         = 1'b0;

        case (opcode)
            // ---- ALU Register-Register Operations ----
            OP_ADD: begin
                o_alu_op      = ALU_ADD;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_SUB: begin
                o_alu_op      = ALU_SUB;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_AND: begin
                o_alu_op      = ALU_AND;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_OR: begin
                o_alu_op      = ALU_OR;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_NOT: begin
                o_alu_op      = ALU_NOT;
                o_reg_raddr_a = byte1[2:0];
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_XOR: begin
                o_alu_op      = ALU_XOR;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_SHL: begin
                o_alu_op      = ALU_SHL;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end
            OP_SHR: begin
                o_alu_op      = ALU_SHR;
                o_reg_raddr_a = byte1[2:0];
                o_reg_raddr_b = byte2[2:0];
                o_reg_waddr   = byte3[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = byte3[3];
            end

            // ---- ALU Immediate Operations ----
            OP_ADDI: begin
                o_alu_op      = ALU_ADD;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_SUBI: begin
                o_alu_op      = ALU_SUB;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_ANDI: begin
                o_alu_op      = ALU_AND;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_ORI: begin
                o_alu_op      = ALU_OR;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_XORI: begin
                o_alu_op      = ALU_XOR;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_SHLI: begin
                o_alu_op      = ALU_SHL;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_SHRI: begin
                o_alu_op      = ALU_SHR;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_flag_update = 1'b1;
            end
            OP_CMPI: begin
                o_alu_op      = ALU_SUB;
                o_reg_raddr_a = byte2[2:0];
                o_imm_sel     = 1'b1;
                o_flag_update = 1'b1;
            end

            // ---- Data Transfer ----
            OP_LD: begin
                o_ram_re      = 1'b1;
                o_reg_raddr_a = byte1[2:0];
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_result_sel  = RES_RAM;
            end
            OP_ST: begin
                o_ram_we      = 1'b1;
                o_reg_raddr_a = byte2[2:0];
            end
            OP_LDI: begin
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_result_sel  = RES_IMM;
            end
            OP_MOV: begin
                o_reg_raddr_a = byte1[2:0];
                o_reg_waddr   = byte2[2:0];
                o_reg_we      = 1'b1;
                o_result_sel  = RES_ALU;
                o_alu_op      = ALU_OR;
                o_reg_raddr_b = byte1[2:0];
            end

            // ---- Stack Operations ----
            OP_PUSH: begin
                o_stack_push  = 1'b1;
                o_reg_raddr_a = byte1[2:0];
            end
            OP_POP: begin
                o_stack_pop   = 1'b1;
                o_reg_waddr   = byte1[2:0];
                o_reg_we      = 1'b1;
                o_result_sel  = RES_STACK;
            end

            // ---- Control Flow ----
            OP_JMP: begin
                o_pc_jump     = 1'b1;
            end
            OP_JZ: begin
                o_pc_jump      = i_flag_z;
                o_pc_jump_cond = 1'b1;
            end
            OP_JNZ: begin
                o_pc_jump      = ~i_flag_z;
                o_pc_jump_cond = 1'b1;
            end
            OP_JC: begin
                o_pc_jump      = i_flag_c;
                o_pc_jump_cond = 1'b1;
            end
            OP_CALL: begin
                o_stack_push  = 1'b1;
                o_pc_jump     = 1'b1;
            end
            OP_RET: begin
                o_stack_pop   = 1'b1;
                o_pc_jump     = 1'b1;
                o_result_sel  = RES_STACK;
            end
            OP_HALT: begin
                o_halt        = 1'b1;
            end

            // ---- I/O Operations ----
            OP_IN: begin
                o_reg_waddr   = byte1[2:0];
                o_reg_we      = 1'b1;
                o_result_sel  = RES_IMM;
                o_reg_raddr_a = 3'd7;
            end
            OP_OUT: begin
                o_io_we       = 1'b1;
                o_reg_raddr_a = byte1[2:0];
            end
            OP_OUTI: begin
                o_io_we       = 1'b1;
                o_imm_sel     = 1'b1;
            end

            default: begin
                // NOP
            end
        endcase
    end

endmodule
