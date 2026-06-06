// =============================================================================
// Testbench  : leg_and_tb
// Module DUT : leg_and
// Description: Self-checking testbench for parameterized AND gate
// =============================================================================

`timescale 1ns / 1ps

module leg_and_tb;

    // Parameters
    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    // Signals
    reg  [DATA_WIDTH-1:0] i_a;
    reg  [DATA_WIDTH-1:0] i_b;
    wire [DATA_WIDTH-1:0] o_y;

    // DUT instantiation
    leg_and #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .i_a (i_a),
        .i_b (i_b),
        .o_y (o_y)
    );

    // Waveform dumping
    initial begin
        $dumpfile("sim/leg_and/leg_and_tb.vcd");
        $dumpvars(0, leg_and_tb);
    end

    // Stimulus & self-checking
    initial begin
        integer test_count, pass_count;
        test_count = 0;
        pass_count = 0;

        // Test 1: All zeros
        test_count = test_count + 1;
        $display("[TEST %0d] AND: 0 & 0", test_count);
        i_a = 8'h00; i_b = 8'h00;
        #10;
        if (o_y === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_y);
        end

        // Test 2: All ones
        test_count = test_count + 1;
        $display("[TEST %0d] AND: FF & FF", test_count);
        i_a = 8'hFF; i_b = 8'hFF;
        #10;
        if (o_y === 8'hFF) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected FF, got %h", o_y);
        end

        // Test 3: 0xAA & 0x55 = 0x00
        test_count = test_count + 1;
        $display("[TEST %0d] AND: AA & 55 = 00", test_count);
        i_a = 8'hAA; i_b = 8'h55;
        #10;
        if (o_y === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_y);
        end

        // Test 4: 0x0F & 0xF0 = 0x00
        test_count = test_count + 1;
        $display("[TEST %0d] AND: 0F & F0 = 00", test_count);
        i_a = 8'h0F; i_b = 8'hF0;
        #10;
        if (o_y === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_y);
        end

        // Test 5: 0x3C & 0x7E = 0x3C
        test_count = test_count + 1;
        $display("[TEST %0d] AND: 3C & 7E = 3C", test_count);
        i_a = 8'h3C; i_b = 8'h7E;
        #10;
        if (o_y === 8'h3C) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 3C, got %h", o_y);
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
