// =============================================================================
// Testbench  : leg_core_tb
// Module DUT : leg_core (with internal behavioral ROM)
// Description: Integration test for LEG processor core with test programs
// =============================================================================

`timescale 1ns / 1ps

module leg_core_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg  [31:0]             i_inst;
    reg  [DATA_WIDTH-1:0]   i_input_port;
    wire [ADDR_WIDTH-1:0]   o_pc;
    wire [DATA_WIDTH-1:0]   o_output_port;
    wire                    o_output_en;
    wire                    o_halt;

    // Simple behavioral program ROM
    reg [7:0] rom [0:255];
    integer i;

    leg_core #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) uut (
        .clk           (clk),
        .rst_n         (rst_n),
        .i_inst        (i_inst),
        .i_input_port  (i_input_port),
        .o_pc          (o_pc),
        .o_output_port (o_output_port),
        .o_output_en   (o_output_en),
        .o_halt        (o_halt)
    );

    initial begin
        $dumpfile("leg_core_tb.vcd");
        $dumpvars(0, leg_core_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Instruction fetch: ROM read on PC change
    always @(*) begin
        i_inst = { rom[o_pc+3], rom[o_pc+2], rom[o_pc+1], rom[o_pc] };
    end

    // Load program into ROM
    task load_program;
        input [7:0] prog_bytes [0:255];
        input integer len;
        begin
            for (i = 0; i < 256; i = i + 1) rom[i] = 8'h00;
            for (i = 0; i < len; i = i + 1) rom[i] = prog_bytes[i];
        end
    endtask

    // Program bytes (32-bit instructions, little-endian byte order)
    // Test Program 1: Load, Output, ALU, Output, Halt
    reg [7:0] prog1 [0:255];
    initial begin
        // LDI R0, 0x42  → {00, 00, 42, 12}
        prog1[0] = 8'h12; prog1[1] = 8'h42; prog1[2] = 8'h00; prog1[3] = 8'h00;
        // OUT R0        → {00, 00, 00, 51}
        prog1[4] = 8'h51; prog1[5] = 8'h00; prog1[6] = 8'h00; prog1[7] = 8'h00;
        // ADDI R0, 0x01 → {00, 00, 01, 08}
        prog1[8] = 8'h08; prog1[9] = 8'h01; prog1[10] = 8'h00; prog1[11] = 8'h00;
        // OUT R0        → {00, 00, 00, 51}
        prog1[12] = 8'h51; prog1[13] = 8'h00; prog1[14] = 8'h00; prog1[15] = 8'h00;
        // HALT          → {00, 00, 00, 36}
        prog1[16] = 8'h36; prog1[17] = 8'h00; prog1[18] = 8'h00; prog1[19] = 8'h00;
    end

    integer test_count, pass_count;
    reg [7:0] captured_out1, captured_out2;

    initial begin
        test_count = 0; pass_count = 0;
        i_input_port = 8'h00;

        // Reset
        rst_n = 1'b0;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        load_program(prog1, 20);
        repeat(1) @(posedge clk);

        // Test 1: First output should be 0x42
        test_count = test_count + 1;
        $display("[TEST %0d] Output 0x42 via LDI+OUT", test_count);
        // Wait for output enable to go high
        while (!o_output_en && !o_halt) @(posedge clk);
        #1;  // let signals settle
        captured_out1 = o_output_port;
        if (captured_out1 === 8'h42) begin
            $display("  PASS: output = %h", captured_out1);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 42, got %h", captured_out1);
        end

        // Wait for output enable to go low (current instruction completes)
        while (o_output_en && !o_halt) @(posedge clk);

        // Test 2: Second output should be 0x43 (after ADDI +1)
        test_count = test_count + 1;
        $display("[TEST %0d] Output 0x43 after ADDI R0,1", test_count);
        // Wait for next output enable
        while (!o_output_en && !o_halt) @(posedge clk);
        #1;
        captured_out2 = o_output_port;
        if (captured_out2 === 8'h43) begin
            $display("  PASS: output = %h", captured_out2);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 43, got %h", captured_out2);
        end

        // Test 3: Processor halts
        test_count = test_count + 1;
        $display("[TEST %0d] Processor halts after program", test_count);
        // Wait for halt
        repeat(10) @(posedge clk);
        #1;
        if (o_halt === 1'b1) begin
            $display("  PASS: o_halt=1");
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected halt, got o_halt=%b (PC=%h)", o_halt, o_pc);
        end

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
