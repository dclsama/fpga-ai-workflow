// =============================================================================
// Module     : leg_ram
// Description: Parameterized synchronous Block RAM for LEG processor
//              Single-port: sync write, async read (Block RAM compatible)
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of each memory word (default: 8)
//   ADDR_WIDTH - Address width (default: 8, giving 256 locations)
// Ports:
//   clk     - System clock
//   rst_n   - Active-low synchronous reset
//   i_we    - Write enable (active high)
//   i_addr  - Read/write address
//   i_wdata - Write data
//   o_rdata - Read data (combinational)
// =============================================================================

module leg_ram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_we,
    input  wire [ADDR_WIDTH-1:0]    i_addr,
    input  wire [DATA_WIDTH-1:0]    i_wdata,
    output reg  [DATA_WIDTH-1:0]    o_rdata
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

    // Async read (combinational) — infers Block RAM read port
    always @(*) begin
        o_rdata = mem[i_addr];
    end

    // Sync write on positive clock edge — infers Block RAM write port
    always @(posedge clk) begin
        if (!rst_n) begin
            // Synchronous reset: clear memory (synthesis may optimize to initial block)
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end else if (i_we) begin
            mem[i_addr] <= i_wdata;
        end
    end

endmodule
