// =============================================================================
// Module     : leg_alu
// Description: 8-bit Arithmetic Logic Unit for LEG processor
//              Supports ADD/SUB/AND/OR/NOT/XOR/SHL/SHR and comparisons
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of operands (default: 8)
// Ports:
//   clk      - System clock
//   rst_n    - Active-low synchronous reset
//   i_op     - Operation select (3 bits)
//             000: ADD, 001: SUB, 010: AND, 011: OR
//             100: NOT, 101: XOR, 110: SHL, 111: SHR
//   i_a      - Operand A
//   i_b      - Operand B
//   o_result - ALU result
//   o_flag_z - Zero flag (result == 0)
//   o_flag_c - Carry/Borrow flag
// =============================================================================

module leg_alu #(
    parameter DATA_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [2:0]               i_op,
    input  wire [DATA_WIDTH-1:0]    i_a,
    input  wire [DATA_WIDTH-1:0]    i_b,
    output reg  [DATA_WIDTH-1:0]    o_result,
    output reg                      o_flag_z,
    output reg                      o_flag_c
);

    // Operation encoding
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_NOT = 3'b100;
    localparam OP_XOR = 3'b101;
    localparam OP_SHL = 3'b110;
    localparam OP_SHR = 3'b111;

    // Internal signals
    wire [DATA_WIDTH:0] add_result;    // {carry, sum}
    wire [DATA_WIDTH:0] sub_result;    // {borrow, diff}

    // ADD: {carry, sum}
    assign add_result = {1'b0, i_a} + {1'b0, i_b};

    // SUB: {borrow, diff}
    assign sub_result = {1'b0, i_a} - {1'b0, i_b};

    // Combinational ALU
    always @(*) begin
        // Defaults
        o_result = {DATA_WIDTH{1'b0}};
        o_flag_z = 1'b0;
        o_flag_c = 1'b0;

        case (i_op)
            OP_ADD: begin
                o_result = add_result[DATA_WIDTH-1:0];
                o_flag_z = (add_result[DATA_WIDTH-1:0] == {DATA_WIDTH{1'b0}});
                o_flag_c = add_result[DATA_WIDTH];
            end

            OP_SUB: begin
                o_result = sub_result[DATA_WIDTH-1:0];
                o_flag_z = (sub_result[DATA_WIDTH-1:0] == {DATA_WIDTH{1'b0}});
                o_flag_c = sub_result[DATA_WIDTH];  // borrow indicator
            end

            OP_AND: begin
                o_result = i_a & i_b;
                o_flag_z = (o_result == {DATA_WIDTH{1'b0}});
            end

            OP_OR: begin
                o_result = i_a | i_b;
                o_flag_z = (o_result == {DATA_WIDTH{1'b0}});
            end

            OP_NOT: begin
                o_result = ~i_a;
                o_flag_z = (o_result == {DATA_WIDTH{1'b0}});
            end

            OP_XOR: begin
                o_result = i_a ^ i_b;
                o_flag_z = (o_result == {DATA_WIDTH{1'b0}});
            end

            OP_SHL: begin
                o_result = i_a << i_b[2:0];
                o_flag_z = (o_result == {DATA_WIDTH{1'b0}});
            end

            OP_SHR: begin
                o_result = i_a >> i_b[2:0];
                o_flag_z = (o_result == {DATA_WIDTH{1'b0}});
            end

            default: begin
                o_result = {DATA_WIDTH{1'b0}};
                o_flag_z = 1'b0;
                o_flag_c = 1'b0;
            end
        endcase
    end

endmodule
