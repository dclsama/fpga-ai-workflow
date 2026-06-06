// =============================================================================
// Module     : leg_shr
// Description: Parameterized logical shift right for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input/output data buses (default: 8)
// Ports:
//   i_a     - Data to shift
//   i_shift - Shift amount (truncated to log2(DATA_WIDTH) bits)
//   o_y     - Shifted result (zero-filled)
// =============================================================================

module leg_shr #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    input  wire [7:0]            i_shift,
    output wire [DATA_WIDTH-1:0] o_y
);

    assign o_y = i_a >> i_shift;

endmodule
