// =============================================================================
// Module     : leg_register
// Description: Parameterized synchronous register with load/save for LEG processor
//              Rising-edge triggered, synchronous active-low reset
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of the register (default: 8)
// Ports:
//   clk    - System clock
//   rst_n  - Active-low synchronous reset
//   i_load - Output enable (when high, o_data reflects internal value)
//   i_save - Write enable (when high, internal value captures i_data on posedge)
//   i_data - Data input
//   o_data - Data output
// =============================================================================

module leg_register #(
    parameter DATA_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_load,
    input  wire                     i_save,
    input  wire [DATA_WIDTH-1:0]    i_data,
    output reg  [DATA_WIDTH-1:0]    o_data
);

    reg [DATA_WIDTH-1:0] value;

    // Output logic: when load is high, drive output with internal value;
    // otherwise output zero (tri-state emulation for bus-based designs)
    always @(*) begin
        if (i_load)
            o_data = value;
        else
            o_data = {DATA_WIDTH{1'b0}};
    end

    // Storage logic: synchronous write on positive clock edge
    always @(posedge clk) begin
        if (!rst_n) begin
            value <= {DATA_WIDTH{1'b0}};
        end else if (i_save) begin
            value <= i_data;
        end
    end

endmodule
