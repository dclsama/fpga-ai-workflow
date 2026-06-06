// =============================================================================
// Testbench  : leg_alu_tb
// Module DUT : leg_alu
// Description: Self-checking testbench for LEG ALU — all 8 operations
// =============================================================================

`timescale 1ns / 1ps

module leg_alu_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg  [2:0]              i_op;
    reg  [DATA_WIDTH-1:0]   i_a;
    reg  [DATA_WIDTH-1:0]   i_b;
    wire [DATA_WIDTH-1:0]   o_result;
    wire                    o_flag_z;
    wire                    o_flag_c;

    leg_alu #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_op     (i_op),
        .i_a      (i_a),
        .i_b      (i_b),
        .o_result (o_result),
        .o_flag_z (o_flag_z),
        .o_flag_c (o_flag_c)
    );

    initial begin
        $dumpfile("leg_alu_tb.vcd");
        $dumpvars(0, leg_alu_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    integer test_count, pass_count;

    // Helper task
    task check_alu;
        input [2:0] op;
        input [7:0] a, b;
        input [7:0] exp_result;
        input       exp_z, exp_c;
        begin
            i_op = op; i_a = a; i_b = b; #10;
            if (o_result === exp_result && o_flag_z === exp_z && o_flag_c === exp_c) begin
                $display("  PASS: op=%0d, %h op %h = %h (z=%b, c=%b)", op, a, b, o_result, o_flag_z, o_flag_c);
                pass_count = pass_count + 1;
            end else begin
                $error("  FAIL: op=%0d, %h op %h: expected %h (z=%b,c=%b), got %h (z=%b,c=%b)",
                       op, a, b, exp_result, exp_z, exp_c, o_result, o_flag_z, o_flag_c);
            end
            test_count = test_count + 1;
        end
    endtask

    initial begin
        test_count = 0; pass_count = 0;
        rst_n = 1'b0; i_op = 3'b000; i_a = 8'h00; i_b = 8'h00;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(2) @(posedge clk);

        // ADD tests
        $display("[TEST %0d] ADD: 5+3=8", test_count+1);
        check_alu(3'b000, 8'h05, 8'h03, 8'h08, 1'b0, 1'b0);
        $display("[TEST %0d] ADD: 0xFF+0x01=0x00 (overflow)", test_count+1);
        check_alu(3'b000, 8'hFF, 8'h01, 8'h00, 1'b1, 1'b1);
        $display("[TEST %0d] ADD: 0+0=0 (zero flag)", test_count+1);
        check_alu(3'b000, 8'h00, 8'h00, 8'h00, 1'b1, 1'b0);

        // SUB tests
        $display("[TEST %0d] SUB: 5-3=2", test_count+1);
        check_alu(3'b001, 8'h05, 8'h03, 8'h02, 1'b0, 1'b0);
        $display("[TEST %0d] SUB: 3-5=0xFE (borrow)", test_count+1);
        check_alu(3'b001, 8'h03, 8'h05, 8'hFE, 1'b0, 1'b1);
        $display("[TEST %0d] SUB: 5-5=0 (zero)", test_count+1);
        check_alu(3'b001, 8'h05, 8'h05, 8'h00, 1'b1, 1'b0);

        // AND tests
        $display("[TEST %0d] AND: 0xFF & 0x0F = 0x0F", test_count+1);
        check_alu(3'b010, 8'hFF, 8'h0F, 8'h0F, 1'b0, 1'b0);
        $display("[TEST %0d] AND: 0xAA & 0x55 = 0x00 (zero)", test_count+1);
        check_alu(3'b010, 8'hAA, 8'h55, 8'h00, 1'b1, 1'b0);

        // OR tests
        $display("[TEST %0d] OR: 0xF0 | 0x0F = 0xFF", test_count+1);
        check_alu(3'b011, 8'hF0, 8'h0F, 8'hFF, 1'b0, 1'b0);
        $display("[TEST %0d] OR: 0x00 | 0x00 = 0x00 (zero)", test_count+1);
        check_alu(3'b011, 8'h00, 8'h00, 8'h00, 1'b1, 1'b0);

        // NOT tests
        $display("[TEST %0d] NOT: ~0xA5 = 0x5A", test_count+1);
        check_alu(3'b100, 8'hA5, 8'h00, 8'h5A, 1'b0, 1'b0);
        $display("[TEST %0d] NOT: ~0xFF = 0x00 (zero)", test_count+1);
        check_alu(3'b100, 8'hFF, 8'h00, 8'h00, 1'b1, 1'b0);

        // XOR tests
        $display("[TEST %0d] XOR: 0xA5 ^ 0xA5 = 0x00 (zero)", test_count+1);
        check_alu(3'b101, 8'hA5, 8'hA5, 8'h00, 1'b1, 1'b0);
        $display("[TEST %0d] XOR: 0xFF ^ 0x0F = 0xF0", test_count+1);
        check_alu(3'b101, 8'hFF, 8'h0F, 8'hF0, 1'b0, 1'b0);

        // SHL tests
        $display("[TEST %0d] SHL: 0x01 << 3 = 0x08", test_count+1);
        check_alu(3'b110, 8'h01, 8'h03, 8'h08, 1'b0, 1'b0);
        $display("[TEST %0d] SHL: 0x80 << 1 = 0x00 (overflow)", test_count+1);
        check_alu(3'b110, 8'h80, 8'h01, 8'h00, 1'b1, 1'b0);

        // SHR tests
        $display("[TEST %0d] SHR: 0x80 >> 3 = 0x10", test_count+1);
        check_alu(3'b111, 8'h80, 8'h03, 8'h10, 1'b0, 1'b0);
        $display("[TEST %0d] SHR: 0x01 >> 1 = 0x00", test_count+1);
        check_alu(3'b111, 8'h01, 8'h01, 8'h00, 1'b1, 1'b0);

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
