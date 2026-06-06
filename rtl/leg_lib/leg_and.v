// =============================================================================
// Module     : leg_and
// Description: Parameterized bitwise AND gate for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input/output data buses (default: 8)
// Ports:
//   i_a  - First operand
//   i_b  - Second operand
//   o_y  - Bitwise AND result
// =============================================================================

module leg_and #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    input  wire [DATA_WIDTH-1:0] i_b,
    output wire [DATA_WIDTH-1:0] o_y
);

    assign o_y = i_a & i_b;

endmodule
