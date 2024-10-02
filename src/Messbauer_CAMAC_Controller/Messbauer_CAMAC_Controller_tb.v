`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:             Wissance (https://wissance.com)
// Engineer:            EvilLord666 (Ushakov MV - https://github.com/EvilLord666)
// 
// Create Date:         29.06.2023 
// Design Name:         SerialCmdProcessor
// Module Name:         serial_cmd_decoder_tb
// Project Name:        SerialCmdProcessor
// Target Devices:      QMTECH CycloneIV Core Board (EP4CE15F23C8N)
// Tool versions:       Quartus Prime Lite 18.1
// Description:         A Testbench for testing Messbauer_CAMAC_Controller
//
// Dependencies:        Depends on Messbauer_CAMAC_Controller
//
// Revision:            1.0
// Additional Comments: A minimal set of tests
//
//////////////////////////////////////////////////////////////////////////////////

module Messbauer_CAMAC_Controller_tb();

reg  clk;
reg  rx;
wire tx;
reg  rts;
wire cts;
reg  [31:0] counter;
wire tx_led;
wire rx_led;
wire [7:0] led_bus;
wire [5:0] camac_n;
wire [4:0] camac_f;
wire [3:0] camac_a;
reg  camac_x;
reg  camac_q;
wire camac_b;
wire camac_z;
wire camac_c;
wire camac_s1;
wire camac_s2;
wire camac_h;
wire [23:0] camac_w;
reg  [23:0] camac_r;
reg  [22:0] camac_l;
wire camac_i_w;
reg  camac_i_r;
reg  write_op;
wire camac_i;

assign camac_i = write_op == 1'b1 ? camac_i_w : camac_i_r;

Messbauer_CAMAC_Controller camac_controller(.clk(clk), .rs232_rx(rx), .rs232_tx(tx), 
                                            .rs232_cts(cts), .rs232_rts(rts),
                                            .rx_led(rx_led), .tx_led(tx_led), .led_bus(led_bus),
                                            .camac_n(camac_n),   .camac_f(camac_f),   .camac_a(camac_a),
                                            .camac_x(camac_x),   .camac_q(camac_q),   .camac_b(camac_b),
                                            .camac_z(camac_z),   .camac_c(camac_c),   .camac_i(camac_i),
                                            .camac_s1(camac_s1), .camac_s2(camac_s2), .camac_h(camac_h),
                                            .camac_r(camac_r), .camac_w(camac_w), .camac_l(camac_l));

initial
begin
    counter <= 0;
    rx <= 1'b1;
    clk <= 1'b0;
end

always
begin
    #10 clk <= ~clk; // 50 MHz
    counter <= counter + 1;
end

endmodule
