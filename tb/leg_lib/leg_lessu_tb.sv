// =============================================================================
// Testbench  : leg_lessu_tb
// Module DUT : leg_lessu
// Description: Self-checking testbench for unsigned less-than comparator
// =============================================================================

`timescale 1ns / 1ps

module leg_lessu_tb;

    parameter DATA_WIDTH = 8;

    reg  [DATA_WIDTH-1:0] i_a;
    reg  [DATA_WIDTH-1:0] i_b;
    wire                  o_y;

    leg_lessu #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .i_a (i_a),
        .i_b (i_b),
        .o_y (o_y)
    );

    initial begin
        $dumpfile("sim/leg_lessu/leg_lessu_tb.vcd");
        $dumpvars(0, leg_lessu_tb);
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        // Test 1: 0 < 0 is false
        test_count = test_count + 1;
        $display("[TEST %0d] LESSU: 0 < 0 = 0", test_count);
        i_a = 8'h00; i_b = 8'h00; #10;
        if (o_y === 1'b0) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 0, got %b", o_y);
        end

        // Test 2: 0 < 1 is true
        test_count = test_count + 1;
        $display("[TEST %0d] LESSU: 0 < 1 = 1", test_count);
        i_a = 8'h00; i_b = 8'h01; #10;
        if (o_y === 1'b1) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 1, got %b", o_y);
        end

        // Test 3: 1 < 0 is false
        test_count = test_count + 1;
        $display("[TEST %0d] LESSU: 1 < 0 = 0", test_count);
        i_a = 8'h01; i_b = 8'h00; #10;
        if (o_y === 1'b0) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 0, got %b", o_y);
        end

        // Test 4: 0x7F < 0x80 is true
        test_count = test_count + 1;
        $display("[TEST %0d] LESSU: 7F < 80 = 1", test_count);
        i_a = 8'h7F; i_b = 8'h80; #10;
        if (o_y === 1'b1) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 1, got %b", o_y);
        end

        // Test 5: 0xFF < 0x00 is false
        test_count = test_count + 1;
        $display("[TEST %0d] LESSU: FF < 00 = 0", test_count);
        i_a = 8'hFF; i_b = 8'h00; #10;
        if (o_y === 1'b0) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 0, got %b", o_y);
        end

        // Test 6: 0xA5 < 0xA5 is false
        test_count = test_count + 1;
        $display("[TEST %0d] LESSU: A5 < A5 = 0", test_count);
        i_a = 8'hA5; i_b = 8'hA5; #10;
        if (o_y === 1'b0) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 0, got %b", o_y);
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
