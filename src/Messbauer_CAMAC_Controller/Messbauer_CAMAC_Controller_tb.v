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

localparam reg[31:0] RS232_BIT_TICKS = 50000000 / 115200; // == 434
localparam reg[31:0] EXCHANGE_OFFSET = 1000;

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
    camac_r <= 0;
    camac_l <= 0;
    write_op <= 1'b0;
    // camac_i_r <= 1'b1;
    // camac_x <= 1'b1;
    // camac_q <= 1'b1;
end

always
begin
    #10 clk <= ~clk; // 50 MHz
    counter <= counter + 1;
    // 1. Sending CMD to write module Reg - 0xFF 0xFF 0x00 0x07 0x01 0x07 0x0B 0x04 0x23 0x11 0xD0 0xEE 0xEE
    // 1.1 First  SOF byte - 0xFF
    // start bit
    if (counter == EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 2 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 3 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 4 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 5 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 6 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 7 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 8 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 9 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 10 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 1.2 Second SOF byte - 0xFF
    // start bit
    if (counter == 2 * 11 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 12 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 13 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 14 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 15 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 16 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 17 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 18 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 19 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 20 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 21 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 1.3 Space byte - 0x00
    // start bit
    if (counter == 2 * 22 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 23 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 24 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 25 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 26 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 27 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 28 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 29 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 30 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 31 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 32 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 1.4 Payload len byte - 0x07
    // start bit
    if (counter == 2 * 33 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 34 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 35 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 36 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 37 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 38 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 39 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 40 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 41 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 42 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 43 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 1.5 Payload bytes - 0x01 0x07 0x0B 0x04 0x23 0x11 0xD0
    // 0x01
    // start bit
    if (counter == 2 * 44 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 45 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 46 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 47 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 48 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 49 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 50 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 51 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 52 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 53 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 54 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end

    // 0x07
    // start bit
    if (counter == 2 * 55 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 56 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 57 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 58 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 59 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 60 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 61 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 62 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 63 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 64 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 65 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
 
    // 0x0B
    // start bit
    if (counter == 2 * 66 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 67 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 68 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 69 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 70 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 71 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 72 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 73 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 74 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 75 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 76 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end

    // 0x04
    // start bit
    if (counter == 2 * 77 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 78 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 79 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 80 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 81 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 82 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 83 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 84 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 85 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 86 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 87 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end

    // 0x23
    // start bit
    if (counter == 2 * 88 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 89 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 90 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 91 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 92 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 93 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 94 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 95 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 96 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 97 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 98 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 0x11
    // start bit
    if (counter == 2 * 99 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 100 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 101 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 102 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 103 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 104 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 105 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 106 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 107 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 108 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 109 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 0xD0
    // start bit
    if (counter == 2 * 110 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 111 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 112 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 113 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 114 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 115 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 116 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 117 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 118 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 119 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 120 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 1.6 First  EOF byte - 0xEE
    // start bit
    if (counter == 2 * 121 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 122 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 123 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 124 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 125 * RS232_BIT_TICKS +EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 126 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 127 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 128 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 129 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 130 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 131 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 1.7 Second EOF byte - 0xEE
    // start bit
    if (counter == 2 * 132 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 133 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
       rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 134 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 135 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 136 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 137 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 138 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 139 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 140 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 141 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 142 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // 2. Sending CMD to read  module Reg
    // 3. Sendign CMD to read  LAM status
end

endmodule
