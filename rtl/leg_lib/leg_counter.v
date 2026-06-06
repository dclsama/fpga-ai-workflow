// =============================================================================
// Module     : leg_counter
// Description: Parameterized synchronous counter with configurable step for LEG processor
//              Used as program counter and stack pointer
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of the counter (default: 8)
//   STEP       - Increment value on each count (default: 4 for 32-bit instructions)
// Ports:
//   clk    - System clock
//   rst_n  - Active-low synchronous reset
//   i_save - Load enable (when high, counter loads i_data)
//   i_data - Parallel load value
//   o_count - Counter output
// =============================================================================

module leg_counter #(
    parameter DATA_WIDTH = 8,
    parameter STEP       = 4
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_save,
    input  wire [DATA_WIDTH-1:0]    i_data,
    output reg  [DATA_WIDTH-1:0]    o_count
);

    reg [DATA_WIDTH-1:0] value;

    always @(posedge clk) begin
        if (!rst_n) begin
            value   <= {DATA_WIDTH{1'b0}};
            o_count <= {DATA_WIDTH{1'b0}};
        end else begin
            if (i_save) begin
                // Load new value (jump)
                value   <= i_data + STEP;
                o_count <= i_data;
            end else begin
                // Increment
                o_count <= value;
                value   <= value + STEP;
            end
        end
    end

endmodule
