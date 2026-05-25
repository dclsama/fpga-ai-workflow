// =============================================================================
// Module     : counter
// Description: 8-bit up counter with enable. Counts from 0 to 255, wraps to 0.
// =============================================================================

`timescale 1ns / 1ps
// Ports:
//   clk      - System clock
//   rst_n    - Active-low asynchronous reset
//   i_en     - Count enable (1 = count up on posedge clk)
//   o_count  - Current count value
// =============================================================================

module counter #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst_n,
    input  wire             i_en,
    output wire [WIDTH-1:0] o_count
);

    // =========================================================================
    // Internal signals
    // =========================================================================
    reg [WIDTH-1:0] count;

    // =========================================================================
    // Counter logic
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= {WIDTH{1'b0}};
        end else if (i_en) begin
            count <= count + 1'b1;
        end
    end

    // =========================================================================
    // Output assignments
    // =========================================================================
    assign o_count = count;

endmodule
