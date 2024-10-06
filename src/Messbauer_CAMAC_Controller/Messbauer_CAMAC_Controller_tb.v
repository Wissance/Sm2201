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
    camac_i_r <= 1'b1;
    camac_x <= 1'b1;
    camac_q <= 1'b1;
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

    // todo(UMV): Add some checks
    if (counter == 154988)
    begin
        camac_x <= 1'b0;
        camac_q <= 1'b0;
    end
    if (counter == 155060)
    begin
        camac_x <= 1'b1;
        camac_q <= 1'b1;
    end

    // 2. Sending CMD to read module Reg - 0xFF 0xFF 0x00 0x04 0x02 0x14 0x0E 0x09 0xEE 0xEE
    // 2.1 First  SOF byte - 0xFF
    // start bit
    if (counter == 2 * 300 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 301 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 302 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 303 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 304 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 305 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 306 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 307 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 308 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 309 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 310 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 2.2 Second SOF byte - 0xFF
    // start bit
    if (counter == 2 * 311 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 312 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 313 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 314 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 315 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 316 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 317 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 318 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 319 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 320 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 321 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 2.3 Space byte - 0x00
    // start bit
    if (counter == 2 * 322 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 323 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 324 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 325 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 326 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 327 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 328 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 329 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 330 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 331 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 332 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 2.4 Payload len byte - 0x04
    // start bit
    if (counter == 2 * 333 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 334 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 335 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 336 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 337 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 338 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 339 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 340 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 341 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 342 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 343 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 2.5 Payload bytes - 0x02 0x14 0x0E 0x09
    // 0x02
    // start bit
    if (counter == 2 * 344 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 345 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 346 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 347 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 348 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 349 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 350 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 351 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 352 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 353 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 354 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 0x14
    // start bit
    if (counter == 2 * 355 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 356 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 357 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 358 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 359 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 360 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 361 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 362 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 363 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 364 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 365 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
 
    // 0x0E
    // start bit
    if (counter == 2 * 366 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 367 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 368 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 369 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 370 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 371 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 372 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 373 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 374 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 375 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 376 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 0x09
    // start bit
    if (counter == 2 * 377 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 378 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 379 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 380 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 381 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 382 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 383 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 384 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 385 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 386 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 387 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 2.6 First  EOF byte - 0xEE
    // start bit
    if (counter == 2 * 388 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 389 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 390 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 391 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 392 * RS232_BIT_TICKS +EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 393 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 394 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 395 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 396 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 397 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 398 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 2.7 Second EOF byte - 0xEE
    // start bit
    if (counter == 2 * 399 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 400 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 401 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 402 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 403 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 404 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 405 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 406 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 407 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 408 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 409 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // todo(UMV): Add some checks
    if(counter == 2 * 400 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        camac_r[7:0] <= 8'hAA;
        camac_r[15:8] <= 8'hBB;
        camac_r[23:16] <= 8'hCC;
    end

    // 3. Sendign CMD to read LAM status 0xFF 0xFF 0x00 0x01 0x03 0xEE 0xEE
    // 3.1 First  SOF byte - 0xFF
    // start bit
    if (counter == 2 * 600 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 601 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 602 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 603 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 604 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 605 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 606 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 607 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 608 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 609 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 610 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 3.2 Second SOF byte - 0xFF
    // start bit
    if (counter == 2 * 611 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 612 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 613 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 614 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 615 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 616 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 617 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 618 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 619 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 620 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 621 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 3.3 Space byte - 0x00
    // start bit
    if (counter == 2 * 622 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 623 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 624 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 625 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 626 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 627 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 628 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 629 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 630 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 631 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 632 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 3.4 Payload len byte - 0x01
    // start bit
    if (counter == 2 * 633 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 634 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 635 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 636 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 637 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 638 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 639 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 640 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 641 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 642 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 643 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 3.5 Payload bytes - 0x03
    // 0x03
    // start bit
    if (counter == 2 * 644 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 645 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 646 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 647 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 648 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 649 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 650 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 651 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 652 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 653 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 654 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 3.6 First  EOF byte - 0xEE
    // start bit
    if (counter == 2 * 655 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 656 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 657 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 658 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 659 * RS232_BIT_TICKS +EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 660 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 661 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 662 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 663 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 664 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 665 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 3.7 Second EOF byte - 0xEE
    // start bit
    if (counter == 2 * 666 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 667 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 668 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 669 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 670 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 671 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 672 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 673 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 674 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 675 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 676 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // todo(UMV): Add some checks
        // todo(UMV): Add some checks
    if(counter == 2 * 670 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        camac_l[7:0] <= 8'h04;
        camac_l[15:8] <= 8'h00;
        camac_l[23:16] <= 8'h20;
    end

    // 4. Sendign Unknown CMD 0xFF 0xFF 0x00 0x01 0x04 0xEE 0xEE
    // 4.1 First  SOF byte - 0xFF
    // start bit
    if (counter == 2 * 900 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 901 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 902 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 903 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 904 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 905 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 906 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 907 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 908 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 909 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 910 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 4.2 Second SOF byte - 0xFF
    // start bit
    if (counter == 2 * 911 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 912 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 913 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 914 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 915 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 916 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 917 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 918 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 919 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 920 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 921 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 4.3 Space byte - 0x00
    // start bit
    if (counter == 2 * 922 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 923 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 924 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 925 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 926 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 927 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 928 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 929 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 930 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 931 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 932 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 4.4 Payload len byte - 0x01
    // start bit
    if (counter == 2 * 933 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 934 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 935 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 936 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 937 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 938 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 939 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 940 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 941 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 942 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 943 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 4.5 Payload bytes - 0x04
    // 0x04
    // start bit
    if (counter == 2 * 944 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 945 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 946 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 947 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 948 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 949 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 950 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 951 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 952 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 953 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 954 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 4.6 First  EOF byte - 0xEE
    // start bit
    if (counter == 2 * 955 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 956 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 957 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 958 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 959 * RS232_BIT_TICKS +EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 960 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 961 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 962 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 963 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 964 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 965 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 4.7 Second EOF byte - 0xEE
    // start bit
    if (counter == 2 * 966 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 967 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 968 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 969 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 970 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 971 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 972 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 973 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 974 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 975 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 976 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // todo(UMV): Add some checks

    // 5. Sending CMD to read module Reg - 0xFF 0xFF 0x00 0x04 0x02 0x14 0x0E 0x09 0xEE 0xEE
    // 5.1 First  SOF byte - 0xFF
    // start bit
    if (counter == 2 * 1300 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1301 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 1302 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 1303 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1304 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 1305 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 1306 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 1307 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 1308 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 1309 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1310 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 5.2 Second SOF byte - 0xFF
    // start bit
    if (counter == 2 * 1311 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1312 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 1313 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 1314 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1315 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 1316 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 1317 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 1318 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 1319 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 1320 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1321 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 5.3 Space byte - 0x00
    // start bit
    if (counter == 2 * 1322 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1323 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1324 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 1325 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 1326 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 1327 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1328 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 1329 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 1330 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 1331 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1332 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 5.4 Payload len byte - 0x04
    // start bit
    if (counter == 2 * 1333 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1334 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1335 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 1336 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1337 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 1338 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1339 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 1340 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 1341 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 1342 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 1343 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 5.5 Payload bytes - 0x02 0x14 0x0E 0x09
    // 0x02
    // start bit
    if (counter == 2 * 1344 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1345 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1346 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 1347 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 1348 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 1349 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1350 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 1351 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 1352 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 1353 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 1354 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 0x14
    // start bit
    if (counter == 2 * 1355 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1356 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1357 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 1358 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1359 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b4
    if (counter == 2 * 1360 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // b5
    if (counter == 2 * 1361 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 1362 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 1363 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 1364 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1365 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
 
    // 0x0E
    // start bit
    if (counter == 2 * 1366 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1367 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1368 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 1369 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1370 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 1371 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1372 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 1373 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 1374 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 1375 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // stop bit
    if (counter == 2 * 1376 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 0x09
    // start bit
    if (counter == 2 * 1377 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1378 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b1;
    end
    // b1
    if (counter == 2 * 1379 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b2
    if (counter == 2 * 1380 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b3
    if (counter == 2 * 1381 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 1382 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1383 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b6
    if (counter == 2 * 1384 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b7
    if (counter == 2 * 1385 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // parity (even)
    if (counter == 2 * 1386 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1387 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // 5.6 First  EOF byte - 0xEE
    // start bit
    if (counter == 2 * 1388 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1389 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1390 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 1391 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1392 * RS232_BIT_TICKS +EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 1393 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1394 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 1395 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 1396 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 1397 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1398 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // 5.7 Second EOF byte - 0xEE
    // start bit
    if (counter == 2 * 1399 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0; 
    end
    // b0
    if (counter == 2 * 1400 * RS232_BIT_TICKS + EXCHANGE_OFFSET)  // we multiply on 2 because counter changes twice a period
    begin
        rx <= 1'b0;
    end
    // b1
    if (counter == 2 * 1401 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b2
    if (counter == 2 * 1402 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b3
    if (counter == 2 * 1403 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b4
    if (counter == 2 * 1404 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // b5
    if (counter == 2 * 1405 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b6
    if (counter == 2 * 1406 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end
    // b7
    if (counter == 2 * 1407 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
       rx <= 1'b1;
    end
    // parity (even)
    if (counter == 2 * 1408 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b0;
    end
    // stop bit
    if (counter == 2 * 1409 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        rx <= 1'b1;
    end

    // todo(UMV): Add some checks
    if(counter == 2 * 1400 * RS232_BIT_TICKS + EXCHANGE_OFFSET)
    begin
        camac_r[7:0] <= 8'h23;
        camac_r[15:8] <= 8'h45;
        camac_r[23:16] <= 8'h67;
    end

end

endmodule
