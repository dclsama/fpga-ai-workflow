// =============================================================================
// Module     : leg_lessu
// Description: Parameterized unsigned less-than comparator for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input data buses (default: 8)
// Ports:
//   i_a  - First operand (left side of comparison)
//   i_b  - Second operand (right side of comparison)
//   o_y  - Result (1 = i_a < i_b, 0 = i_a >= i_b)
// =============================================================================

module leg_lessu #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    input  wire [DATA_WIDTH-1:0] i_b,
    output wire                   o_y
);

    assign o_y = (i_a < i_b);

endmodule
