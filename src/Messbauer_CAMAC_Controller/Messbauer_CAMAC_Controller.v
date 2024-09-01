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
localparam reg [3:0] DEFAULT_PROCESSES_DELAY_CYCLES = 10;
localparam reg [4:0] RST_DELAY_CYCLES = 20;

localparam reg [1:0]  BLINK_EVENT_AWAIT = 0;
localparam reg [1:0]  BLINK_ZERO_STATE = 1;
localparam reg [1:0]  BLINK_ONE_STATE = 2;
localparam reg [31:0] LED_DELAY_COUNTER = 10000000; // 200 ms for 50 MHz

localparam reg [3:0] INITIAL_STATE = 4'b0000;
localparam reg [3:0] AWAIT_CMD_STATE = 4'b0001;
localparam reg [3:0] CMD_DECODE_STATE = 4'b0010;
localparam reg [3:0] CMD_CHECK_STATE = 4'b0011;
localparam reg [3:0] CMD_DETECTED_STATE = 4'b0100;
localparam reg [3:0] CMD_EXECUTE_STATE = 4'b0101;
localparam reg [3:0] CMD_FINALIZE_STATE = 4'b0110;
localparam reg [3:0] SEND_RESPONSE_STATE = 4'b0111;
localparam reg [3:0] CLEANUP_STATE = 4'b1000;

localparam reg [3:0]  MIN_CMD_LENGTH = 8;
localparam reg [15:0] MAX_TIMEOUT_BETWEEN_BYTES = 11000; // in cycles of 50MHz
localparam reg [7:0]  SET_REG_CMD = 1;
localparam reg [7:0]  GET_REG_CMD = 2;

/*********************************************************************************/
/******************************* Блок переменных *********************************/
// 1. Набор регистров сброса
reg  rst = 1'b0;
reg  rst_generated = 1'b0;
reg  [7:0] rst_counter;
// 2. Набор регистров и проводников для чтения из RS232 (Rx)
reg  rx_read;
wire rx_err;
wire [7:0] rx_data;
wire rx_byte_received;
wire has_rx_data;
wire fifo_encoder_read;
wire fifo_read;
// 3. Набор регистров и проводников для записи в RS232 (Tx)
reg  tx_transaction;
reg  [7:0] tx_data;
reg  tx_data_ready;
wire tx_data_copied;
wire tx_busy;
// 4. Набор регистров статуса обмена по RS233 (мигание светодиодами по Tx и Rx)
reg  [7:0] data_buffer;
reg  [3:0] serial_data_exchange_state;
reg  [7:0] delay_counter;
reg  tx_blink;
reg  [1:0]  tx_blink_state;
reg  [31:0] tx_blink_counter;
reg  rx_blink;
reg  [1:0]  rx_blink_state;
reg  [31:0] rx_blink_counter;
// 5. Дополнительный набор регистров-состояний обмена и полученных данных
reg  rx_data_ready_trig;
reg  [7:0] received_bytes_counter;
reg  [3:0] device_state;
reg  [15:0] cmd_receive_timeout;
reg  [7:0] cmd_bytes_counter;
reg  [7:0] rx_read_counter;
reg  [7:0] rx_cmd_bytes_analyzed;
// 6. Набор регистров командной обработки данных по RS232
wire [7:0] r0, r1, r2, r3, r4, r5, r6, r7;
reg  [7:0] cmd_response [0: 14];
reg  [3:0] cmd_response_bytes;
reg  [3:0] cmd_tx_bytes_counter;
reg  [3:0] cmd_finalize_counter;
reg cmd_next_byte_protect;
reg cmd_ready;
reg cmd_response_required;
reg cmd_processed_received;
wire cmd_decode_finished;
wire cmd_decode_success;
reg [31:0] memory [0:7];
integer c;
// 6.1 Регистры декодирования команд
wire bad_sof;
wire no_space;
wire bad_payload;
wire bad_eof;
wire [7:0] current_byte;
wire [7:0] bytes_processed;

assign fifo_read = fifo_encoder_read | rx_read;
/*********************************************************************************/
// this always implements the global reset that board generates at start
always @(posedge clk)
begin
    if (rst_generated != 1'b1)
    begin
        if (rst != 1'b1)
        begin
            rst <= 1'b1;
            rst_counter <= 0;
        end
        else
        begin
            rst_counter <= rst_counter + 1;
            if (rst_counter == RST_DELAY_CYCLES)
            begin
                rst <= 1'b0;
                rst_generated <= 1'b1;
            end
        end
    end
end
/************** Блок описания поведения работы CAMAC-контроллера *****************/
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
