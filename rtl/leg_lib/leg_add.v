// =============================================================================
// Module     : leg_add
// Description: Parameterized adder with carry in/out for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of input/output data buses (default: 8)
// Ports:
//   i_a  - First operand (augend)
//   i_b  - Second operand (addend)
//   i_ci - Carry in
//   o_y  - Sum result
//   o_co - Carry out
// =============================================================================

module leg_add #(
    parameter DATA_WIDTH = 8
) (
    input  wire [DATA_WIDTH-1:0] i_a,
    input  wire [DATA_WIDTH-1:0] i_b,
    input  wire                   i_ci,
    output wire [DATA_WIDTH-1:0] o_y,
    output wire                   o_co
);

    assign {o_co, o_y} = i_a + i_b + i_ci;

endmodule
