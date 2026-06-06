// =============================================================================
// Module     : leg_stack
// Description: 256-deep × 8-bit hardware stack for LEG processor
//              Supports PUSH/POP with internal stack pointer
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of stack entries (default: 8)
//   STACK_DEPTH - Number of entries (default: 256, needs 8-bit SP)
// Ports:
//   clk     - System clock
//   rst_n   - Active-low synchronous reset
//   i_push  - Push enable (store i_data, increment SP)
//   i_pop   - Pop enable (decrement SP, read from new SP)
//   i_data  - Data to push onto stack
//   o_data  - Data popped from stack (combinational read at SP-1)
// =============================================================================

module leg_stack #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_push,
    input  wire                     i_pop,
    input  wire [DATA_WIDTH-1:0]    i_data,
    output wire [DATA_WIDTH-1:0]    o_data
);

    localparam DEPTH = 1 << ADDR_WIDTH;

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] sp;        // Stack pointer (points to next free slot)
    reg [ADDR_WIDTH-1:0] sp_next;

    integer i;

    // Stack pointer logic
    always @(posedge clk) begin
        if (!rst_n) begin
            sp <= {ADDR_WIDTH{1'b0}};
        end else begin
            sp <= sp_next;
        end
    end

    // Stack memory (sync write, async read)
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end else if (i_push) begin
            mem[sp] <= i_data;
        end
    end

    // Next state logic for SP
    always @(*) begin
        sp_next = sp;
        if (i_push && !i_pop)
            sp_next = sp + 8'd1;
        else if (!i_push && i_pop)
            sp_next = sp - 8'd1;
        // If both push and pop asserted, SP is unchanged (swap-like behavior)
    end

    // Combinational read: output is value at SP-1 (top of stack after pop,
    // or current top before push)
    assign o_data = mem[sp - 8'd1];

endmodule
