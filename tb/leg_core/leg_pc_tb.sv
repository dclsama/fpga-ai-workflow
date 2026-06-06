// =============================================================================
// Testbench  : leg_pc_tb
// Module DUT : leg_pc
// Description: Self-checking testbench for program counter
// =============================================================================

`timescale 1ns / 1ps

module leg_pc_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg                     i_jump;
    reg  [DATA_WIDTH-1:0]   i_target;
    wire [DATA_WIDTH-1:0]   o_pc;

    leg_pc #(.DATA_WIDTH(DATA_WIDTH), .STEP(4)) uut (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_jump  (i_jump),
        .i_target(i_target),
        .o_pc    (o_pc)
    );

    initial begin
        $dumpfile("leg_pc_tb.vcd");
        $dumpvars(0, leg_pc_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        rst_n = 1'b0; i_jump = 1'b0; i_target = 8'h00;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(1) @(posedge clk);

        // Test 1: PC=0 after reset
        test_count = test_count + 1;
        $display("[TEST %0d] PC=0 after reset", test_count);
        if (o_pc === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_pc);
        end

        // Test 2: PC increments by 4
        test_count = test_count + 1;
        $display("[TEST %0d] PC=4 after increment", test_count);
        @(posedge clk);
        if (o_pc === 8'h04) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 04, got %h", o_pc);
        end

        // Test 3: PC=8
        test_count = test_count + 1;
        $display("[TEST %0d] PC=8 after 2nd increment", test_count);
        @(posedge clk);
        if (o_pc === 8'h08) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 08, got %h", o_pc);
        end

        // Test 4: Jump to 0x40
        test_count = test_count + 1;
        $display("[TEST %0d] Jump to 0x40", test_count);
        i_jump = 1'b1; i_target = 8'h40;
        @(posedge clk);
        i_jump = 1'b0;
        if (o_pc === 8'h40) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 40, got %h", o_pc);
        end

        // Test 5: Continue from jumped address
        test_count = test_count + 1;
        $display("[TEST %0d] PC=44 after jump continuation", test_count);
        @(posedge clk);
        if (o_pc === 8'h44) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 44, got %h", o_pc);
        end

        // Test 6: Jump to 0x00 (restart)
        test_count = test_count + 1;
        $display("[TEST %0d] Jump to 0x00", test_count);
        i_jump = 1'b1; i_target = 8'h00;
        @(posedge clk);
        i_jump = 1'b0;
        if (o_pc === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_pc);
        end

        $display("============================================");
        $display("=== TEST COMPLETE: %0d/%0d tests passed ===", pass_count, test_count);
        if (pass_count == test_count)
            $display("=== ALL TESTS PASSED ===");
        else
            $error("=== %0d TEST(S) FAILED ===", test_count - pass_count);
        $finish;
    end

endmodule
