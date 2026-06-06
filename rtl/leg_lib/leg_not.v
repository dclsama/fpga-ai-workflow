// =============================================================================
// Module     : leg_not
// Description: Parameterized bitwise NOT gate for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input/output data buses (default: 8)
// Ports:
//   i_a  - Input operand
//   o_y  - Bitwise NOT result
// =============================================================================

module leg_not #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    output wire [DATA_WIDTH-1:0] o_y
);

    assign o_y = ~i_a;

endmodule
