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
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Messbauer_CAMAC_Accumulator #
(
    // ширина данных CAMAC
    CAMAC_DATA_WIDTH = 24,
    // ширина данных линии функция (количество бит)
    CAMAC_FUNC_WIDTH = 5,
    // число бит адреса накопителя (в SM-2201 число точек в спектре = 2^12 = 4096)
    MESSB_ACC_ADDRESS_WIDTH = 12
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
    // Сигналы управления адресацией юю
    input [CAMAC_FUNC_WIDTH-1:0] camac_f,

    input camac_s1,
    output reg [CAMAC_DATA_WIDTH-1:0] read,  // should be input && rename
    output reg [CAMAC_DATA_WIDTH-1:0] write,
    output reg camac_x,
    output reg camac_q,
    

    output reg trig  // ?
);

/******************************* Блок констант ***********************************/
// 1. Состояния конечного автомата
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
// специальный синтаксис 2 ** MESSB_ACC_ADDRESS_WIDTH = 2 в степени
reg [CAMAC_DATA_WIDTH-1:0] spectrum [2**MESSB_ACC_ADDRESS_WIDTH];
reg channel_data_accumulated;              // регистр, используемый для 
wire acc_event_rst;                        // эффективный сигнал сброса триггера канала и очистки счетсчика импульсов
integer i;                                 // Переменная для цикла for для инициализации спектра
/*********************************************************************************/
assign acc_event_rst = rst | channel_data_accumulated;
/****************** Блок описания поведения работы накопителя ********************/
// Блок логики смены состояний
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
            begin
                mode <= AUTONOMOUS_MODE;
                // todo(UMV): add stop condition
            end
            MESSB_ACC_AMPLITUDE_MODE_STATE:
            begin
                mode <= AMPLITUDE_MODE;
                // todo(UMV): add stop condition
            end
            MESSB_ACC_ACCUMULATION_CYCLE_STARTED_STATE:
            /* В этом состоянии идет ожидание генерации старт-импульса -> ---__--------------------------
             */
             //todo (umv): добавить обработку переключения канал-импульса в амплитудном режиме
            begin
                if (start_trigger == 1'b1)
                begin
                    // запуск накопления от 0 до 2^MESSB_ACC_ADDRESS_WIDTH - 1 точки
                    address <= 0;
                    state <= MESSB_ACC_ACCUMULATION_ADDR_SEL_STATE;
                end
            end
            MESSB_ACC_ACCUMULATION_ADDR_SEL_STATE:
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

/* Блок смены адреса точки спектра с асинхронным сбросом
 * start   -----_-----------------------------------------------------------.....------_----....
 * channel -----__----------------__----------------__-----------------__---.....------__---....
 */
always @(negedge channel or posedge acc_event_rst)
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
/*********************************************************************************/
/*
//------------------------------------------------------
reg [1:0] State;
reg [1:0] NextState;
reg [23:0] counter1;
reg [23:0] counter2;
reg [23:0] current_counter;

localparam [1:0] data_exchange = 0;

localparam [1:0] auto = 1;

localparam [1:0] amplitude = 2;
//------------------------------------------------------
//технический блок
always @(posedge clk)
  begin
    if(rst)
      State <= data_exchange;
    else
      State <= NextState;
  end

//------------------------------------------------------
//выбор перехода 
always @(*)
  begin
    //по умолчанию сохраняем текущее состояние 
    NextState = State;
    
    case(State)
      //--------------------------------------
      data_exchange: 
        begin
          if(camac_f == 5'b11010) //запрос перехода в автономный режим
            begin
           if(start == 1'b1) //Ожидание команды start
              begin
               NextState = auto;
               end
            else
               begin
                  NextState = State;
               end
            end
          else
            if(camac_f == 5'b11000) //запрос перехода в амплитудный анализ
              begin
              NextState = amplitude;
               end
        end
      //--------------------------------------
      auto:
        begin
          if(camac_f == 5'b01011) //запрос перехода в программный обмен
            begin
              NextState = data_exchange;
            end            
        end
      //--------------------------------------
      amplitude:
        begin
          if(camac_f == 5'b01011) //запрос перехода в программный обмен
            begin
              NextState = data_exchange;
            end
        end
      //--------------------------------------
      default: NextState = data_exchange; //Состяние по умолчанию
    endcase
  end 
//-------------------------------------------

//задание выхода
always @(posedge clk)
  begin
    if(rst)
      begin
        camac_q <= 1'b1;
        camac_x <= 1'b1;
        address = 12'b0;
        trig <= 1'b0;
        end
    else
      begin
        //чтобы значение выхода изменялось вместе с изменением
        //состояния, а не на следующем такте, анализируем NextState
        case(NextState)
          //--------------------------------------
          data_exchange: 
            begin
              camac_q <= 1'b1;
              camac_x <= 1'b1;
              
              if ((camac_f == 5'b01001) && (camac_s1 == 1'b1))//сброс счетчиков
              begin
               counter1 = 24'b0;
               counter2 = 24'b0;
               current_counter <= counter1;
              end
              
              if ((camac_f == 5'b10001) && (camac_s1 == 1'b1))//перезапись регистра адреса
            begin
               //перезапись регистра адреса
               address <= 8'b11111111;
              end
              
              if ((camac_f == 5'b10000) && (camac_s1 == 1'b1))//Запись данных в ячейку ОЗУ
            begin
               //Запись данных в ячейку ОЗУ
               read <= 0;
               write <= 8'b10101010;
              end            
              
              if (camac_f == 5'b00000)//Чтение ОЗУ
             begin
               //Чтение ОЗУ
             write <= 0;
               read <= 8'b10101010;
              end
              
              if (camac_f == 5'b11011)//проверка q
             begin
               camac_q <= camac_q;
              end
              
            end

          //--------------------------------------
          auto:
            begin
              camac_q <= 1'b0;
              camac_x <= 1'b1;
              
              if(start == 1'b1) // сброс регистрва адреса
             begin
                 address <= 0;
               end
               
              if (camac_f == 5'b11011)//проверка q
             begin
               camac_q <= camac_q;
              end
              
              if(count == 1'b1) // Счетчик
            begin
               current_counter <= current_counter + 1;
               address <= address + 1; // Для проверки 
              end
           
             if(chanel == 1'b1)
             begin
              // Смена счетчиков
              if(trig == 1'b0)
               begin
                  //counter1 <= current_counter;
                  //current_counter <= counter2;
                  trig <= 1'b1;
                  //Запись данных из неактивного счётчика в ОЗУ
             end
             
             else if(trig == 1'b1)
               begin
                  //counter2 <= current_counter;
                  //current_counter <= counter1;
                  trig <= 1'b0;
                  //Запись данных из неактивного счётчика в ОЗУ
             end
*/
               /*
              Адрес +2
            
               Запоминание адреса для неактивного счетчика
               
             Адрес -1
              */
              /*
            
              end
              
            end

          //--------------------------------------
          amplitude:
            begin
              camac_q <= 1'b1;
              camac_x <= 1'b1;
              
              if(start == 1'b1) // сброс регистрва адреса
             begin
                 address <= 0;
               end
               
              if (camac_f == 5'b11011)//проверка q
             begin
                 camac_q <= camac_q;
              end
              
              if(count == 1'b1) // Счетчик
            begin
               //current_counter = current_counter + 1;
               //current_counter <= 4'b1101;
              end
              
              if((camac_f == 5'b11001) && (camac_s1 == 1'b1))
              begin
              // Смена счетчиков
              if(trig == 0)
               begin
                  //counter1 <= current_counter;
                  //current_counter <= counter2;
                  trig <= 1;
                  //Запись данных из неактивного счётчика в ОЗУ
             end
             
             else if(trig == 1)
               begin
                  //counter2 <= current_counter;
                  //current_counter <= counter1;
                  trig <= 0;
                  //Запись данных из неактивного счётчика в ОЗУ
             end
*/
               /*
              Адрес +2
            
               Запоминание адреса для неактивного счетчика
               
             Адрес -1
              */
              /*
            
              end
              
            end
          //--------------------------------------
        
        endcase
      end
  end
//-------------------------------------------
*/
endmodule




