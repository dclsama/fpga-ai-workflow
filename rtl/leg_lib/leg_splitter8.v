// =============================================================================
// Module     : leg_splitter8
// Description: 8-bit splitter — extracts individual bits from a byte
//              Used in instruction decoding for bit-field extraction
// =============================================================================
// Ports:
//   i_data - 8-bit input data
//   o_b0   - Bit 0 (LSB)
//   o_b1   - Bit 1
//   o_b2   - Bit 2
//   o_b3   - Bit 3
//   o_b4   - Bit 4
//   o_b5   - Bit 5
//   o_b6   - Bit 6
//   o_b7   - Bit 7 (MSB)
// =============================================================================

module leg_splitter8 (
    input  wire [7:0] i_data,
    output wire       o_b0,
    output wire       o_b1,
    output wire       o_b2,
    output wire       o_b3,
    output wire       o_b4,
    output wire       o_b5,
    output wire       o_b6,
    output wire       o_b7
);

    assign {o_b7, o_b6, o_b5, o_b4, o_b3, o_b2, o_b1, o_b0} = i_data;

endmodule
