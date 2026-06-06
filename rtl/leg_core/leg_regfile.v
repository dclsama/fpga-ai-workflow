// =============================================================================
// Module     : leg_regfile
// Description: 8×8-bit register file with 2 read ports and 1 write port
//              Registers: R0-R5 (GPR), R6=PC (read-only), R7=INPUT (read-only)
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of each register (default: 8)
// Ports:
//   clk      - System clock
//   rst_n    - Active-low synchronous reset
//   i_raddr_a - Read port A address (3 bits)
//   i_raddr_b - Read port B address (3 bits)
//   i_waddr   - Write port address (3 bits)
//   i_we      - Write enable
//   i_wdata   - Write data
//   i_pc      - Program counter value (for R6 read)
//   i_input   - External input port value (for R7 read)
//   o_rdata_a - Read port A data
//   o_rdata_b - Read port B data
// =============================================================================

module leg_regfile #(
    parameter DATA_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [2:0]               i_raddr_a,
    input  wire [2:0]               i_raddr_b,
    input  wire [2:0]               i_waddr,
    input  wire                     i_we,
    input  wire [DATA_WIDTH-1:0]    i_wdata,
    input  wire [DATA_WIDTH-1:0]    i_pc,
    input  wire [DATA_WIDTH-1:0]    i_input,
    output reg  [DATA_WIDTH-1:0]    o_rdata_a,
    output reg  [DATA_WIDTH-1:0]    o_rdata_b
);

    // 6 GPR registers (R0-R5)
    reg [DATA_WIDTH-1:0] regs [0:5];
    integer i;

    // Write operation (sync, on posedge clk)
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < 6; i = i + 1)
                regs[i] <= {DATA_WIDTH{1'b0}};
        end else if (i_we && (i_waddr < 3'd6)) begin
            regs[i_waddr] <= i_wdata;
        end
    end

    // Read operations (combinational)
    always @(*) begin
        // Read port A
        case (i_raddr_a)
            3'd0, 3'd1, 3'd2, 3'd3, 3'd4, 3'd5:
                o_rdata_a = regs[i_raddr_a];
            3'd6: o_rdata_a = i_pc;       // PC (read-only)
            3'd7: o_rdata_a = i_input;    // INPUT port (read-only)
            default: o_rdata_a = {DATA_WIDTH{1'b0}};
        endcase

        // Read port B
        case (i_raddr_b)
            3'd0, 3'd1, 3'd2, 3'd3, 3'd4, 3'd5:
                o_rdata_b = regs[i_raddr_b];
            3'd6: o_rdata_b = i_pc;       // PC (read-only)
            3'd7: o_rdata_b = i_input;    // INPUT port (read-only)
            default: o_rdata_b = {DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
