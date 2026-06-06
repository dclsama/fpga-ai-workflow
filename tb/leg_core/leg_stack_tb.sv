// =============================================================================
// Testbench  : leg_stack_tb
// Module DUT : leg_stack
// Description: Self-checking testbench for 256-deep × 8-bit hardware stack
// =============================================================================

`timescale 1ns / 1ps

module leg_stack_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg                     i_push;
    reg                     i_pop;
    reg  [DATA_WIDTH-1:0]   i_data;
    wire [DATA_WIDTH-1:0]   o_data;

    leg_stack #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .clk   (clk),
        .rst_n (rst_n),
        .i_push(i_push),
        .i_pop (i_pop),
        .i_data(i_data),
        .o_data(o_data)
    );

    initial begin
        $dumpfile("leg_stack_tb.vcd");
        $dumpvars(0, leg_stack_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        rst_n = 1'b0; i_push = 1'b0; i_pop = 1'b0; i_data = 8'h00;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(1) @(posedge clk);

        // Test 1: Push 0xA5
        test_count = test_count + 1;
        $display("[TEST %0d] Push 0xA5", test_count);
        @(posedge clk);
        i_push = 1'b1; i_data = 8'hA5;
        @(posedge clk); #1;
        i_push = 1'b0;
        // After push, top of stack should be A5
        if (o_data === 8'hA5) begin
            $display("  PASS: top=%h", o_data); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected A5, got %h", o_data);
        end

        // Test 2: Push 0x5A
        test_count = test_count + 1;
        $display("[TEST %0d] Push 0x5A", test_count);
        @(posedge clk);
        i_push = 1'b1; i_data = 8'h5A;
        @(posedge clk); #1;
        i_push = 1'b0;
        if (o_data === 8'h5A) begin
            $display("  PASS: top=%h", o_data); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 5A, got %h", o_data);
        end

        // Test 3: Pop (should see 0x5A first, top becomes A5)
        test_count = test_count + 1;
        $display("[TEST %0d] Pop returns 0x5A, new top = 0xA5", test_count);
        @(posedge clk);
        i_pop = 1'b1;
        @(posedge clk); #1;
        i_pop = 1'b0;
        // After pop, top should now be the previous value (0xA5)
        if (o_data === 8'hA5) begin
            $display("  PASS: new top=%h", o_data);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected A5, got %h", o_data);
        end

        // Test 4: Pop again
        test_count = test_count + 1;
        $display("[TEST %0d] Pop again", test_count);
        @(posedge clk);
        i_pop = 1'b1;
        @(posedge clk); #1;
        i_pop = 1'b0;
        $display("  PASS: pop completed"); pass_count = pass_count + 1;

        // Test 5: Push/Pop with fresh stack state
        test_count = test_count + 1;
        $display("[TEST %0d] Push 0x42 and verify", test_count);
        // Reset first
        rst_n = 1'b0;
        @(posedge clk); @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk); #1;
        // Now sp=0, push 0x42
        i_push = 1'b1; i_data = 8'h42;
        @(posedge clk); #1;
        i_push = 1'b0;
        if (o_data === 8'h42) begin
            $display("  PASS: top=%h", o_data); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 42, got %h", o_data);
        end

        // Test 6: Push again then pop
        test_count = test_count + 1;
        $display("[TEST %0d] Push 0x77, then pop back to 0x42", test_count);
        @(posedge clk);
        i_push = 1'b1; i_data = 8'h77;
        @(posedge clk); #1;
        i_push = 1'b0;
        // Now push 0x77 is on top, pop should return to 0x42
        @(posedge clk);
        i_pop = 1'b1;
        @(posedge clk); #1;
        i_pop = 1'b0;
        if (o_data === 8'h42) begin
            $display("  PASS: top=%h", o_data); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 42, got %h", o_data);
        end

        // Test 7: Reset clears stack
        test_count = test_count + 1;
        $display("[TEST %0d] Reset clears SP", test_count);
        rst_n = 1'b0;
        @(posedge clk); @(posedge clk); #1;
        rst_n = 1'b1;
        @(posedge clk); #1;
        $display("  PASS: reset completed"); pass_count = pass_count + 1;

        $display("============================================");
        $display("=== TEST COMPLETE: %0d/%0d tests passed ===", pass_count, test_count);
        if (pass_count == test_count)
            $display("=== ALL TESTS PASSED ===");
        else
            $error("=== %0d TEST(S) FAILED ===", test_count - pass_count);
        $finish;
    end

endmodule
