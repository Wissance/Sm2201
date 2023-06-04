//////////////////////////////////////////////////////////////////////////////////
// Company:        Wissance (https://wissance.com)
// Engineer:       EvilLord666 (Ushakov MV), Verroneros
// 
// Create Date:    22/12/2022 
// Design Name: 
// Module Name:    Messbauer_CAMAC_Accumulator
// Project Name:   Messbauer_CAMAC_Accumulator
// Target Devices: Cyclone IV ()
// Tool versions:  Quartus Prime Lite 18.1
// Description:    CAMAC блок накопления спектрометра СМ2201 (SM2201)
//
// Dependencies:   Без внешних зависимостей
//
// Revision:       1.0
// Additional Comments: В КАМАК используется инверсная логика т.е. лог. 1 соотвествует низкий уровень (0 - 0.4В),
//                      а лог. 0 - высокий уровень (2.0 - 5.5 В)
//
//////////////////////////////////////////////////////////////////////////////////
module Messbauer_CAMAC_Accumulator #
(
    // ширина данных CAMAC
    CAMAC_DATA_WIDTH = 24,
    // число линии модулей (станций)
    CAMAC_MODULE_WIDTH = 24,
    // ширина данных линии субадреса модуля (количество бит)
    CAMAC_ADDR_WIDTH = 4,
    // ширина данных линии функция (количество бит)
    CAMAC_FUNC_WIDTH = 5,
    // число тактов в течение которых переходные процессы будут завершены (по стандарту КАМАК - 0,1 мкс)
    CAMAC_TRANSITION_CYCLES = 5,
    // число бит адреса накопителя (в SM-2201 число точек в спектре = 2^12 = 4096)
    MESSB_ACC_ADDRESS_WIDTH = 12,
    // использование С1 для генерации переключения следующего канала (если == 0) или внутренний генератор (если == 1)
    USE_INTERNAL_AMPL_CHANNEL_SWITCH = 0
)
(
    // Общие сигналы управления: тактовая частота и чигнал сброса
    input wire clk,
    input wire rst,
    // Спектрометрические сигналы
    input wire channel,  
    input wire start,
    input wire count,
    //output reg [MESSB_ACC_ADDRESS_WIDTH:0] address,

    // CAMAC-сигналы
    // Сигналы управления адресацией
    input wire [CAMAC_MODULE_WIDTH-1:0] camac_n,
    input wire [CAMAC_ADDR_WIDTH-1:0] camac_a,
    input wire [CAMAC_FUNC_WIDTH-1:0] camac_f,
    
    input wire camac_b,  // занято (busy)
    input wire camac_s1, // строб S1
    input wire camac_s2, // строб S2
    input wire camac_c,  // C - сброс (при С=1 установка регистров в начальное значение)
    input wire camac_z,  // Z - пуск
    input wire [CAMAC_DATA_WIDTH-1:0] camac_read,  // should be input && rename
    output reg [CAMAC_DATA_WIDTH-1:0] camac_write,
    output reg camac_x,  // X - команда принята
    output reg camac_l,  // L - запрос на обслуживание
    output reg camac_q   // Q - ответ (на любую адресную операцию т.е. содержащую N и A)
);

/******************************* Блок констант ***********************************/
// 1. Состояния конечного автомата блока накопления
localparam reg [3:0] MESSB_ACC_INITIAL_STATE = 0;
localparam reg [3:0] MESSB_ACC_RESETED_STATE = 1;
localparam reg [3:0] MESSB_ACC_DATA_EXCH_STATE = 2;
localparam reg [3:0] MESSB_ACC_AUTONOMOUS_MODE_STATE = 3;
localparam reg [3:0] MESSB_ACC_AMPLITUDE_MODE_STATE = 4;
localparam reg [3:0] MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE = 5;
localparam reg [3:0] MESSB_ACC_ACCUMULATION_ADDR_SEL_STATE = 6;
localparam reg [3:0] MESSB_ACC_ACCUMULATION_COUNTER1_COUNT_STATE = 7;
localparam reg [3:0] MESSB_ACC_ACCUMULATION_COUNTER2_COUNT_STATE = 8;
localparam reg [3:0] MESSB_ACC_ACCUMULATION_VALUE_COPY_STATE = 9;
localparam reg [3:0] MESSB_ACC_ACCUMULATION_CYCLE_FINISHED_STATE = 10;
// 2. Констаны, определяющие связь постоянных значений с функциями
localparam reg [3:0] DELAY_BEFORE_EXCH_READY = 10;
localparam reg [CAMAC_FUNC_WIDTH-1:0] AMPLITUDE_MODE_FUNC = 24;
localparam reg [CAMAC_FUNC_WIDTH-1:0] AUTONOMOUS_MODE_FUNC = 26;
localparam reg [1:0] AMPLITUDE_MODE = 1;
localparam reg [1:0] AUTONOMOUS_MODE = 2;
localparam reg [MESSB_ACC_ADDRESS_WIDTH-1:0] LAST_ADDRESS = 2**MESSB_ACC_ADDRESS_WIDTH - 1;
localparam reg [7:0] INERNAL_CHANNEL_COUNT_SWITCH_VALUE = 8'b100;
// 3. Константы, связанные с работой CAMAC
localparam reg [3:0] CAMAC_INITIAL_STATE = 0;
localparam reg [3:0] CAMAC_CMD_CYCLE_STARTED = 1;
localparam reg [3:0] CAMAC_WAIT_ADDRESED_CMD_DETECTION = 2;
localparam reg [3:0] CAMAC_S1_STROBE_WAIT_STATE = 3;
localparam reg [3:0] CAMAC_S1_STROBE_STATE = 4;
localparam reg [3:0] CAMAC_S2_STROBE_WAIT_STATE = 5;
localparam reg [3:0] CAMAC_S2_STROBE_STATE = 6;
localparam reg [3:0] CAMAC_CMD_CYCLE_FINISHED = 7;
/*********************************************************************************/
/******************************* Блок переменных *********************************/
reg [3:0] state;                           // состояние блока накопления. см. диаграмму
reg [3:0] delay_counter;                   // счетчик задержек, для перехода между состояниями
reg [1:0] mode;                            // режим измерения
reg start_trigger;                         // триггер старт-импульса
reg [MESSB_ACC_ADDRESS_WIDTH-1:0] address; // адрес текущей точки спектра
reg current_counter;                       // текущий используемый счетчик
reg [CAMAC_DATA_WIDTH-1:0] current_value;  // текущее значение
reg [CAMAC_DATA_WIDTH-1:0] counter1_value; // текущее значение накопленное в счетчике 1
reg [CAMAC_DATA_WIDTH-1:0] counter2_value; // текущее значение накопленное в счетчике 2
reg channel_switched;                      // триггер переключения канал-импульса
reg generated_channel;                     // генерируемы канал-импульс в амплиткдном режиме для случая USE_INTERNAL_AMPL_CHANNEL_SWITCH == 0
reg [7:0] generated_channel_counter;       // счетчик переключения генерируемого
// специальный синтаксис 2 ** MESSB_ACC_ADDRESS_WIDTH = 2 в степени
reg [CAMAC_DATA_WIDTH-1:0] spectrum [2**MESSB_ACC_ADDRESS_WIDTH];
reg channel_data_accumulated;              // регистр, используемый для 
wire acc_event_rst;                        // эффективный сигнал сброса триггера канала и очистки счетсчика импульсов
wire ampl_mode_channel;                    // канал-импульс в амплитудном режиме
wire internal_channel;                     // мультиплексируемый канал-импульс
integer i;                                 // Переменная для цикла for для инициализации спектра
reg [3:0] camac_cmd_state;                 // Состояние обработки действий на магистрали
reg [3:0] camac_transition_counter;        // Счетчик для подсчета тактов для завершения переходных процессов
/*********************************************************************************/
assign acc_event_rst = rst | channel_data_accumulated;
// todo(UMV): если используется s1 от КАМАК, то не учитывается вся команда целиком NF(25)A(0-15)
assign ampl_mode_channel = USE_INTERNAL_AMPL_CHANNEL_SWITCH == 1'b1 ? generated_channel_counter : camac_s1;
assign internal_channel = mode == AMPLITUDE_MODE ? ampl_mode_channel : channel;
/****************** Блок описания поведения работы накопителя ********************/

// Блок логики смены состояний накопителя (автономный и амплитудный анализ)
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        state <= MESSB_ACC_RESETED_STATE;
        delay_counter <= 0;
        // todo(UMV) : добавить инициализацию остальных регистров
        address <= 0;
        channel_data_accumulated <= 1'b0;
        current_value <= 0;
        for (i = 0; i < 2 ** MESSB_ACC_ADDRESS_WIDTH; i = i+1)
        begin
            spectrum[i] <= 0;
        end
    end
    else
    begin
        case (state)
            MESSB_ACC_RESETED_STATE:
            begin
                delay_counter <= delay_counter + 1;
                if (delay_counter == DELAY_BEFORE_EXCH_READY)
                begin
                    state <= MESSB_ACC_DATA_EXCH_STATE;
                end
            end
            MESSB_ACC_DATA_EXCH_STATE:
            begin
                /* ожидание команды, выбор между 1 из 2 режимов: MESSB_ACC_AUTONOMOUS_MODE_STATE или 
                   MESSB_ACC_AMPLITUDE_MODE_STATE
                   TODO:
                      1. Нужно вообще понимание, что в данный момент функцию можно читать, что это
                         не какое-то предыдущее значение
                      2. Необходимо ответить на команду, т.е. подтвердить, что она принята / непринята
                      3. Необходимо добавить обработку ответа на другие команды управления:
                         - остановка накопления
                         - чтение spectrum
                         - запись spectrum в память
                         Для обработки команд при запущенном анализе нужно отслеживать необходимость прерывания
                         измерения в состоянии MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE с переходом
                         MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE -> MESSB_ACC_DATA_EXCH_STATE.
                         Вся обработка команд должна происходить здесь.
                 */
                if (camac_f == AMPLITUDE_MODE_FUNC)
                begin
                    state <= MESSB_ACC_AMPLITUDE_MODE_STATE;
                end
                else
                begin
                    if (camac_f == AUTONOMOUS_MODE_FUNC)
                    begin
                        state <= MESSB_ACC_AUTONOMOUS_MODE_STATE;
                    end
                end
            end
            MESSB_ACC_AUTONOMOUS_MODE_STATE:
            /* Автономный режим или режим измерения мессбауэровских спектров, в данном режиме
             * идет ожидание импульсов от линий START, CHANNEL
             */
            begin
                mode <= AUTONOMOUS_MODE;
                state <= MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE;
                // todo(UMV): add stop condition
            end
            MESSB_ACC_AMPLITUDE_MODE_STATE:
            /* Амплитудный режим или режим измерения амплитудных спектров, в данном режиме
             * CHANNEL генерируется внутри
             */
            begin
                mode <= AMPLITUDE_MODE;
                state <= MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE;
                // todo(UMV): add stop condition
            end
            MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE:
            /* В этом состоянии идет ожидание генерации старт-импульса -> ---__--------------------------
             */
             //todo (umv): добавить обработку переключения канал-импульса в амплитудном режиме
            begin
                if (start_trigger == 1'b1 || mode == AMPLITUDE_MODE)
                begin
                    // запуск накопления от 0 до 2^MESSB_ACC_ADDRESS_WIDTH - 1 точки
                    address <= 0;
                    state <= MESSB_ACC_ACCUMULATION_ADDR_SEL_STATE;
                end
            end
            MESSB_ACC_ACCUMULATION_ADDR_SEL_STATE:
            /*
             *
             */
            begin
                if (address[0] == 1'b0)
                    state <= MESSB_ACC_ACCUMULATION_COUNTER1_COUNT_STATE;
                // todo (umv): добавить выбор счечтчика 2
            end
            MESSB_ACC_ACCUMULATION_COUNTER1_COUNT_STATE:
            begin
                current_counter <= 1'b0;
                channel_data_accumulated <= 1'b0;
                // ждем окончания канала ...
                // по завершении копируем в блок памяти в ПЛИС, переходим в MESSB_ACC_ACCUMULATION_VALUE_COPY_STATE
                if (channel_switched == 1'b1)
                begin
                    state <= MESSB_ACC_ACCUMULATION_VALUE_COPY_STATE;
                end
            end
            MESSB_ACC_ACCUMULATION_COUNTER2_COUNT_STATE:
            begin
                current_counter <= 1'b1;
                channel_data_accumulated <= 1'b0;
                // ждем окончания канала ...
                // по завершении копируем в блок памяти в ПЛИС, переходим в MESSB_ACC_ACCUMULATION_VALUE_COPY_STATE
                if (channel_switched == 1'b1)
                begin
                    state <= MESSB_ACC_ACCUMULATION_VALUE_COPY_STATE;
                end
            end
            MESSB_ACC_ACCUMULATION_VALUE_COPY_STATE:
           /*
               здесь осуществляется перенос значения в ячейку памяти -> s[i] = s[i] + value
            */
            begin
                if (current_counter == 1'b0)
                    current_value <= counter1_value;
                else
                    current_value <= counter2_value;
                spectrum[address] = spectrum[address] + current_value;
                channel_data_accumulated <= 1'b1;
                if (address == LAST_ADDRESS)
                begin
                    state <= MESSB_ACC_ACCUMULATION_CYCLE_FINISHED_STATE;
                end
                else
                begin
                    address <= address + 1;
                    state <= MESSB_ACC_ACCUMULATION_ADDR_SEL_STATE;
                    channel_data_accumulated <= 1'b0;
                end
            end
            MESSB_ACC_ACCUMULATION_CYCLE_FINISHED_STATE:
            begin
            /* Последовательно были измерены все точки спектра от 0 до 2^12-1 (4095)
             * В этом состоянии очищаем все временные значения если необходимо, готовимся к следующему циклу
             */
                state <= MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE;
                address <= 0;
            end
        endcase
    end
end

/*
 * Блок ответов на команды/запросы КАМАК (еще не известно как мы будем отвечать на команды, это все под
 * вопросом),
 * вероятно необходимо учитывать линии:
 * B  - занято (busy)
 * Z  - пуск
 * C  - сброс
 * I  -
 * S1 - строб S1
 * S2 - строб S2
 *             Диаграммы команды на магистрали КАМАК 
 *             1. Адресные команды
 * B     -----                                        ---------
 *           |________________________________________|
 * NAF   -----                                        ---------
 *           |________________________________________|
 * XQRW  -----                                        ---------
 *           |________________________________________|
 *            ________________________________________
 * L     ____|                                        |________
 *       ______________         _______________________________
 * S1                  |_______|
 *       ______________________________       _________________
 * S2                                  |_____|
 * В КАМАК лог 0 - 2-5 В, лог. 1 - 0.4 В
 */ 
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        camac_cmd_state <= CAMAC_INITIAL_STATE;
        camac_l <= ~(1'b0);
        camac_transition_counter <= 3'b0;
    end
    else
        begin
        if (camac_c == 1'b1 || camac_z == 1'b0) // todo(umv): Возможно ПУСК мы будем обрабатывать отдельно ...
        begin
            camac_cmd_state <= CAMAC_INITIAL_STATE;
            camac_transition_counter <= 3'b0;
        end
        case (camac_cmd_state)
            CAMAC_INITIAL_STATE:
            begin
                if (camac_b == ~(1'b0))
                begin
                    camac_cmd_state <= CAMAC_CMD_CYCLE_STARTED;
                    camac_l <= ~(1'b0);
                end
            end
            CAMAC_CMD_CYCLE_STARTED:
            begin
                camac_l <= ~(1'b1);
                camac_x <= ~(1'b1);
                camac_cmd_state <= CAMAC_WAIT_ADDRESED_CMD_DETECTION;
                // если команда адресная (т.е. N != 0), то нужно отправить ответ Q, но, возможно требуется ожидание
                // окончания переходных процессов (по стандату это не более 0,1 мкс)
                
            end
            CAMAC_WAIT_ADDRESED_CMD_DETECTION:
            begin
               camac_transition_counter <= camac_transition_counter + 1;
               if (camac_transition_counter == CAMAC_TRANSITION_CYCLES)
               begin
                  // определяем адресная команда или безадресная
                  if (camac_n != ~(24'b111111111111111111111111)) // ??? Как активитуется модуль 0 или 1 ?
                  begin
                      camac_cmd_state <= CAMAC_S1_STROBE_WAIT_STATE;
                  end
                  else
                  begin
                      // безадресные команды
                  end
               end
            end
            CAMAC_S1_STROBE_WAIT_STATE:
            begin
               if (camac_s1 == 1'b0)
                   camac_cmd_state <= CAMAC_S1_STROBE_STATE;
            end
            CAMAC_S1_STROBE_STATE:
            begin
                camac_cmd_state <= CAMAC_S2_STROBE_WAIT_STATE;
            end
            CAMAC_S2_STROBE_WAIT_STATE:
            begin
               if (camac_s2 == 1'b0)
                   camac_cmd_state <= CAMAC_S2_STROBE_STATE;
            end
            CAMAC_S2_STROBE_STATE:
            begin
                camac_cmd_state <= CAMAC_CMD_CYCLE_FINISHED;
            end
            CAMAC_CMD_CYCLE_FINISHED:
            begin
                camac_x <= 1'b0;
            end
        endcase
    end
end

// Блок генерации внутреннего канал-импульса
always @(posedge clk)
begin
    if (rst == 1'b1)
    begin
        generated_channel <= 1'b0;
        generated_channel_counter <= 8'b0;
    end
    else
    begin
       if (USE_INTERNAL_AMPL_CHANNEL_SWITCH == 1'b1)
       begin
           generated_channel_counter <= generated_channel_counter + 1;
           if (generated_channel_counter == INERNAL_CHANNEL_COUNT_SWITCH_VALUE)
           begin
              generated_channel <= ~generated_channel;
           end
       end
    end
end

// Блок ожидания Старт-импульса
// -----__----
always @(start)
begin
    if (state == MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE)
        if (start == 1'b0)
            start_trigger <= 1'b1;
    else
        start_trigger <= 1'b0;
end

// Блок подсчета импульсов с асинхронным сбросом
always @(posedge count or posedge acc_event_rst)
begin
    // асинхронный сброс для задания начального значения для current_value
    if (acc_event_rst == 1'b1)
    begin
        // тут нужен "хитрый сброс",т.е. когда идет счет и счет происходит в сч.1, сбросить можно
        // если для сч.2 данные уже попали в память аналогично и с другим счетчиком
        if (rst == 1'b1)
        begin
            // это глобальный сброс, мы очищаем оба счетчика
            counter1_value <= 0;
            counter2_value <= 0;
        end
        else
        begin
            if (current_counter == 1'b0)
                counter2_value <= 0;
            else
                counter1_value <= 0;
        end
    end
    else
    begin
        if (current_counter == 1'b0)
            counter1_value <= counter1_value + 1;
        else
            counter2_value <= counter2_value + 1;
    end
end

/* Блок смены адреса точки спектра асинхронным сбросом
 * start   -----_-----------------------------------------------------------.....------_----....
 * channel -----__----------------__----------------__-----------------__---.....------__---....
 * В качестве канал-импульса использован internal_channel, мультиплексирующий в зависимости от режима 
 * канал-импульс как для автономного (мессбауэровского режима), так и для амплитудного
 */
always @(negedge internal_channel or posedge acc_event_rst)
begin
if (acc_event_rst == 1'b1)
    begin
        channel_switched <= 1'b0;
    end
    else
    begin
        if (address > 0)
            channel_switched <= 1'b1;
    end
end

/* Блок смены адреса точки спектра в амплитудном режиме по КАМАК команде NF(25)A(0-15)S1
 *
 */


endmodule




