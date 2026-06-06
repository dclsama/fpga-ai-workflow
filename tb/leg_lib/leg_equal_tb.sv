// =============================================================================
// Testbench  : leg_equal_tb
// Module DUT : leg_equal
// Description: Self-checking testbench for equality comparator
// =============================================================================

`timescale 1ns / 1ps

module leg_equal_tb;

    parameter DATA_WIDTH = 8;

    reg  [DATA_WIDTH-1:0] i_a;
    reg  [DATA_WIDTH-1:0] i_b;
    wire                  o_y;

    leg_equal #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .i_a (i_a),
        .i_b (i_b),
        .o_y (o_y)
    );

    initial begin
        $dumpfile("sim/leg_equal/leg_equal_tb.vcd");
        $dumpvars(0, leg_equal_tb);
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        // Test 1: Equal zeros
        test_count = test_count + 1;
        $display("[TEST %0d] EQUAL: 00 == 00", test_count);
        i_a = 8'h00; i_b = 8'h00; #10;
        if (o_y === 1'b1) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 1, got %b", o_y);
        end

        // Test 2: Equal non-zero
        test_count = test_count + 1;
        $display("[TEST %0d] EQUAL: A5 == A5", test_count);
        i_a = 8'hA5; i_b = 8'hA5; #10;
        if (o_y === 1'b1) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 1, got %b", o_y);
        end

        // Test 3: Not equal
        test_count = test_count + 1;
        $display("[TEST %0d] EQUAL: A5 != 5A", test_count);
        i_a = 8'hA5; i_b = 8'h5A; #10;
        if (o_y === 1'b0) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 0, got %b", o_y);
        end

        // Test 4: Not equal (one bit different)
        test_count = test_count + 1;
        $display("[TEST %0d] EQUAL: FF != FE", test_count);
        i_a = 8'hFF; i_b = 8'hFE; #10;
        if (o_y === 1'b0) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 0, got %b", o_y);
        end

        // Test 5: All ones equal
        test_count = test_count + 1;
        $display("[TEST %0d] EQUAL: FF == FF", test_count);
        i_a = 8'hFF; i_b = 8'hFF; #10;
        if (o_y === 1'b1) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 1, got %b", o_y);
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
