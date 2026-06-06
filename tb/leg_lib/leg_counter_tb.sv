// =============================================================================
// Testbench  : leg_counter_tb
// Module DUT : leg_counter
// Description: Self-checking testbench for configurable-step counter
// =============================================================================

`timescale 1ns / 1ps

module leg_counter_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;
    parameter STEP       = 4;

    reg                     clk;
    reg                     rst_n;
    reg                     i_save;
    reg  [DATA_WIDTH-1:0]   i_data;
    wire [DATA_WIDTH-1:0]   o_count;

    leg_counter #(.DATA_WIDTH(DATA_WIDTH), .STEP(STEP)) uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .i_save (i_save),
        .i_data (i_data),
        .o_count(o_count)
    );

    initial begin
        $dumpfile("sim/leg_counter/leg_counter_tb.vcd");
        $dumpvars(0, leg_counter_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        // Reset
        rst_n = 1'b0; i_save = 1'b0; i_data = 8'h00;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(1) @(posedge clk);

        // Test 1: After reset, count starts at 0
        test_count = test_count + 1;
        $display("[TEST %0d] Count = 0 after reset", test_count);
        if (o_count === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_count);
        end

        // Test 2: Count increments by STEP
        test_count = test_count + 1;
        $display("[TEST %0d] Count increments by %0d", test_count, STEP);
        @(posedge clk);
        if (o_count === STEP) begin
            $display("  PASS: count=%0d", o_count);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected %0d, got %0d", STEP, o_count);
        end

        // Test 3: Second increment
        test_count = test_count + 1;
        $display("[TEST %0d] Count increments to %0d", test_count, 2*STEP);
        @(posedge clk);
        if (o_count === 2*STEP) begin
            $display("  PASS: count=%0d", o_count);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected %0d, got %0d", 2*STEP, o_count);
        end

        // Test 4: Jump (load) to address 0x20
        test_count = test_count + 1;
        $display("[TEST %0d] Jump to 0x20", test_count);
        i_save = 1'b1; i_data = 8'h20;
        @(posedge clk);
        i_save = 1'b0;
        if (o_count === 8'h20) begin
            $display("  PASS: count=%h", o_count);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 20, got %h", o_count);
        end

        // Test 5: Continue from jumped value (0x20 + STEP)
        test_count = test_count + 1;
        $display("[TEST %0d] Continue from 0x20 (increment by %0d)", test_count, STEP);
        @(posedge clk);
        if (o_count === 8'h20 + STEP) begin
            $display("  PASS: count=%0d", o_count);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected %0d, got %0d", 8'h20+STEP, o_count);
        end

        // Test 6: Reset mid-count
        test_count = test_count + 1;
        $display("[TEST %0d] Reset clears count", test_count);
        rst_n = 1'b0;
        @(posedge clk);
        @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        if (o_count === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_count);
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
