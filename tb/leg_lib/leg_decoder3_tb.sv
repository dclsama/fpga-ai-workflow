// =============================================================================
// Testbench  : leg_decoder3_tb
// Module DUT : leg_decoder3
// Description: Self-checking testbench for 3-to-8 decoder with enable
// =============================================================================

`timescale 1ns / 1ps

module leg_decoder3_tb;

    reg         i_en;
    reg  [2:0]  i_sel;
    wire [7:0]  o_y;

    leg_decoder3 uut (
        .i_en  (i_en),
        .i_sel (i_sel),
        .o_y   (o_y)
    );

    initial begin
        $dumpfile("sim/leg_decoder3/leg_decoder3_tb.vcd");
        $dumpvars(0, leg_decoder3_tb);
    end

    initial begin
        integer test_count, pass_count;
        integer i;
        reg [7:0] expected;
        test_count = 0; pass_count = 0;

        // Test 1-8: Each select value with enable=1
        for (i = 0; i < 8; i = i + 1) begin
            test_count = test_count + 1;
            $display("[TEST %0d] DECODER: en=1, sel=%0d", test_count, i);
            i_en = 1'b1;
            i_sel = i[2:0];
            expected = 8'b1 << i;
            #10;
            if (o_y === expected) begin
                $display("  PASS: output = %b", o_y);
                pass_count = pass_count + 1;
            end else begin
                $error("  FAIL: expected %b, got %b", expected, o_y);
            end
        end

        // Test 9: Disabled output (en=0)
        test_count = test_count + 1;
        $display("[TEST %0d] DECODER: en=0, all outputs zero", test_count);
        i_en = 1'b0; i_sel = 3'd5;
        #10;
        if (o_y === 8'b0000_0000) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00000000, got %b", o_y);
        end

        // Test 10: Enable back on
        test_count = test_count + 1;
        $display("[TEST %0d] DECODER: en=1 after disable, sel=7", test_count);
        i_en = 1'b1; i_sel = 3'd7;
        #10;
        if (o_y === 8'b1000_0000) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 10000000, got %b", o_y);
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
