module Messbauer_CAMAC_Accumulator
(
    input chanel,
    input start,
	 input count,
	 input [4:0] f,
	 input clk,
	 input rst,
	 input [23:0] read,
	 input s1,
	 
	 output reg [23:0] write,
	 output reg x,
	 output reg q,
	 output reg [11:0] address
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
          if(f == 5'b11010) //запрос перехода в автономный режим
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
				if(f == 5'b11000) //запрос перехода в амплитудный анализ
					begin
					NextState = amplitude;
					end
        end
      //--------------------------------------
      auto:
        begin
          if(f == 5'b01011) //запрос перехода в программный обмен
            begin
              NextState = data_exchange;
            end            
        end
      //--------------------------------------
      amplitude:
        begin
          if(f == 5'b01011) //запрос перехода в программный обмен
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
        q <= 1'b1;
		  x <= 1'b1;
		  address = 12'b0;
        end
    else
      begin
        //чтобы значение выхода изменялось вместе с изменением
        //состояния, а не на следующем такте, анализируем NextState
        case(NextState)
          //--------------------------------------
          data_exchange: 
            begin
              q <= 1'b1;
              x <= 1'b1;
				  
				  if ((f == 5'b01001) && (s1 == 1'b1))//сброс счетчиков
				  begin
					counter1 = 24'b0;
					counter2 = 24'b0;
					current_counter <= counter1;
				  end
				  
				  if ((f == 5'b10001) && (s1 == 1'b1))//перезапись регистра адреса
				  begin
					//перезапись регистра адреса
				  end
				  
				  if ((f == 5'b10000) && (s1 == 1'b1))//Запись данных в ячейку ОЗУ
				  begin
					//Запись данных в ячейку ОЗУ
				  end				  
				  
				  if (f == 5'b00000)//Чтение ОЗУ
				  begin
					//Чтение ОЗУ
				  end
				  
				  if (f == 5'b11011)//проверка q
				  begin
					q <= q;
				  end
				  
            end

          //--------------------------------------
          auto:
            begin
              q <= 1'b0;
              x <= 1'b1;
				  
				  if(start == 1'b1) // сброс регистрва адреса
					begin
						//address <= 0;
					end
					
				  if (f == 5'b11011)//проверка q
				  begin
					q <= q;
				  end
				  
				  if(count == 1'b1) // Счетчик
				  begin
					current_counter = current_counter + 1;
				  end
				  
				  if(chanel == 1'b1)
				  begin
				  /* Смена счетчиков
					if(current_counter = counter1)
					begin
						counter = counter1
					end
					if(current_counter = counter2)
					begin
						
					end
					
					Запись данных из неактивного счётчика в ОЗУ
					
					Адрес +2
					
					Запоминание адреса для неактивного счетчика
					
					Адрес -1
					*/
					
				  end
				  
            end

          //--------------------------------------
          amplitude:
            begin
              q <= 1'b1;
              x <= 1'b1;
            end
          //--------------------------------------
        
        endcase
      end
  end
//-------------------------------------------
endmodule




