// =============================================================================
// Module     : leg_neg
// Description: Parameterized two's complement negation for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input/output data buses (default: 8)
// Ports:
//   i_a  - Input operand
//   o_y  - Two's complement negation result
// =============================================================================

module leg_neg #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    output wire [DATA_WIDTH-1:0] o_y
);

    assign o_y = {DATA_WIDTH{1'b0}} - i_a;

endmodule
