// =============================================================================
// Module     : leg_decoder3
// Description: 3-to-8 decoder with enable for LEG processor
//              Used for register selection and control signal generation
// =============================================================================
// Ports:
//   i_en   - Enable (active high, when low all outputs = 0)
//   i_sel  - 3-bit select input
//   o_y    - 8-bit one-hot output
// =============================================================================

module leg_decoder3 (
    input  wire         i_en,
    input  wire [2:0]   i_sel,
    output reg  [7:0]   o_y
);

    always @(*) begin
        if (!i_en) begin
            o_y = 8'b0000_0000;
        end else begin
            case (i_sel)
                3'd0: o_y = 8'b0000_0001;
                3'd1: o_y = 8'b0000_0010;
                3'd2: o_y = 8'b0000_0100;
                3'd3: o_y = 8'b0000_1000;
                3'd4: o_y = 8'b0001_0000;
                3'd5: o_y = 8'b0010_0000;
                3'd6: o_y = 8'b0100_0000;
                3'd7: o_y = 8'b1000_0000;
                default: o_y = 8'b0000_0000;
            endcase
        end
    end

endmodule
