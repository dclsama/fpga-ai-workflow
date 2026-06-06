// =============================================================================
// Module     : leg_pc
// Description: Program Counter for LEG processor
//              8-bit PC, increments by 4 (32-bit instruction alignment)
//              Supports unconditional and conditional jumps
// =============================================================================
// Parameters:
//   DATA_WIDTH - PC width (default: 8)
//   STEP       - Increment per instruction (default: 4)
// Ports:
//   clk       - System clock
//   rst_n     - Active-low synchronous reset
//   i_jump    - Jump enable
//   i_target  - Jump target address
//   o_pc      - Current program counter value
// =============================================================================

module leg_pc #(
    parameter DATA_WIDTH = 8,
    parameter STEP       = 4
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_jump,
    input  wire [DATA_WIDTH-1:0]    i_target,
    output reg  [DATA_WIDTH-1:0]    o_pc
);

    reg [DATA_WIDTH-1:0] pc_next;

    // The PC behavior matches the original LEG TC_Counter:
    //   o_pc shows the "current" value, pc_next holds the next incremental value.
    //   On reset: both = 0.
    //   On jump: o_pc = target, pc_next = target + STEP.
    //   On normal cycle: o_pc = pc_next, pc_next += STEP.
    always @(posedge clk) begin
        if (!rst_n) begin
            o_pc    <= {DATA_WIDTH{1'b0}};
            pc_next <= {DATA_WIDTH{1'b0}};
        end else begin
            if (i_jump) begin
                o_pc    <= i_target;
                pc_next <= i_target + STEP;
            end else begin
                o_pc    <= pc_next;
                pc_next <= pc_next + STEP;
            end
        end
    end

endmodule
