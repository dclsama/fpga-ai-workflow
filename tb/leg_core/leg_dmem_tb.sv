// =============================================================================
// Testbench  : leg_dmem_tb
// Module DUT : leg_dmem
// Description: Self-checking testbench for 256×8 data memory
// =============================================================================

`timescale 1ns / 1ps

module leg_dmem_tb;

    parameter CLK_PERIOD = 10;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 8;

    reg                     clk;
    reg                     rst_n;
    reg                     i_we;
    reg  [ADDR_WIDTH-1:0]   i_addr;
    reg  [DATA_WIDTH-1:0]   i_wdata;
    wire [DATA_WIDTH-1:0]   o_rdata;

    leg_dmem #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .i_we   (i_we),
        .i_addr (i_addr),
        .i_wdata(i_wdata),
        .o_rdata(o_rdata)
    );

    initial begin
        $dumpfile("leg_dmem_tb.vcd");
        $dumpvars(0, leg_dmem_tb);
    end

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        integer test_count, pass_count;
        integer i;
        test_count = 0; pass_count = 0;

        rst_n = 1'b0; i_we = 1'b0; i_addr = 8'h00; i_wdata = 8'h00;
        repeat(3) @(posedge clk);
        rst_n = 1'b1;
        repeat(1) @(posedge clk);

        // Test 1: Read after reset returns 0
        test_count = test_count + 1;
        $display("[TEST %0d] Read addr 0 after reset = 0", test_count);
        i_addr = 8'h00; #5;
        if (o_rdata === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_rdata);
        end

        // Test 2: Write and read back
        test_count = test_count + 1;
        $display("[TEST %0d] Write A5 to addr 0x10, read back", test_count);
        @(posedge clk);
        i_we = 1'b1; i_addr = 8'h10; i_wdata = 8'hA5;
        @(posedge clk);
        i_we = 1'b0;
        i_addr = 8'h10; #5;
        if (o_rdata === 8'hA5) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected A5, got %h", o_rdata);
        end

        // Test 3: Write doesn't affect other addresses
        test_count = test_count + 1;
        $display("[TEST %0d] Write to 0x10 doesn't affect 0x11", test_count);
        i_addr = 8'h11; #5;
        if (o_rdata === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_rdata);
        end

        // Test 4: Write to max address
        test_count = test_count + 1;
        $display("[TEST %0d] Write to addr 0xFF", test_count);
        @(posedge clk);
        i_we = 1'b1; i_addr = 8'hFF; i_wdata = 8'h77;
        @(posedge clk);
        i_we = 1'b0;
        i_addr = 8'hFF; #5;
        if (o_rdata === 8'h77) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 77, got %h", o_rdata);
        end

        // Test 5: Overwrite previously written address
        test_count = test_count + 1;
        $display("[TEST %0d] Overwrite addr 0x10 with 0x5A", test_count);
        @(posedge clk);
        i_we = 1'b1; i_addr = 8'h10; i_wdata = 8'h5A;
        @(posedge clk);
        i_we = 1'b0;
        i_addr = 8'h10; #5;
        if (o_rdata === 8'h5A) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 5A, got %h", o_rdata);
        end

        // Test 6: Reset clears memory
        test_count = test_count + 1;
        $display("[TEST %0d] Reset clears memory", test_count);
        rst_n = 1'b0;
        @(posedge clk); @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        i_addr = 8'h10; #5;
        if (o_rdata === 8'h00) begin
            $display("  PASS"); pass_count = pass_count + 1;
        end else begin
            $error("  FAIL: expected 00, got %h", o_rdata);
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
