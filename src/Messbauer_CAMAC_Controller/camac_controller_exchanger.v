//////////////////////////////////////////////////////////////////////////////////
// Company:        Wissance (https://wissance.com)
// Engineer:       EvilLord666 (Ushakov MV)
// 
// Create Date:    22/12/2022 
// Design Name: 
// Module Name:    camac_controller_exchanger
// Project Name:   camac_controller_exchanger
// Target Devices: Cyclone IV ()
// Tool versions:  Quartus Prime Lite 18.1
// Description:    Модуль Camac-контроллера, непосредственно управляющий CAMAC-модулями
//
// Dependencies: 
//
// Revision: 
// Revision 1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
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
    // todo(UMV): добавить регистры!

    // CAMAC-сигналы
    // В CAMAC инверсная по отношению к стандарту ТТЛ логика (т.е. лог. 0 CAMAC == лог. 1 ТТЛ)
    // Сигналы управления адресацией модулей (N, F, A)
    output wire [CAMAC_MODULE_WIDTH-1:0] camac_n,    // выбор модуля
    output wire [CAMAC_FUNC_WIDTH-1:0] camac_f,      // выбор функции
    output wire [CAMAC_SUB_ADDR_WIDTH-1:0] camac_a,  // выбор суб адреса
    // Сигналы состояния
    input wire camac_x,                              // сигнал команда принята, модуль -> контроллер на любой NAF
    input wire camac_q,                              // сигнал ответ, модуль -> контроллер на любой NAF
    input wire camac_l,                              // сигнал запрос на обслуживание, модуль -> контроллер
    output wire camac_b,                             // сигнал занято, контроллер -> магистраль, вырабатывается при любой операции контроллером
    // Сигналы управления
    output wire camac_z,                             // сигнал начальная установка (= Пуск), контроллер -> магистраль
    output wire camac_c,                             // сигнал сброс, контроллер -> магистраль
    output wire camac_i,                             // сигнал запрет, контроллер -> магистраль/устройство
    output wire camac_s1,                            // сигнал строб S1, контроллер -> магистраль
    output wire camac_s12,                           // сигнал строб S2, контроллер -> магистраль
    output wire camac_h,                             // сигнал задержка, контроллер -> магистраль/устройство (нестандартный сигнал)
    // Сигналы передачи данных
    input wire [CAMAC_DATA_WIDTH-1:0] camac_r,  // should be input && rename
    output wire [CAMAC_DATA_WIDTH-1:0] camac_w
);