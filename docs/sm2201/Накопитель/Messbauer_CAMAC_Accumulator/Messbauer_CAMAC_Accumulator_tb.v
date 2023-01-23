
module Messbauer_CAMAC_Accumulator_tb();
	 
reg chanel;
reg start;
reg count;
reg [4:0] f;
reg clk;
reg rst;
wire [23:0] read;
reg s1;
wire [23:0] write;
wire x;
wire q;
wire [11:0] address;
wire [1:0] trig;

//reg [31:0] counter;

Messbauer_CAMAC_Accumulator uut
(
.chanel(chanel),
.start(start),
.count(count),
.f(f),
.clk(clk),
.rst(rst),
.read(read),
.s1(s1),
.write(write),
.x(x),
.q(q),
.address(address),
.trig(trig),
);
//

initial
begin
    clk <= 0;
    reset <= 1;
    counter <= 0;
    # 400
    reset <= 0;
end
//
 
 always
begin
//Проверка Программного обмена.
	//Проверка игнорирования
	start <= 1;
	#100
	start <= 0;
	chanel <= 1;
	#100
	chanel <= 0;
	count <= 1;
	#100
	count <= 0;
	//f(9) сброс счетчиков
	
	//f(17) + s1
	
	//f(16) + s1
	
	//f(0) чтение
	
	//Проверка q f(27)

//Проверка Автономного режима

	//Проверка start
	
	//Проверка count
	
	//Проверка chanel
	
	//Проверка start
	
	//Проверка q

//Возврат в программный обмен
	
	//Проверка q

//Преход в Амплитудный анализ

	//Проверка q

//Проверка Амплитудного анализа

	//Проверка start
	
	//Проверка count
	
	//Проверка f(25) + s1
	
	//Проверка start
	
	//Проверка q

end
// 
 
endmodule
