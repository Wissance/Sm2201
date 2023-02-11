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
// Dependencies: 
//
// Revision: 
// Revision 1.0
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Messbauer_CAMAC_Accumulator #
(
    CAMAC_DATA_WIDTH = 24,
    CAMAC_FUNC_WIDTH = 5,
    MESSB_ACC_ADDRESS_WIDTH = 12
)
(
    // Общие сигналы управления: тактовая частота и чигнал сброса
    input clk,
    input rst,
    // Спектрометрические сигналы
    input chanel,  
    input start,
    input count,
    output reg [MESSB_ACC_ADDRESS_WIDTH:0] address,

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

					/*
					Адрес +2
					
					Запоминание адреса для неактивного счетчика
					
					Адрес -1
					*/
					
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

					/*
					Адрес +2
					
					Запоминание адреса для неактивного счетчика
					
					Адрес -1
					*/
					
				  end
				  
            end
          //--------------------------------------
        
        endcase
      end
  end
//-------------------------------------------
endmodule




