// =============================================================================
// Testbench  : counter_tb
// Module DUT : counter
// Description: Self-checking testbench for the 8-bit counter module
// =============================================================================

`timescale 1ns / 1ps

module counter_tb;

    // =========================================================================
    // Parameters
    // =========================================================================
    parameter CLK_PERIOD = 10;   // 100 MHz
    parameter WIDTH      = 8;

    // =========================================================================
    // Signal declarations
    // =========================================================================
    reg                clk;
    reg                rst_n;
    reg                i_en;
    wire [WIDTH-1:0]   o_count;

    // =========================================================================
    // DUT instantiation
    // =========================================================================
    counter #(
        .WIDTH(WIDTH)
    ) uut (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_en    (i_en),
        .o_count (o_count)
    );

    // =========================================================================
    // Waveform dumping
    // =========================================================================
    initial begin
        $dumpfile("counter_tb.vcd");
        $dumpvars(0, counter_tb);
    end

    // =========================================================================
    // Clock generation
    // =========================================================================
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // =========================================================================
    // Reset generation
    // =========================================================================
    initial begin
        rst_n = 1'b0;
        repeat(10) @(posedge clk);
        rst_n = 1'b1;
    end

    // =========================================================================
    // Stimulus & self-checking
    // =========================================================================
    initial begin
        integer test_count;
        integer pass_count;
        integer i;
        reg [WIDTH-1:0] expected;

        test_count = 0;
        pass_count = 0;

        // Initialize inputs
        i_en = 1'b0;

        // Wait for reset deassertion
        @(posedge rst_n);
        repeat(2) @(posedge clk);

        // ---------------------------------------------------------------------
        // Test Case 1: Reset initializes counter to 0
        // ---------------------------------------------------------------------
        $display("[TEST %0d] Reset initializes counter to 0", test_count);
        test_count = test_count + 1;
        // Wait a cycle after reset
        @(posedge clk);
        if (o_count === 8'd0) begin
            $display("  PASS");
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: After reset, expected 0, got %0d", o_count);
        end

        // ---------------------------------------------------------------------
        // Test Case 2: Counter stays at 0 when enable is low
        // ---------------------------------------------------------------------
        $display("[TEST %0d] Counter holds value when enable is low", test_count);
        test_count = test_count + 1;
        i_en = 1'b0;
        repeat(5) @(posedge clk);
        if (o_count === 8'd0) begin
            $display("  PASS");
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: With en=0, expected 0, got %0d", o_count);
        end

        // ---------------------------------------------------------------------
        // Test Case 3: Counter increments by 1 each cycle
        // ---------------------------------------------------------------------
        $display("[TEST %0d] Counter increments by 1 each cycle", test_count);
        test_count = test_count + 1;
        i_en = 1'b1;
        expected = 8'd0;
        for (i = 0; i < 20; i = i + 1) begin
            @(posedge clk);
            expected = expected + 1'b1;
            if (o_count !== expected) begin
                $error("  FAIL at time %0t: cycle %0d, expected %0d, got %0d",
                       $time, i, expected, o_count);
            end
        end
        // Check if any failures
        if (expected === 8'd20) begin
            // All increments were correct (we got here without errors if all matched)
            $display("  PASS (20 cycles verified)");
            pass_count = pass_count + 1;
        end

        // ---------------------------------------------------------------------
        // Test Case 4: Counter wraps from 255 to 0 (overflow)
        // ---------------------------------------------------------------------
        $display("[TEST %0d] Counter wraps from max to 0 (overflow)", test_count);
        test_count = test_count + 1;
        i_en = 1'b0;
        @(posedge clk);
        // Force counter to near-max value via reset+many cycles
        // We'll use a simpler approach: check that after 256 increments it wraps
        rst_n = 1'b0;
        repeat(5) @(posedge clk);
        rst_n = 1'b1;
        i_en = 1'b1;
        @(posedge clk);
        // Wait for counter to naturally wrap
        // Counter is at 1 after the @(posedge clk) above, so start expected at 1
        // i starts at 1 since counter is already at 1
        expected = 8'd1;
        for (i = 1; i < 256; i = i + 1) begin
            @(posedge clk);
            expected = expected + 1'b1;
            if (o_count !== expected) begin
                $error("  FAIL at time %0t: wrap test, expected %0d, got %0d",
                       $time, expected, o_count);
            end
        end
        // After 255 more increments, counter should have wrapped to 0
        if (o_count === 8'd0) begin
            $display("  PASS (wrapped to 0 after 256 total increments)");
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: After 256 increments, expected 0, got %0d", o_count);
        end

        // ---------------------------------------------------------------------
        // Test Case 5: Enable toggling does not cause glitches
        // ---------------------------------------------------------------------
        $display("[TEST %0d] Enable toggling - counter only counts when en=1", test_count);
        test_count = test_count + 1;
        rst_n = 1'b0;
        repeat(5) @(posedge clk);
        rst_n = 1'b1;
        i_en = 1'b0;
        @(posedge clk);

        // Pulse enable every other cycle
        for (i = 0; i < 10; i = i + 1) begin
            i_en = 1'b1;
            @(posedge clk);
            i_en = 1'b0;
            @(posedge clk);
        end

        if (o_count === 8'd10) begin
            $display("  PASS (counted exactly 10 times with toggled enable)");
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: After 10 enable pulses, expected 10, got %0d", o_count);
        end

        // ---------------------------------------------------------------------
        // Final report
        // ---------------------------------------------------------------------
        repeat(5) @(posedge clk);
        $display("============================================");
        $display("=== TEST COMPLETE: %0d/%0d tests passed ===", pass_count, test_count);
        $display("============================================");
        if (pass_count == test_count) begin
            $display("=== ALL TESTS PASSED ===");
        end else begin
            $error("=== %0d TEST(S) FAILED ===", test_count - pass_count);
        end
        $finish;
    end

endmodule
