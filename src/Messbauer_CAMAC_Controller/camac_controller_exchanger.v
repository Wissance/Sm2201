//////////////////////////////////////////////////////////////////////////////////
// Company:        Wissance (https://wissance.com)
// Engineer:       EvilLord666 (Ushakov MV)
// 
// Create Date:    22/12/2022 
// Design Name: 
// Module Name:    camac_controller_exchanger
// Project Name:   camac_controller_exchanger
// Target Devices: Cyclone IV (EP4CE15F23C8N)
// Tool versions:  Quartus Prime Lite 18.1
// Description:    Camac-контроллера, непосредственно управляющий CAMAC-модулями
//
// Dependencies: 
//
// Revision: 
// Revision 1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`define COMMON_OPERATION         0
`define WRITE_OPERATION          1
`define READ_OPERATION           2
`define CHECK_LAM_OPERATION      3

module camac_controller_exchanger #
(
    parameter CAMAC_AVAILABLE_MODULES = 23,
    parameter CAMAC_DATA_WIDTH = 24,
    parameter CAMAC_MODULE_WIDTH = 6,
    parameter CAMAC_FUNC_WIDTH = 5,
    parameter CAMAC_SUB_ADDR_WIDTH = 4
)
(
    // Общие сигналы управления: тактовая частота и чигнал сброса
    input wire clk,
    input wire rst,
    // Сигналы взаимодействия с внешним модулем
    input wire cmd,
    output reg cmd_received,
    output reg controller_busy,
    input wire [7:0] camac_module,                   // номер модуля 1-23, от RS-232 получение
    input wire [7:0] camac_module_function,          // код функции
    input wire [7:0] camac_module_subaddr,           // субадрес
    input wire [1:0] camac_operation,                // 0 - инициализация/обcлуживание, 1 - чтение, 2 - запись
    input wire [7:0] camac_w0,                       // младший байт записи CAMAC
    input wire [7:0] camac_w1,                       // средний байт записи CAMAC
    input wire [7:0] camac_w2,                       // старший байт записи CAMAC
    output reg [7:0] camac_r0,                       // младший байт чтения CAMAC
    output reg [7:0] camac_r1,                       // средний байт чтения CAMAC
    output reg [7:0] camac_r2,                       // старший байт чтения CAMAC
    // CAMAC-сигналы
    // В CAMAC инверсная по отношению к стандарту ТТЛ логика (т.е. лог. 0 CAMAC == лог. 1 ТТЛ)
    // Сигналы управления адресацией модулей (N, F, A)
    output reg [CAMAC_MODULE_WIDTH-1:0] camac_n,     // выбор модуля
    output reg [CAMAC_FUNC_WIDTH-1:0] camac_f,       // выбор функции
    output reg [CAMAC_SUB_ADDR_WIDTH-1:0] camac_a,   // выбор суб адреса
    // Сигналы состояния
    input wire camac_x,                              // сигнал команда принята, модуль -> контроллер на любой NAF
    input wire camac_q,                              // сигнал ответ, модуль -> контроллер на любой NAF
    output reg camac_b,                              // сигнал занято, контроллер -> магистраль, вырабатывается при любой операции контроллером
    // Сигналы управления
    output reg  camac_z,                             // сигнал начальная установка (= Пуск), контроллер -> магистраль
    output reg  camac_c,                             // сигнал сброс, контроллер -> магистраль
    inout  wire camac_i,                             // сигнал запрет, контроллер -> магистраль/устройство
    output reg  camac_s1,                            // сигнал строб S1, контроллер -> магистраль
    output reg  camac_s2,                            // сигнал строб S2, контроллер -> магистраль
    // output reg  camac_h,                             // сигнал задержка, контроллер -> магистраль/устройство (нестандартный сигнал)
    // Сигналы передачи данных
    input wire [CAMAC_DATA_WIDTH-1:0] camac_r,
    output reg [CAMAC_DATA_WIDTH-1:0] camac_w,
    input wire [CAMAC_AVAILABLE_MODULES - 1:0] camac_l // сигнал запрос на обслуживание, модуль -> контроллер
);

localparam reg [3:0] INITIAL_STATE = 4'b0000;
localparam reg [3:0] BEGIN_INIT_STATE = 4'b0001;
localparam reg [3:0] INIT_S2_STROBE_BEGIN_STATE = 4'b0010;
localparam reg [3:0] INIT_S2_STROBE_END_STATE = 4'b0011;
localparam reg [3:0] END_INIT_STATE = 4'b0100;

localparam reg [3:0] AWAIT_CMD_STATE = 4'b0101;
localparam reg [3:0] SET_CAMAC_BUSY_STATE = 4'b0110;
localparam reg [3:0] DELAY_BEFORE_S1_STATE = 4'b0111;
localparam reg [3:0] S1_STROBE_BEGIN_STATE = 4'b1000;
localparam reg [3:0] S1_STROBE_END_STATE = 4'b1001;
localparam reg [3:0] S1_TO_S2_STROBE_DELAY_STATE = 4'b1010;
localparam reg [3:0] S2_STROBE_BEGIN_STATE = 4'b1011;
localparam reg [3:0] S2_STROBE_END_STATE = 4'b1100;
localparam reg [3:0] FREE_CAMAC_BUSY_STATE = 4'b1101;
localparam reg [3:0] FIN_CMD_STATE = 4'b1110;

localparam reg [7:0] CAMAC_BUSY_DELAY = 15;
localparam reg [7:0] CAMAC_S1_MIN_LEN = 10;
localparam reg [7:0] CAMAC_S1_TO_S2_DELAY = 5;
localparam reg [7:0] CAMAC_S2_MIN_LEN = 15;
localparam reg [7:0] CAMAC_Z_TO_S2_STROBE_DELAY = 23;
localparam reg [7:0] CAMAC_S2_INIT_LEN = 10;
localparam reg [7:0] CAMAC_AFTER_S2_DELAY = 5;

reg [3:0] camac_state;
reg [7:0] counter;
reg  camac_i_w;
wire camac_i_r;

assign camac_i = ~camac_z & ~camac_s2 ? camac_i_r : camac_i_w;

always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        cmd_received <= 1'b0;
        controller_busy <= 1'b0;
        camac_state <= INITIAL_STATE;
        camac_b <= 1'b1;
        camac_s1 <= 1'b1;
        camac_s2 <= 1'b1;

        counter <= 8'h00;
        camac_r0 <= 8'h00;
        camac_r1 <= 8'h00;
        camac_r2 <= 8'h00;
        camac_z <= 1'b1;
        camac_i_w <= 1'b1;
        camac_w <= 0;
    end
    else
    begin
        case (camac_state)
            INITIAL_STATE:
            begin
                camac_state <= BEGIN_INIT_STATE;
                counter <= 8'h00;
                camac_r0 <= 8'h00;
                camac_r1 <= 8'h00;
                camac_r2 <= 8'h00;
                
                camac_s1 <= 1'b1;
                camac_s2 <= 1'b1;
                camac_b <= 1'b1;
                camac_z <= 1'b1;
                camac_i_w <= 1'b1;
            end
            BEGIN_INIT_STATE:
            begin
                camac_b <= 1'b0;
                camac_z <= 1'b0;
                camac_i_w <= 1'b0;
                counter <= counter + 1;
                if (counter == CAMAC_Z_TO_S2_STROBE_DELAY)
                begin
                    counter <= 0;
                    camac_state <= INIT_S2_STROBE_BEGIN_STATE;
                end
            end
            INIT_S2_STROBE_BEGIN_STATE:
            begin
                camac_s2 <= 1'b0;
                counter <= counter + 1;
                if (counter == CAMAC_S2_INIT_LEN)
                begin
                    counter <= 8'h00;
                    camac_state <= INIT_S2_STROBE_END_STATE;
                end
            end
            INIT_S2_STROBE_END_STATE:
            begin
                camac_s2 <= 1'b1;
                counter <= counter + 1;
                if (counter == CAMAC_AFTER_S2_DELAY)
                begin
                    counter <= 8'h00;
                    camac_state <= END_INIT_STATE;
                end
            end
            END_INIT_STATE:
            begin
                camac_b <= 1'b1;
                camac_z <= 1'b1;
                camac_i_w <= 1'b1;
                camac_state <= AWAIT_CMD_STATE;
            end
            AWAIT_CMD_STATE:
            begin
                if (cmd == 1'b1)
                begin
                    camac_state <= SET_CAMAC_BUSY_STATE;
                    cmd_received <= 1'b1;
                    controller_busy <= 1'b1;
                end
                counter <= 8'h00;
                camac_r0 <= 8'h00;
                camac_r1 <= 8'h00;
                camac_r2 <= 8'h00;

                camac_s1 <= 1'b1;
                camac_s2 <= 1'b1;
                camac_b <= 1'b1;
            end
            SET_CAMAC_BUSY_STATE:
            begin
                
                camac_b <= 1'b0;
                if (camac_module == 0)
                begin
                    // безадресаня команда (может быть сброс)
                    // todo(UMV): в следующей версии
                    camac_state <= S2_STROBE_BEGIN_STATE;
                end
                else
                begin
                    // здесь адресуется модуль NAF
                    camac_n <= camac_module;
                    camac_f <= camac_module_function;
                    camac_a <= camac_module_subaddr;
                    if (camac_operation == `WRITE_OPERATION)
                    begin
                        camac_w[7:0] <= camac_w0;
                        camac_w[15:8] <= camac_w1;
                        camac_w[23:16] <= camac_w2;
                    end
                    camac_state <= DELAY_BEFORE_S1_STATE;
                end
            end
            DELAY_BEFORE_S1_STATE:
            begin
                counter <= counter + 1;
                if (counter == CAMAC_BUSY_DELAY)
                begin
                    counter <= 0;
                    camac_state <= S1_STROBE_BEGIN_STATE;
                    camac_s1 <= 1'b1;
                end
            end
            S1_STROBE_BEGIN_STATE:
            begin
                // запись и чтение осуществялется по строб сигналу S1
                camac_s1 <= 1'b0;
                // counter <= counter + 1;
                //if (camac_x == 1'b1)
                //begin
                    if (camac_operation == `READ_OPERATION)
                    begin
                        camac_r0 <= camac_r[7:0];
                        camac_r1 <= camac_r[15:8];
                        camac_r2 <= camac_r[23:16];
                    end
                    camac_state <= S1_STROBE_END_STATE;
                //end
                // todo umv: 
            end
            S1_STROBE_END_STATE:
            begin
                counter <= counter + 1;
                if (counter > CAMAC_S1_MIN_LEN)
                begin 
                    camac_state <= S1_TO_S2_STROBE_DELAY_STATE;
                    camac_s1 <= 1'b1;
                    counter <= 0;
                end
            end
            S1_TO_S2_STROBE_DELAY_STATE:
            begin
                counter <= counter + 1;
                if (counter > CAMAC_S1_TO_S2_DELAY)
                begin 
                    camac_state <= S2_STROBE_BEGIN_STATE;
                    camac_s2 <= 1'b1;
                    counter <= 0;
                end
            end
            S2_STROBE_BEGIN_STATE:
            begin
                camac_s2 <= 1'b0;
                camac_state <= S2_STROBE_END_STATE;
            end
            S2_STROBE_END_STATE:
            begin
                counter <= counter + 1;
                if (counter > CAMAC_S2_MIN_LEN)
                begin 
                    camac_s2 <= 1'b1;
                    counter <= 0;
                    camac_state <= FREE_CAMAC_BUSY_STATE;
                end
            end
            FREE_CAMAC_BUSY_STATE:
            begin
                counter <= counter + 1;
                if (counter > CAMAC_S2_MIN_LEN)
                begin 
                    counter <= 0;
                    camac_state <= FIN_CMD_STATE;
                    cmd_received <= 1'b0;
                    camac_b <= 1'b1;
                end
            end
            FIN_CMD_STATE:
            begin
                if (cmd == 1'b0)
                begin
                    camac_state <= AWAIT_CMD_STATE;
                    controller_busy <= 1'b0;
                end
            end
        endcase
    end
end

endmodule
