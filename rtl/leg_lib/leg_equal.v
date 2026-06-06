// =============================================================================
// Module     : leg_equal
// Description: Parameterized equality comparator for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input data buses (default: 8)
// Ports:
//   i_a  - First operand
//   i_b  - Second operand
//   o_y  - Equality result (1 = equal, 0 = not equal)
// =============================================================================

module leg_equal #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    input  wire [DATA_WIDTH-1:0] i_b,
    output wire                   o_y
);

    assign o_y = (i_a == i_b);

endmodule
