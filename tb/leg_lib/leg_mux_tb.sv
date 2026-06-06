// =============================================================================
// Testbench  : leg_mux_tb
// Module DUT : leg_mux
// Description: Self-checking testbench for parameterized 2-to-1 multiplexer
// =============================================================================

`timescale 1ns / 1ps

module leg_mux_tb;

    parameter DATA_WIDTH = 8;

    reg                   i_sel;
    reg  [DATA_WIDTH-1:0] i_a;
    reg  [DATA_WIDTH-1:0] i_b;
    wire [DATA_WIDTH-1:0] o_y;

    leg_mux #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .i_sel (i_sel),
        .i_a   (i_a),
        .i_b   (i_b),
        .o_y   (o_y)
    );

    initial begin
        $dumpfile("sim/leg_mux/leg_mux_tb.vcd");
        $dumpvars(0, leg_mux_tb);
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        // Test 1: sel=0 selects i_a
        test_count = test_count + 1;
        $display("[TEST %0d] MUX: sel=0 selects i_a", test_count);
        i_sel = 1'b0; i_a = 8'hA5; i_b = 8'h5A;
        #10;
        if (o_y === 8'hA5) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected A5, got %h", o_y);
        end

        // Test 2: sel=1 selects i_b
        test_count = test_count + 1;
        $display("[TEST %0d] MUX: sel=1 selects i_b", test_count);
        i_sel = 1'b1; i_a = 8'hA5; i_b = 8'h5A;
        #10;
        if (o_y === 8'h5A) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 5A, got %h", o_y);
        end

        // Test 3: zero inputs
        test_count = test_count + 1;
        $display("[TEST %0d] MUX: zero inputs, sel=0", test_count);
        i_sel = 1'b0; i_a = 8'h00; i_b = 8'hFF;
        #10;
        if (o_y === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_y);
        end

        // Test 4: all ones
        test_count = test_count + 1;
        $display("[TEST %0d] MUX: all ones, sel=1", test_count);
        i_sel = 1'b1; i_a = 8'h00; i_b = 8'hFF;
        #10;
        if (o_y === 8'hFF) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected FF, got %h", o_y);
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
