// =============================================================================
// Testbench  : <module_name>_tb
// Module DUT : <module_name>
// Description: Self-checking testbench with comprehensive test cases
// =============================================================================

`timescale 1ns / 1ps

module <module_name>_tb;

    // =========================================================================
    // Parameters
    // =========================================================================
    parameter CLK_PERIOD = 10;     // 100 MHz
    parameter DATA_WIDTH = 8;

    // =========================================================================
    // Signal declarations
    // =========================================================================
    reg                     clk;
    reg                     rst_n;
    reg                     i_enable;
    reg  [DATA_WIDTH-1:0]   i_data;
    wire                    o_valid;
    wire [DATA_WIDTH-1:0]   o_data;

    // =========================================================================
    // DUT instantiation
    // =========================================================================
    <module_name> #(
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_enable (i_enable),
        .i_data   (i_data),
        .o_valid  (o_valid),
        .o_data   (o_data)
    );

    // =========================================================================
    // Waveform dumping
    // =========================================================================
    initial begin
        $dumpfile("<module_name>_tb.vcd");
        $dumpvars(0, <module_name>_tb);
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
        test_count = 0;
        pass_count = 0;

        // Initialize inputs
        i_enable = 1'b0;
        i_data   = {DATA_WIDTH{1'b0}};

        // Wait for reset deassertion
        @(posedge rst_n);
        repeat(2) @(posedge clk);

        // ---------------------------------------------------------------------
        // Test Case 1: description
        // ---------------------------------------------------------------------
        $display("[TEST %0d] <description>", test_count);
        test_count = test_count + 1;
        // Apply stimulus
        @(posedge clk);
        // Check results
        if (/* expected condition */ 1) begin
            $display("  PASS");
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected %h, got %h", /*expected*/, /*actual*/);
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
