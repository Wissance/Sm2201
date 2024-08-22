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
`define COMMON_OPERATION     0
`define READ_OPERATION       1
`define WRITE_OPERATION      2

module camac_controller_exchanger #
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
    // Сигналы взаимодействия с внешним модулем
    input wire cmd,
    output reg cmd_received,
    output reg controller_busy,
    input wire [7:0] camac_module,                   // номер модуля 1-23, от RS-232 получение
    input wire [7:0] camac_module_function,          // код функции
    input wire [7:0] camac_module_subaddr,           // субадрес
    input wire [1:0] camac_opeartion,                // 0 - инициализация/обмлуживание, 1 - чтение, 2 - записб
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
    input wire camac_l,                              // сигнал запрос на обслуживание, модуль -> контроллер
    output reg camac_b,                              // сигнал занято, контроллер -> магистраль, вырабатывается при любой операции контроллером
    // Сигналы управления
    output wire camac_z,                             // сигнал начальная установка (= Пуск), контроллер -> магистраль
    output wire camac_c,                             // сигнал сброс, контроллер -> магистраль
    output wire camac_i,                             // сигнал запрет, контроллер -> магистраль/устройство
    output reg  camac_s1,                            // сигнал строб S1, контроллер -> магистраль
    output reg  camac_s2,                            // сигнал строб S2, контроллер -> магистраль
    output wire camac_h,                             // сигнал задержка, контроллер -> магистраль/устройство (нестандартный сигнал)
    // Сигналы передачи данных
    input wire [CAMAC_DATA_WIDTH-1:0] camac_r,  // should be input && rename
    output reg [CAMAC_DATA_WIDTH-1:0] camac_w
);

localparam reg [3:0] INITIAL_STATE = 4'b0000;
localparam reg [3:0] AWAIT_CMD_STATE = 4'b0001;
localparam reg [3:0] SET_CAMAC_BUSY_STATE = 4'b0010;
localparam reg [3:0] DELAY_BEFORE_S1_STATE = 4'b0011;
localparam reg [3:0] S1_STROBE_BEGIN_STATE = 4'b0100;
localparam reg [3:0] S1_STROBE_END_STATE = 4'b0101;
localparam reg [3:0] S2_STROBE_BEGIN_STATE = 4'b0110;
localparam reg [3:0] S2_STROBE_END_STATE = 4'b0111;
localparam reg [3:0] FIN_CMD_STATE = 4'b1000;

localparam reg [7:0] CAMAC_BUSY_DELAY = 15;

reg [3:0] camac_state;
reg [7:0] counter;

always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        cmd_received <= 1'b0;
        controller_busy <= 1'b0;
        camac_state <= INITIAL_STATE;
        camac_b <= 1'b1;
        camac_s1 <= 1'b0;
        camac_s2 <= 1'b0;

        counter <= 8'h00;
        camac_r0 <= 8'h00;
        camac_r1 <= 8'h00;
        camac_r2 <= 8'h00;
    end
    else
    begin
        case (camac_state)
            INITIAL_STATE:
            begin
                camac_state <= AWAIT_CMD_STATE;
                counter <= 8'h00;
                camac_r0 <= 8'h00;
                camac_r1 <= 8'h00;
                camac_r2 <= 8'h00;
                
                camac_s1 <= 1'b0;
                camac_s2 <= 1'b0;
            end
            AWAIT_CMD_STATE:
            begin
                camac_state <= SET_CAMAC_BUSY_STATE;
                cmd_received <= 1'b1;
                controller_busy <= 1'b1;
                counter <= 8'h00;
                camac_r0 <= 8'h00;
                camac_r1 <= 8'h00;
                camac_r2 <= 8'h00;

                camac_s1 <= 1'b0;
                camac_s2 <= 1'b0;
            end
            SET_CAMAC_BUSY_STATE:
            begin
                
                camac_b <= 1'b0;
                if (camac_module == 0)
                begin
                    // безадресаня команда
                    camac_state <= S2_STROBE_BEGIN_STATE;
                end
                else
                begin
                    // здесь адресуется модуль NAF
                    camac_n <= camac_module;
                    camac_f <= camac_module_function;
                    camac_a <= camac_module_subaddr;
                    if (camac_opeartion == `WRITE_OPERATION)
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
                // нужно проверять camac_x
                if (camac_x == 1'b1)
                begin
                    if (camac_opeartion == `READ_OPERATION)
                    begin
                        camac_r0 <= camac_r[7:0];
                        camac_r1 <= camac_r[15:8];
                        camac_r2 <= camac_r[23:16];
                    end
                    camac_state <= S1_STROBE_END_STATE;
                end
            end
            S1_STROBE_END_STATE:
            begin
                camac_state <= S2_STROBE_BEGIN_STATE;
            end
            S2_STROBE_BEGIN_STATE:
            begin
                camac_state <= S2_STROBE_END_STATE;
            end
            S2_STROBE_END_STATE:
            begin
                camac_state <= FIN_CMD_STATE;
                cmd_received <= 1'b0;
            end
            FIN_CMD_STATE:
            begin
                camac_state <= INITIAL_STATE;
                controller_busy <= 1'b0;
            end
        endcase
    end
end

endmodule
