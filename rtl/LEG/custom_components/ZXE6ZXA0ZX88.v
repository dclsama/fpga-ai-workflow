module ZXE6ZXA0ZX88 (clk, rst, POP, PUSH, VALUE, OUTPUT);
  parameter UUID = 0;
  parameter NAME = "";
  input wire clk;
  input wire rst;

  input  wire [0:0] POP;
  input  wire [0:0] PUSH;
  input  wire [7:0] VALUE;
  output  wire [7:0] OUTPUT;

  TC_Switch # (.UUID(64'd1488657288217452848 ^ UUID), .BIT_WIDTH(64'd8)) Output8z_0 (.en(wire_0), .in(wire_10[7:0]), .out(OUTPUT));
  TC_Ram # (.UUID(64'd1716867256454592077 ^ UUID), .WORD_WIDTH(64'd8), .WORD_COUNT(64'd256)) Ram_1 (.clk(clk), .rst(rst), .load(wire_0), .save(wire_7), .address({{24{1'b0}}, wire_3 }), .in0({{56{1'b0}}, wire_9 }), .in1(64'd0), .in2(64'd0), .in3(64'd0), .out0(wire_10), .out1(), .out2(), .out3());
  TC_Constant # (.UUID(64'd1130133938084501803 ^ UUID), .BIT_WIDTH(64'd8), .value(8'hFF)) Constant8_2 (.out(wire_8));
  TC_Constant # (.UUID(64'd2340283613083810950 ^ UUID), .BIT_WIDTH(64'd8), .value(8'h1)) Constant8_3 (.out(wire_2));
  TC_Switch # (.UUID(64'd4158354487772880832 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_4 (.en(wire_0), .in(wire_8), .out(wire_5_1));
  TC_Switch # (.UUID(64'd4169744723004828739 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_5 (.en(wire_7), .in(wire_2), .out(wire_5_0));
  TC_Add # (.UUID(64'd3349625031741384105 ^ UUID), .BIT_WIDTH(64'd8)) Add8_6 (.in0(wire_5), .in1(wire_4), .ci(1'd0), .out(wire_6), .co());
  TC_Constant # (.UUID(64'd198643176734037942 ^ UUID), .BIT_WIDTH(64'd1), .value(1'd1)) On_7 (.out(wire_1));
  TC_Register # (.UUID(64'd1411035934897331678 ^ UUID), .BIT_WIDTH(64'd8)) Register8_8 (.clk(clk), .rst(rst), .load(wire_1), .save(wire_1), .in(wire_6), .out(wire_4));
  TC_Switch # (.UUID(64'd3588348918832480552 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_9 (.en(wire_7), .in(wire_4), .out(wire_3_0));
  TC_Switch # (.UUID(64'd4394000090431758227 ^ UUID), .BIT_WIDTH(64'd8)) Switch8_10 (.en(wire_0), .in(wire_6), .out(wire_3_1));

  wire [0:0] wire_0;
  assign wire_0 = POP;
  wire [0:0] wire_1;
  wire [7:0] wire_2;
  wire [7:0] wire_3;
  wire [7:0] wire_3_0;
  wire [7:0] wire_3_1;
  assign wire_3 = wire_3_0|wire_3_1;
  wire [7:0] wire_4;
  wire [7:0] wire_5;
  wire [7:0] wire_5_0;
  wire [7:0] wire_5_1;
  assign wire_5 = wire_5_0|wire_5_1;
  wire [7:0] wire_6;
  wire [0:0] wire_7;
  assign wire_7 = PUSH;
  wire [7:0] wire_8;
  wire [7:0] wire_9;
  assign wire_9 = VALUE;
  wire [63:0] wire_10;

endmodule
