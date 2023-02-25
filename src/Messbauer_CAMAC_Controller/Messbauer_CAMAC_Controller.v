//////////////////////////////////////////////////////////////////////////////////
// Company:        Wissance (https://wissance.com)
// Engineer:       EvilLord666 (Ushakov MV)
// 
// Create Date:    22/12/2022 
// Design Name: 
// Module Name:    Messbauer_CAMAC_Controller
// Project Name:   Messbauer_CAMAC_Controller
// Target Devices: Cyclone IV ()
// Tool versions:  Quartus Prime Lite 18.1
// Description:    Новый Camac-контроллер с RS-232 интерфейсом управления
//
// Dependencies: 
//
// Revision: 
// Revision 1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Messbauer_CAMAC_Controller #
(
    CAMAC_DATA_WIDTH = 24,
    CAMAC_FUNC_WIDTH = 5,
    MESSB_ACC_ADDRESS_WIDTH = 12
)
(
    // Общие сигналы управления: тактовая частота и чигнал сброса
    input wire clk,
    input wire rst,


    // CAMAC-сигналы
    // Сигналы управления адресацией юю
    input [CAMAC_FUNC_WIDTH-1:0] camac_f,

    input camac_s1,
    output reg [CAMAC_DATA_WIDTH-1:0] read,  // should be input && rename
    output reg [CAMAC_DATA_WIDTH-1:0] write,
    output reg camac_x,
    output reg camac_q,
    

    output reg trig  // ?
);


endmodule
