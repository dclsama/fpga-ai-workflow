// =============================================================================
// Module     : leg_or3
// Description: Parameterized 3-input bitwise OR gate for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input/output data buses (default: 8)
// Ports:
//   i_a  - First operand
//   i_b  - Second operand
//   i_c  - Third operand
//   o_y  - Bitwise OR result
// =============================================================================

module leg_or3 #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    input  wire [DATA_WIDTH-1:0] i_b,
    input  wire [DATA_WIDTH-1:0] i_c,
    output wire [DATA_WIDTH-1:0] o_y
);

    assign o_y = i_a | i_b | i_c;

endmodule
