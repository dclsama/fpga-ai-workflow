// =============================================================================
// Module     : leg_program_rom
// Description: Program ROM for LEG processor — loads binary from file
//              Supports $readmemh for standard hex file loading
// =============================================================================
// Parameters:
//   DATA_WIDTH - Width of each instruction chunk (default: 8)
//   ADDR_WIDTH - Address width (default: 8, 256 locations)
//   INIT_FILE  - Hex initialization file (default: "program.hex")
// Ports:
//   clk     - System clock
//   rst_n   - Active-low synchronous reset
//   i_addr  - Read address (byte address)
//   o_data  - Read data (4 × DATA_WIDTH = 32-bit instruction)
// =============================================================================

module leg_program_rom #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter INIT_FILE  = "program.hex"
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [ADDR_WIDTH-1:0]    i_addr,
    output reg  [4*DATA_WIDTH-1:0]  o_data
);

    localparam DEPTH = 1 << ADDR_WIDTH;
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    integer i;

    // Initialize memory from hex file
    initial begin
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = {DATA_WIDTH{1'b0}};
        $readmemh(INIT_FILE, mem);
    end

    // Combinational read of 4 consecutive bytes (32-bit instruction)
    always @(*) begin
        if (!rst_n) begin
            o_data = {4*DATA_WIDTH{1'b0}};
        end else begin
            o_data = { mem[i_addr+3],
                       mem[i_addr+2],
                       mem[i_addr+1],
                       mem[i_addr] };
        end
    end

endmodule
