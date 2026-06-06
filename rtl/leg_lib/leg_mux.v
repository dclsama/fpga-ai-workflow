// =============================================================================
// Module     : leg_mux
// Description: Parameterized 2-to-1 multiplexer for LEG processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of data paths (default: 8)
// Ports:
//   i_sel - Select (0 = i_a, 1 = i_b)
//   i_a   - Input A (selected when i_sel = 0)
//   i_b   - Input B (selected when i_sel = 1)
//   o_y   - Selected output
// =============================================================================

module leg_mux #(
    parameter DATA_WIDTH = 8
) (
    input  wire                   i_sel,
    input  wire [DATA_WIDTH-1:0]  i_a,
    input  wire [DATA_WIDTH-1:0]  i_b,
    output reg  [DATA_WIDTH-1:0]  o_y
);

    always @(*) begin
        case (i_sel)
            1'b0: o_y = i_a;
            1'b1: o_y = i_b;
            default: o_y = {DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
