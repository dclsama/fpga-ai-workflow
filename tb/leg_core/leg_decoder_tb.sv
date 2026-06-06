// =============================================================================
// Testbench  : leg_decoder_tb
// Module DUT : leg_decoder
// Description: Self-checking testbench for LEG instruction decoder
// =============================================================================

`timescale 1ns / 1ps

module leg_decoder_tb;

    parameter CLK_PERIOD = 10;

    reg         clk;
    reg         rst_n;
    reg  [31:0] i_inst;
    reg         i_flag_z;
    reg         i_flag_c;
    wire [2:0]  o_alu_op;
    wire [2:0]  o_reg_raddr_a;
    wire [2:0]  o_reg_raddr_b;
    wire [2:0]  o_reg_waddr;
    wire        o_reg_we;
    wire        o_ram_we;
    wire        o_ram_re;
    wire        o_stack_push;
    wire        o_stack_pop;
    wire        o_pc_jump;
    wire        o_pc_jump_cond;
    wire        o_imm_sel;
    wire [1:0]  o_result_sel;
    wire        o_io_we;
    wire        o_flag_update;
    wire        o_halt;

    leg_decoder uut (
        .clk          (clk),
        .rst_n        (rst_n),
        .i_inst       (i_inst),
        .i_flag_z     (i_flag_z),
        .i_flag_c     (i_flag_c),
        .o_alu_op     (o_alu_op),
        .o_reg_raddr_a(o_reg_raddr_a),
        .o_reg_raddr_b(o_reg_raddr_b),
        .o_reg_waddr  (o_reg_waddr),
        .o_reg_we     (o_reg_we),
        .o_ram_we     (o_ram_we),
        .o_ram_re     (o_ram_re),
        .o_stack_push (o_stack_push),
        .o_stack_pop  (o_stack_pop),
        .o_pc_jump    (o_pc_jump),
        .o_pc_jump_cond(o_pc_jump_cond),
        .o_imm_sel    (o_imm_sel),
        .o_result_sel (o_result_sel),
        .o_io_we      (o_io_we),
        .o_flag_update(o_flag_update),
        .o_halt       (o_halt)
    );

    initial begin
        $dumpfile("leg_decoder_tb.vcd");
        $dumpvars(0, leg_decoder_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    integer test_count, pass_count;

    // Instruction format: {byte3[7:0], byte2[7:0], byte1[7:0], opcode[7:0]}
    //   byte1 = i_inst[15:8]
    //   byte2 = i_inst[23:16]
    //   byte3 = i_inst[31:24]

    task check_decode;
        input [31:0] inst;
        input        fz, fc;
        input [2:0]  exp_alu;
        input [2:0]  exp_ra, exp_rb, exp_wa;
        input        exp_we, exp_rwe, exp_rre;
        input        exp_push, exp_pop, exp_jmp, exp_jcnd;
        input        exp_imm, exp_io, exp_fup, exp_halt;
        input [1:0]  exp_rsel;
        begin
            i_inst = inst; i_flag_z = fz; i_flag_c = fc;
            #5;
            if (o_alu_op === exp_alu &&
                o_reg_raddr_a === exp_ra &&
                o_reg_raddr_b === exp_rb &&
                o_reg_waddr === exp_wa &&
                o_reg_we === exp_we &&
                o_ram_we === exp_rwe &&
                o_ram_re === exp_rre &&
                o_stack_push === exp_push &&
                o_stack_pop === exp_pop &&
                o_pc_jump === exp_jmp &&
                o_pc_jump_cond === exp_jcnd &&
                o_imm_sel === exp_imm &&
                o_io_we === exp_io &&
                o_flag_update === exp_fup &&
                o_halt === exp_halt &&
                o_result_sel === exp_rsel) begin
                $display("  PASS: op=%02h", inst[7:0]);
                pass_count = pass_count + 1;
            end else begin
                $error("  FAIL: op=%02h inst=%08h", inst[7:0], inst);
                $display("    exp: alu=%0d ra=%0d rb=%0d wa=%0d we=%b rwe=%b rre=%b push=%b pop=%b jmp=%b jc=%b imm=%b io=%b fup=%b halt=%b rsel=%0d",
                    exp_alu, exp_ra, exp_rb, exp_wa, exp_we, exp_rwe, exp_rre,
                    exp_push, exp_pop, exp_jmp, exp_jcnd, exp_imm, exp_io, exp_fup, exp_halt, exp_rsel);
                $display("    got: alu=%0d ra=%0d rb=%0d wa=%0d we=%b rwe=%b rre=%b push=%b pop=%b jmp=%b jc=%b imm=%b io=%b fup=%b halt=%b rsel=%0d",
                    o_alu_op, o_reg_raddr_a, o_reg_raddr_b, o_reg_waddr, o_reg_we, o_ram_we, o_ram_re,
                    o_stack_push, o_stack_pop, o_pc_jump, o_pc_jump_cond, o_imm_sel, o_io_we, o_flag_update, o_halt, o_result_sel);
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        test_count = 0; pass_count = 0;
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;
        repeat(1) @(posedge clk);

        // === ALU Reg-Reg ===
        // Format: {byte3={flag[3],dst[2:0]}, byte2=srcB, byte1=srcA, op}
        // ADD R1,R2 -> R0  (srcA=1, srcB=2, dst=0)
        $display("[DECODER] ALU Reg-Reg");
        check_decode({8'h00, 8'd2, 8'd1, 8'h00}, 0,0, 0, 1,2,0, 1,0,0, 0,0,0,0, 0,0,0,0, 0);
        // ADD R4,R5 -> R3 with flags (srcA=4, srcB=5, dst=3, fup=1)
        check_decode({8'h0B, 8'd5, 8'd4, 8'h00}, 0,0, 0, 4,5,3, 1,0,0, 0,0,0,0, 0,0,1,0, 0);
        // SUB R1,R0 -> R2 (srcA=1, srcB=0, dst=2)
        check_decode({8'h02, 8'd0, 8'd1, 8'h01}, 0,0, 1, 1,0,2, 1,0,0, 0,0,0,0, 0,0,0,0, 0);
        // AND R4,R5 -> R3 (srcA=4, srcB=5, dst=3)
        check_decode({8'h03, 8'd5, 8'd4, 8'h02}, 0,0, 2, 4,5,3, 1,0,0, 0,0,0,0, 0,0,0,0, 0);
        // OR R0,R0 -> R0
        check_decode({8'h00, 8'd0, 8'd0, 8'h03}, 0,0, 3, 0,0,0, 1,0,0, 0,0,0,0, 0,0,0,0, 0);
        // NOT R3 -> R5 (srcA=3, dst=5)
        check_decode({8'h00, 8'd5, 8'd3, 8'h04}, 0,0, 4, 3,0,5, 1,0,0, 0,0,0,0, 0,0,0,0, 0);

        // === ALU Immediate ===
        // Format: {byte3, byte2={dst/src}, byte1=imm, op}
        // ADDI R0, 0x42  (dst/src=R0, imm=0x42)
        $display("[DECODER] ALU Imm");
        check_decode({8'h00, 8'd0, 8'h42, 8'h08}, 0,0, 0, 0,0,0, 1,0,0, 0,0,0,0, 1,0,1,0, 0);
        // ORI R3, 0x0F   (dst/src=R3, imm=0x0F)
        check_decode({8'h00, 8'd3, 8'h0F, 8'h0B}, 0,0, 3, 3,0,3, 1,0,0, 0,0,0,0, 1,0,1,0, 0);

        // === Data Transfer ===
        // LD R0, [R1]  — byte2=dst=0, byte1=addr_reg=1
        $display("[DECODER] Data Transfer");
        check_decode({8'h00, 8'd0, 8'd1, 8'h10}, 0,0, 0, 1,0,0, 1,0,1, 0,0,0,0, 0,0,0,0, 1);
        // ST [R1], R0  — byte2=src=0, byte1=addr=1
        check_decode({8'h00, 8'd0, 8'd1, 8'h11}, 0,0, 0, 0,0,0, 0,1,0, 0,0,0,0, 0,0,0,0, 0);
        // LDI R5, 0xAB — byte2=dst=5, byte1=imm=0xAB
        check_decode({8'h00, 8'd5, 8'hAB, 8'h12}, 0,0, 0, 0,0,5, 1,0,0, 0,0,0,0, 0,0,0,0, 3);
        // MOV R1 -> R3 — byte2=dst=3, byte1=src=1
        check_decode({8'h00, 8'd3, 8'd1, 8'h13}, 0,0, 3, 1,1,3, 1,0,0, 0,0,0,0, 0,0,0,0, 0);

        // === Stack ===
        // PUSH R0 — byte1=src=0
        $display("[DECODER] Stack");
        check_decode({8'h00, 8'd0, 8'd0, 8'h20}, 0,0, 0, 0,0,0, 0,0,0, 1,0,0,0, 0,0,0,0, 0);
        // POP R3  — byte1=dst=3
        check_decode({8'h00, 8'd0, 8'd3, 8'h21}, 0,0, 0, 0,0,3, 1,0,0, 0,1,0,0, 0,0,0,0, 2);

        // === Control Flow ===
        // JMP 0x40 — unconditional (byte1=target)
        $display("[DECODER] Control Flow");
        check_decode({8'h00, 8'd0, 8'h40, 8'h30}, 0,0, 0, 0,0,0, 0,0,0, 0,0,1,0, 0,0,0,0, 0);
        // JZ 0x20 (Z=1) -> jump
        check_decode({8'h00, 8'd0, 8'h20, 8'h31}, 1,0, 0, 0,0,0, 0,0,0, 0,0,1,1, 0,0,0,0, 0);
        // JZ 0x20 (Z=0) -> no jump
        check_decode({8'h00, 8'd0, 8'h20, 8'h31}, 0,0, 0, 0,0,0, 0,0,0, 0,0,0,1, 0,0,0,0, 0);
        // JNZ 0x30 (Z=0) -> jump
        check_decode({8'h00, 8'd0, 8'h30, 8'h32}, 0,0, 0, 0,0,0, 0,0,0, 0,0,1,1, 0,0,0,0, 0);
        // JC 0x10 (C=1) -> jump
        check_decode({8'h00, 8'd0, 8'h10, 8'h33}, 0,1, 0, 0,0,0, 0,0,0, 0,0,1,1, 0,0,0,0, 0);
        // CALL 0x50 (push + jump)
        check_decode({8'h00, 8'd0, 8'h50, 8'h34}, 0,0, 0, 0,0,0, 0,0,0, 1,0,1,0, 0,0,0,0, 0);
        // RET (pop + jump, result_sel=STACK)
        check_decode({8'h00, 8'd0, 8'd0, 8'h35}, 0,0, 0, 0,0,0, 0,0,0, 0,1,1,0, 0,0,0,0, 2);
        // HALT
        check_decode({8'h00, 8'd0, 8'd0, 8'h36}, 0,0, 0, 0,0,0, 0,0,0, 0,0,0,0, 0,0,0,1, 0);

        // === I/O ===
        // IN R4  — byte1=dst=4, raddr_a=7 (input port)
        $display("[DECODER] I/O");
        check_decode({8'h00, 8'd0, 8'd4, 8'h50}, 0,0, 0, 7,0,4, 1,0,0, 0,0,0,0, 0,0,0,0, 3);
        // OUT R1 — byte1=src=1
        check_decode({8'h00, 8'd0, 8'd1, 8'h51}, 0,0, 0, 1,0,0, 0,0,0, 0,0,0,0, 0,1,0,0, 0);

        // === NOP (unknown opcode) ===
        check_decode({8'h00, 8'd0, 8'd0, 8'hFF}, 0,0, 0, 0,0,0, 0,0,0, 0,0,0,0, 0,0,0,0, 0);

        // Final report
        $display("============================================");
        $display("=== TEST COMPLETE: %0d/%0d tests passed ===", pass_count, test_count);
        if (pass_count == test_count)
            $display("=== ALL TESTS PASSED ===");
        else
            $error("=== %0d TEST(S) FAILED ===", test_count - pass_count);
        $finish;
    end

endmodule
