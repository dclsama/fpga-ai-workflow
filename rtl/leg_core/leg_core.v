// =============================================================================
// Module     : leg_core
// Description: LEG Processor Core — integrates PC, decoder, regfile, ALU,
//              stack, and data memory into a complete 8-bit processor
// =============================================================================
// Parameters:
//   DATA_WIDTH - Data path width (default: 8)
//   ADDR_WIDTH - Address width for memories (default: 8)
// Ports:
//   clk            - System clock
//   rst_n          - Active-low synchronous reset
//   i_inst         - 32-bit instruction from program ROM
//   i_input_port   - External 8-bit input port
//   o_pc           - Program counter output (to ROM address)
//   o_output_port  - External 8-bit output port
//   o_output_en    - Output port enable
//   o_halt         - Processor halted
// =============================================================================

module leg_core #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8
) (
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire [31:0]              i_inst,
    input  wire [DATA_WIDTH-1:0]    i_input_port,
    output wire [ADDR_WIDTH-1:0]    o_pc,
    output wire [DATA_WIDTH-1:0]    o_output_port,
    output wire                     o_output_en,
    output wire                     o_halt
);

    // =========================================================================
    // Decoder signals
    // =========================================================================
    wire [2:0]  w_alu_op;
    wire [2:0]  w_reg_raddr_a;
    wire [2:0]  w_reg_raddr_b;
    wire [2:0]  w_reg_waddr;
    wire        w_reg_we;
    wire        w_ram_we;
    wire        w_ram_re;
    wire        w_stack_push;
    wire        w_stack_pop;
    wire        w_pc_jump;
    wire        w_pc_jump_cond;
    wire        w_imm_sel;
    wire [1:0]  w_result_sel;
    wire        w_io_we;
    wire        w_flag_update;
    wire        w_halt;

    // =========================================================================
    // Datapath signals
    // =========================================================================
    wire [DATA_WIDTH-1:0]  w_reg_rdata_a;
    wire [DATA_WIDTH-1:0]  w_reg_rdata_b;
    reg  [DATA_WIDTH-1:0]  w_reg_wdata;
    wire [DATA_WIDTH-1:0]  w_alu_result;
    wire                   w_flag_z, w_flag_c;
    reg  [DATA_WIDTH-1:0]  r_flag_z, r_flag_c;
    wire [DATA_WIDTH-1:0]  w_stack_data;
    wire [DATA_WIDTH-1:0]  w_ram_rdata;
    wire [DATA_WIDTH-1:0]  w_alu_op_b;
    wire [DATA_WIDTH-1:0]  w_pc_val;
    wire [DATA_WIDTH-1:0]  w_jump_target;

    // =========================================================================
    // Instruction Decoder
    // =========================================================================
    leg_decoder u_decoder (
        .clk           (clk),
        .rst_n         (rst_n),
        .i_inst        (i_inst),
        .i_flag_z      (r_flag_z == 1'b1),
        .i_flag_c      (r_flag_c == 1'b1),
        .o_alu_op      (w_alu_op),
        .o_reg_raddr_a (w_reg_raddr_a),
        .o_reg_raddr_b (w_reg_raddr_b),
        .o_reg_waddr   (w_reg_waddr),
        .o_reg_we      (w_reg_we),
        .o_ram_we      (w_ram_we),
        .o_ram_re      (w_ram_re),
        .o_stack_push  (w_stack_push),
        .o_stack_pop   (w_stack_pop),
        .o_pc_jump     (w_pc_jump),
        .o_pc_jump_cond(w_pc_jump_cond),
        .o_imm_sel     (w_imm_sel),
        .o_result_sel  (w_result_sel),
        .o_io_we       (w_io_we),
        .o_flag_update (w_flag_update),
        .o_halt        (w_halt)
    );

    // =========================================================================
    // Register File
    // =========================================================================
    leg_regfile u_regfile (
        .clk       (clk),
        .rst_n     (rst_n),
        .i_raddr_a (w_reg_raddr_a),
        .i_raddr_b (w_reg_raddr_b),
        .i_waddr   (w_reg_waddr),
        .i_we      (w_reg_we),
        .i_wdata   (w_reg_wdata),
        .i_pc      (w_pc_val),
        .i_input   (i_input_port),
        .o_rdata_a (w_reg_rdata_a),
        .o_rdata_b (w_reg_rdata_b)
    );

    // =========================================================================
    // ALU
    // =========================================================================
    // ALU operand B: either register B data or immediate from instruction
    wire [DATA_WIDTH-1:0] w_immediate;
    assign w_immediate  = i_inst[15:8];  // byte1 = immediate field

    assign w_alu_op_b = w_imm_sel ? w_immediate : w_reg_rdata_b;

    leg_alu u_alu (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_op     (w_alu_op),
        .i_a      (w_reg_rdata_a),
        .i_b      (w_alu_op_b),
        .o_result (w_alu_result),
        .o_flag_z (w_flag_z),
        .o_flag_c (w_flag_c)
    );

    // Flag register (updated only on flag-update instructions)
    always @(posedge clk) begin
        if (!rst_n) begin
            r_flag_z <= 1'b0;
            r_flag_c <= 1'b0;
        end else if (w_flag_update) begin
            r_flag_z <= w_flag_z;
            r_flag_c <= w_flag_c;
        end
    end

    // =========================================================================
    // Stack
    // =========================================================================
    leg_stack u_stack (
        .clk    (clk),
        .rst_n  (rst_n),
        .i_push (w_stack_push),
        .i_pop  (w_stack_pop),
        .i_data (w_reg_rdata_a),
        .o_data (w_stack_data)
    );

    // =========================================================================
    // Data Memory
    // =========================================================================
    // Address comes from register A data (for LD/ST, byte1 is the address
    // register select, and reg_rdata_a provides the actual address)
    leg_dmem u_dmem (
        .clk     (clk),
        .rst_n   (rst_n),
        .i_we    (w_ram_we),
        .i_addr  (w_reg_rdata_a),
        .i_wdata (w_reg_rdata_b),
        .o_rdata (w_ram_rdata)
    );

    // =========================================================================
    // Program Counter
    // =========================================================================
    // Jump target comes from byte1 (immediate field) for jumps,
    // or from stack data for RET
    assign w_jump_target = (w_stack_pop && w_pc_jump) ? w_stack_data
                                                    : i_inst[15:8];

    leg_pc u_pc (
        .clk      (clk),
        .rst_n    (rst_n),
        .i_jump   (w_pc_jump || w_halt),   // HALT stops PC via jump-to-self
        .i_target (w_halt ? w_pc_val : w_jump_target),
        .o_pc     (w_pc_val)
    );

    assign o_pc = w_pc_val;

    // =========================================================================
    // Write-back MUX (selects data to write to register file)
    // =========================================================================
    //  00 = ALU result
    //  01 = RAM read data
    //  10 = Stack data
    //  11 = Immediate (for LDI, IN)
    always @(*) begin
        case (w_result_sel)
            2'b00:   w_reg_wdata = w_alu_result;
            2'b01:   w_reg_wdata = w_ram_rdata;
            2'b10:   w_reg_wdata = w_stack_data;
            2'b11:   w_reg_wdata = w_immediate;
            default: w_reg_wdata = w_alu_result;
        endcase
    end

    // =========================================================================
    // I/O Output
    // =========================================================================
    assign o_output_port = w_reg_rdata_a;
    assign o_output_en   = w_io_we;
    assign o_halt        = w_halt;

endmodule
