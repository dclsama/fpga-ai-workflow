// =============================================================================
// Testbench  : leg_regfile_tb
// Module DUT : leg_regfile
// Description: Self-checking testbench for 8×8-bit register file
// =============================================================================

`timescale 1ns / 1ps

module leg_regfile_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg  [2:0]              i_raddr_a;
    reg  [2:0]              i_raddr_b;
    reg  [2:0]              i_waddr;
    reg                     i_we;
    reg  [DATA_WIDTH-1:0]   i_wdata;
    reg  [DATA_WIDTH-1:0]   i_pc;
    reg  [DATA_WIDTH-1:0]   i_input;
    wire [DATA_WIDTH-1:0]   o_rdata_a;
    wire [DATA_WIDTH-1:0]   o_rdata_b;

    leg_regfile #(.DATA_WIDTH(DATA_WIDTH)) uut (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_raddr_a(i_raddr_a),
        .i_raddr_b(i_raddr_b),
        .i_waddr  (i_waddr),
        .i_we     (i_we),
        .i_wdata  (i_wdata),
        .i_pc     (i_pc),
        .i_input  (i_input),
        .o_rdata_a(o_rdata_a),
        .o_rdata_b(o_rdata_b)
    );

    initial begin
        $dumpfile("leg_regfile_tb.vcd");
        $dumpvars(0, leg_regfile_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        integer test_count, pass_count;
        integer i;
        test_count = 0; pass_count = 0;

        // Reset
        rst_n = 1'b0;
        i_raddr_a = 3'd0; i_raddr_b = 3'd0;
        i_waddr = 3'd0; i_we = 1'b0; i_wdata = 8'h00;
        i_pc = 8'h10; i_input = 8'hFF;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(2) @(posedge clk);

        // Test 1: After reset, R0=0
        test_count = test_count + 1;
        $display("[TEST %0d] After reset, R0 = 0", test_count);
        i_raddr_a = 3'd0; #5;
        if (o_rdata_a === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_rdata_a);
        end

        // Test 2-7: Write and read back each GPR
        for (i = 0; i < 6; i = i + 1) begin
            test_count = test_count + 1;
            $display("[TEST %0d] Write R%0d = %h, read back", test_count, i, 8'hA0 + i);
            @(posedge clk);
            i_we = 1'b1; i_waddr = i[2:0]; i_wdata = 8'hA0 + i;
            @(posedge clk);
            i_we = 1'b0;
            i_raddr_a = i[2:0]; #5;
            if (o_rdata_a === (8'hA0 + i)) begin
                $display("  PASS: R%0d = %h", i, o_rdata_a);
                pass_count = pass_count + 1;
            end else begin
                $error("  FAIL: expected %h, got %h", 8'hA0+i, o_rdata_a);
            end
        end

        // Test 8: Dual read ports — read R0 on port A, R1 on port B
        test_count = test_count + 1;
        $display("[TEST %0d] Dual read: R0 on A, R1 on B", test_count);
        i_raddr_a = 3'd0; i_raddr_b = 3'd1; #5;
        if (o_rdata_a === 8'hA0 && o_rdata_b === 8'hA1) begin
            $display("  PASS: A=%h, B=%h", o_rdata_a, o_rdata_b);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: A=%h (expected A0), B=%h (expected A1)", o_rdata_a, o_rdata_b);
        end

        // Test 9: Read PC (R6)
        test_count = test_count + 1;
        $display("[TEST %0d] Read R6 = PC = 10", test_count);
        i_raddr_a = 3'd6; #5;
        if (o_rdata_a === 8'h10) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 10, got %h", o_rdata_a);
        end

        // Test 10: Read INPUT (R7)
        test_count = test_count + 1;
        $display("[TEST %0d] Read R7 = INPUT = FF", test_count);
        i_raddr_a = 3'd7; #5;
        if (o_rdata_a === 8'hFF) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected FF, got %h", o_rdata_a);
        end

        // Test 11: Write to R6 is ignored (read-only)
        test_count = test_count + 1;
        $display("[TEST %0d] Write to R6 ignored (read-only)", test_count);
        @(posedge clk);
        i_we = 1'b1; i_waddr = 3'd6; i_wdata = 8'h55;
        @(posedge clk);
        i_we = 1'b0;
        i_raddr_a = 3'd6; #5;
        if (o_rdata_a === 8'h10) begin  // Still reads PC
            $display("  PASS: R6 still reads PC=%h", o_rdata_a);
            pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 10, got %h", o_rdata_a);
        end

        // Test 12: Reset clears all registers
        test_count = test_count + 1;
        $display("[TEST %0d] Reset clears all GPRs", test_count);
        rst_n = 1'b0;
        @(posedge clk); @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        i_raddr_a = 3'd0; #5;
        if (o_rdata_a === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_rdata_a);
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
