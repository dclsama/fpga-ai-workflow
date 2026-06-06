// =============================================================================
// Testbench  : leg_register_tb
// Module DUT : leg_register
// Description: Self-checking testbench for synchronous register
// =============================================================================

`timescale 1ns / 1ps

module leg_register_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg                     i_load;
    reg                     i_save;
    reg  [DATA_WIDTH-1:0]   i_data;
    wire [DATA_WIDTH-1:0]   o_data;

    leg_register #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .i_load (i_load),
        .i_save (i_save),
        .i_data (i_data),
        .o_data (o_data)
    );

    initial begin
        $dumpfile("sim/leg_register/leg_register_tb.vcd");
        $dumpvars(0, leg_register_tb);
    end

    // Clock
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        integer test_count, pass_count;
        test_count = 0; pass_count = 0;

        // Reset
        rst_n = 1'b0; i_load = 1'b0; i_save = 1'b0; i_data = 8'h00;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(2) @(posedge clk);

        // Test 1: After reset, output is zero when load=0
        test_count = test_count + 1;
        $display("[TEST %0d] Output zero after reset (load=0)", test_count);
        if (o_data === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_data);
        end

        // Test 2: Save data, then load to output
        test_count = test_count + 1;
        $display("[TEST %0d] Save A5, then verify with load=1", test_count);
        @(posedge clk);
        i_save = 1'b1; i_data = 8'hA5;
        @(posedge clk);
        i_save = 1'b0;
        i_load = 1'b1;
        @(posedge clk);
        #1; // wait for combinational output
        if (o_data === 8'hA5) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected A5, got %h", o_data);
        end

        // Test 3: load=0 outputs zero even when internal value is A5
        test_count = test_count + 1;
        $display("[TEST %0d] load=0 outputs zero", test_count);
        i_load = 1'b0;
        #5;
        if (o_data === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_data);
        end

        // Test 4: load=1 restores output
        test_count = test_count + 1;
        $display("[TEST %0d] load=1 restores output", test_count);
        i_load = 1'b1;
        #5;
        if (o_data === 8'hA5) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected A5, got %h", o_data);
        end

        // Test 5: Write new value
        test_count = test_count + 1;
        $display("[TEST %0d] Write 5A over A5", test_count);
        @(posedge clk);
        i_save = 1'b1; i_data = 8'h5A;
        @(posedge clk);
        i_save = 1'b0;
        #5;
        if (o_data === 8'h5A) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 5A, got %h", o_data);
        end

        // Test 6: Reset clears value
        test_count = test_count + 1;
        $display("[TEST %0d] Reset clears internal value", test_count);
        rst_n = 1'b0;
        @(posedge clk);
        @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        if (o_data === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_data);
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
