// =============================================================================
// Testbench  : leg_add_tb
// Module DUT : leg_add
// Description: Self-checking testbench for parameterized adder with carry
// =============================================================================

`timescale 1ns / 1ps

module leg_add_tb;

    parameter DATA_WIDTH = 8;

    reg  [DATA_WIDTH-1:0] i_a;
    reg  [DATA_WIDTH-1:0] i_b;
    reg                   i_ci;
    wire [DATA_WIDTH-1:0] o_y;
    wire                  o_co;

    leg_add #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .i_a  (i_a),
        .i_b  (i_b),
        .i_ci (i_ci),
        .o_y  (o_y),
        .o_co (o_co)
    );

    initial begin
        $dumpfile("sim/leg_add/leg_add_tb.vcd");
        $dumpvars(0, leg_add_tb);
    end

    // Helper task
    task test_add;
        input [7:0] a, b;
        input       ci;
        input [8:0] expected; // {co, sum}
        begin
            i_a = a; i_b = b; i_ci = ci; #10;
            if ({o_co, o_y} === expected) begin
                $display("  PASS: %h + %h + %b = %b%h", a, b, ci, o_co, o_y);
            end else begin
                $error("  FAIL: %h + %h + %b: expected %b%h, got %b%h",
                       a, b, ci, expected[8], expected[7:0], o_co, o_y);
            end
        end
    endtask

    initial begin
        integer test_count, pass_count, fail_count;
        test_count = 0; pass_count = 0;

        $display("[========== leg_add Tests ==========]");

        test_count = test_count + 1; $display("[TEST %0d] Basic addition", test_count);
        test_add(8'h00, 8'h00, 1'b0, 9'h000); pass_count = pass_count + (({o_co, o_y} === 9'h000) ? 1 : 0);

        test_count = test_count + 1; $display("[TEST %0d] Addition with carry in", test_count);
        test_add(8'h00, 8'h00, 1'b1, 9'h001); pass_count = pass_count + (({o_co, o_y} === 9'h001) ? 1 : 0);

        test_count = test_count + 1; $display("[TEST %0d] 1+1=2", test_count);
        test_add(8'h01, 8'h01, 1'b0, 9'h002); pass_count = pass_count + (({o_co, o_y} === 9'h002) ? 1 : 0);

        test_count = test_count + 1; $display("[TEST %0d] 127+1=128", test_count);
        test_add(8'h7F, 8'h01, 1'b0, 9'h080); pass_count = pass_count + (({o_co, o_y} === 9'h080) ? 1 : 0);

        test_count = test_count + 1; $display("[TEST %0d] 128+128=256 (overflow)", test_count);
        test_add(8'h80, 8'h80, 1'b0, 9'h100); pass_count = pass_count + (({o_co, o_y} === 9'h100) ? 1 : 0);

        test_count = test_count + 1; $display("[TEST %0d] Max: FF+FF+1=1FF", test_count);
        test_add(8'hFF, 8'hFF, 1'b1, 9'h1FF); pass_count = pass_count + (({o_co, o_y} === 9'h1FF) ? 1 : 0);

        test_count = test_count + 1; $display("[TEST %0d] A5+5A=FF", test_count);
        test_add(8'hA5, 8'h5A, 1'b0, 9'h0FF); pass_count = pass_count + (({o_co, o_y} === 9'h0FF) ? 1 : 0);

        // Final report
        fail_count = test_count - pass_count;
        $display("============================================");
        $display("=== TEST COMPLETE: %0d/%0d tests passed ===", pass_count, test_count);
        if (fail_count == 0)
            $display("=== ALL TESTS PASSED ===");
        else
            $error("=== %0d TEST(S) FAILED ===", fail_count);
        $finish;
    end

endmodule
