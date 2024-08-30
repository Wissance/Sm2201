//////////////////////////////////////////////////////////////////////////////////
// Company:        Wissance (https://wissance.com)
// Engineer:       EvilLord666 (Ushakov MV)
// 
// Create Date:    22/12/2022 
// Design Name: 
// Module Name:    Messbauer_CAMAC_Controller
// Project Name:   Messbauer_CAMAC_Controller
// Target Devices: Cyclone IV (EP4CE15F23C8N)
// Tool versions:  Quartus Prime Lite 18.1
// Description:    Новый Camac-контроллер с RS-232 интерфейсом управления
//
// Dependencies:   1. quick_rs232 (модуль последовательного порта - https://github.com/Wissance/QuickRS232)
//                 2. fifo (модуль буфера First In First Out - https://github.com/Wissance/QuickRS232)
//                 3. serial_cmd_decoder (декодер команд, пример - https://github.com/Wissance/QmtechCycloneIVBoardDemos/blob/master/SerialPortWithCmdProcessor/serial_cmd_decoder.v)
//                 4. camac_controller_exchanger (модуль управления циклом CAMAC)
// Revision:       1.0
// Additional Comments: В CAMAC инверсная по отношению к стандарту ТТЛ логика 
//                      (т.е. лог. 0 CAMAC == лог. 1 ТТЛ)
// Command & Control: Для управления будет использован формат команд из демо проекта 
//                    SerialPortWithCmdProcessor в репо QmtechCycloneIVBoardDemos
//                    Общий формат команды к контроллеру:
//                      |   SOF   |Space|PayLoad Len| Type (1b) |  N (1 byte) |    A (1 byte)   |  F (1 byte)  | Data (3bytes)|    EOF   |
//                       0xFF 0xFF  0x00     {L}     {Cmd Type}  {N - module}  {A - sub address} {F - function}  {Camac Data}   0xEE 0xEE
//                    Для управления CAMAC-модулями существует несколько значений типа команды (Cmd Type):
//                    1. Запись в модуль CmdType = 1
//                       Пример команды записи в модуль 7 по адресу 11 с функцией 4 и данных на CAMAC-шине 0xD01123:
//                         0xFF 0xFF 0x00 0x08 0x01 0x07 0x0B 0x04 0x23 0x11 0xD0 0xEE 0xEE
//                       В ответ приходит подтверждение о том, что команда принята:
//                         |  SOF   |Space|Len|Accepted|   EOF   |
//                          0xFF 0xFF 0x00 0x01  0x01   0xEE 0xEE
//                    2. Чтение из модуля CmdType = 2, например, из модуля 20, по адресу 14 с функцией 9:
//                         0xFF 0xFF 0x00 0x04 0x02 0x14 0x0E 0x09 0xEE 0xEE
//                       В ответ придет:
//                         0xFF 0xFF 0x00 0x03 0x11 0x22 0x33 0xEE 0xEE где 0x332211 - данные из модуля
//                    3. Проверка наличия запросов на обслуживание CmdType=3, безадресная команда: 0xFF 0xFF 0x00 0x01 0x03 0xFF
//                       В ответ придет 3 байта состояния линий L, например, 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 :
//                         0xFF 0xFF 0x00 0x03 0x01 0x04 0x04 0xEE 0xEE
//                    4. Любые другие команды отклоняются 0xFF 0xFF 0x00 0x01 0x02 0xEE 0xEE
//
//////////////////////////////////////////////////////////////////////////////////
module Messbauer_CAMAC_Controller #
(
    CAMAC_DATA_WIDTH = 24,
    CAMAC_MODULE_WIDTH = 6,
    CAMAC_FUNC_WIDTH = 5,
    CAMAC_SUB_ADDR_WIDTH = 4
)
(
    // Общие сигналы управления: тактовая частота и чигнал сброса
    input wire clk,
    input wire rst,
    // RS232-сигналы
    input  wire rs232_rx,                            // сигнал RX чтение данных PC -> устройство (контроллер крейта)
    output wire rs232_tx,                            // сигнал TX чтение данных PC <- устройство (контроллер крейта)
    input  wire rs232_cts,                           // сигнал Clear-to-send, PC выставляет когда готов принять данные
    output wire rs232_rts,                           // сигнал Ready-to-send, устройство выставляет когда готово отправить данные
    // Сигналы управления адресацией модулей (N, F, A)
    output wire [CAMAC_MODULE_WIDTH-1:0] camac_n,    // выбор модуля
    output wire [CAMAC_FUNC_WIDTH-1:0] camac_f,      // выбор функции
    output wire [CAMAC_SUB_ADDR_WIDTH-1:0] camac_a,  // выбор суб адреса
    // Сигналы состояния
    input  wire camac_x,                             // сигнал команда принята, модуль -> контроллер на любой NAF
    input  wire camac_q,                             // сигнал ответ, модуль -> контроллер на любой NAF
    input  wire camac_l,                             // сигнал запрос на обслуживание, модуль -> контроллер
    output wire camac_b,                             // сигнал занято, контроллер -> магистраль, вырабатывается при любой операции контроллером
    // Сигналы управления
    output wire camac_z,                             // сигнал начальная установка (= Пуск), контроллер -> магистраль
    output wire camac_c,                             // сигнал сброс, контроллер -> магистраль
    output wire camac_i,                             // сигнал запрет, контроллер -> магистраль/устройство
    output wire camac_s1,                            // сигнал строб S1, контроллер -> магистраль
    output wire camac_s12,                           // сигнал строб S2, контроллер -> магистраль
    output wire camac_h,                             // сигнал задержка, контроллер -> магистраль/устройство (нестандартный сигнал)
    // Сигналы передачи данных
    input  wire [CAMAC_DATA_WIDTH-1:0] camac_r,  // should be input && rename
    output wire [CAMAC_DATA_WIDTH-1:0] camac_w
);

/******************************* Блок констант ***********************************/
// 1. Состояния конечного автомата
localparam reg [3:0] MESSB_CAMAC_CONTR_INITIAL_STATE = 0;
localparam reg [3:0] MESSB_CAMAC_CONTR_RESETED_STATE = 1;
// 2. Констаны, определяющие связь постоянных значений с функциями

/*********************************************************************************/
/******************************* Блок переменных *********************************/
/*********************************************************************************/
/****************** Блок описания поведения работы накопителя ********************/
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
    end
    else
    begin
    end
end
/*********************************************************************************/
endmodule
