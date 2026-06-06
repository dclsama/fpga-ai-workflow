// =============================================================================
// Module     : leg_top
// Description: LEG Processor Top-Level — core + program ROM + I/O interface
//              Compatible with the original LEG I/O port interface
// =============================================================================
// Parameters:
//   DATA_WIDTH  - Data path width (default: 8)
//   ADDR_WIDTH  - Address width for memories (default: 8)
//   INIT_FILE   - Program hex file for ROM initialization
// Ports:
//   clk                - System clock
//   rst_n              - Active-low synchronous reset
//   i_input_port       - External 8-bit input
//   o_output_port      - External 8-bit output
//   o_output_en        - Output enable
//   o_halt             - Processor halted
// =============================================================================

module leg_top #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter INIT_FILE  = "program.hex"
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [DATA_WIDTH-1:0]    i_input_port,
    output wire [DATA_WIDTH-1:0]    o_output_port,
    output wire                     o_output_en,
    output wire                     o_halt
);

    // =========================================================================
    // Internal signals
    // =========================================================================
    wire [ADDR_WIDTH-1:0]  w_pc;
    wire [31:0]            w_inst;

    // =========================================================================
    // Program ROM
    // =========================================================================
    leg_program_rom #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .INIT_FILE(INIT_FILE)
    ) u_rom (
        .clk    (clk),
        .rst_n  (rst_n),
        .i_addr (w_pc),
        .o_data (w_inst)
    );

    // =========================================================================
    // Processor Core
    // =========================================================================
    leg_core #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_core (
        .clk           (clk),
        .rst_n         (rst_n),
        .i_inst        (w_inst),
        .i_input_port  (i_input_port),
        .o_pc          (w_pc),
        .o_output_port (o_output_port),
        .o_output_en   (o_output_en),
        .o_halt        (o_halt)
    );

endmodule
