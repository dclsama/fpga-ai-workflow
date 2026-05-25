// =============================================================================
// Module     : <module_name>
// Author     : AI-generated
// Description: <brief description of functionality>
// =============================================================================

`timescale 1ns / 1ps
// Parameters:
//   PARAM_NAME - description
// Ports:
//   clk        - System clock
//   rst_n      - Active-low asynchronous reset
//   i_<name>   - Input signals
//   o_<name>   - Output signals
// =============================================================================

module <module_name> #(
    parameter DATA_WIDTH = 8
)(
    input  wire                     clk,
    input  wire                     rst_n,
    // Inputs
    input  wire                     i_enable,
    input  wire [DATA_WIDTH-1:0]    i_data,
    // Outputs
    output wire                     o_valid,
    output wire [DATA_WIDTH-1:0]    o_data
);

    // =========================================================================
    // Internal signals
    // =========================================================================
    reg [DATA_WIDTH-1:0] data_reg;

    // =========================================================================
    // Main logic
    // =========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_reg <= {DATA_WIDTH{1'b0}};
        end else if (i_enable) begin
            data_reg <= i_data;
        end
    end

    // =========================================================================
    // Output assignments
    // =========================================================================
    assign o_valid = i_enable;
    assign o_data  = data_reg;

endmodule
