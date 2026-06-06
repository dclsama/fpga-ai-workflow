// =============================================================================
// Module     : leg_dmem
// Description: 256×8-bit data memory for LEG processor
//              Block RAM inference with sync write and combinational read
// =============================================================================
// Parameters:
//   DATA_WIDTH - Memory word width (default: 8)
//   ADDR_WIDTH - Address width (default: 8, 256 locations)
// Ports:
//   clk      - System clock
//   rst_n    - Active-low synchronous reset
//   i_we     - Write enable (active high)
//   i_addr   - Read/write address
//   i_wdata  - Write data
//   o_rdata  - Read data (combinational)
// =============================================================================

module leg_dmem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     i_we,
    input  wire [ADDR_WIDTH-1:0]    i_addr,
    input  wire [DATA_WIDTH-1:0]    i_wdata,
    output wire [DATA_WIDTH-1:0]    o_rdata
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

    // Sync write
    always @(posedge clk) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1)
                mem[i] <= {DATA_WIDTH{1'b0}};
        end else if (i_we) begin
            mem[i_addr] <= i_wdata;
        end
    end

    // Combinational read
    assign o_rdata = mem[i_addr];

endmodule
