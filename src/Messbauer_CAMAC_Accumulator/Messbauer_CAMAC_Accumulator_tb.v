
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
wire trig;

reg [31:0] counter;

Messbauer_CAMAC_Accumulator uut
(
.clk(clk),
.rst(rst),
.chanel(chanel),
.start(start),
.count(count),
.f(f),
.read(read),
.s1(s1),
.write(write),
.x(x),
.q(q),
.address(address),
.trig(trig)
);
//

initial
begin
    clk <= 0;
    rst <= 1;
    counter <= 0;
    #400
    rst <= 0;
end
//
 
always
begin
#50 clk <= ~clk;
//Проверка Программного обмена.
#100 counter <= counter + 1;
	if (counter == 1) //Проверка игнорирования
	begin
		start <= 1;
	end
	
	if (counter == 2)
	begin
		start <= 0;
	end
	
	if (counter == 3)
	begin	
		chanel <= 1;
	end
	
	if (counter == 4)
	begin	
		chanel <= 0;
	end
	
	if (counter == 5)
	begin	
		count <= 1;
	end
	
	if (counter == 6)
	begin	
		count <= 0;
	end
	
	if (counter == 7) //f(9) + s1 сброс счетчиков
	begin
		f <= 5'b01001;
		s1 <= 1;
	end
	
	if (counter == 8)
	begin
		s1 <= 0;
	end
	
	if (counter == 9)//f(17) + s1
	begin
		f <= 5'b10001;
		s1 <= 1;
	end
	
	if (counter == 10)
	begin
		s1 <= 0;
	end
	
	if (counter == 11)//f(16) + s1
	begin
		f <= 5'b10000;
		s1 <= 1;
	end
	
	if (counter == 12)
	begin
		s1 <= 0;
	end
	
	if (counter == 13)//f(0) чтение
	begin
		f <= 5'b00000;
	end
	
	if (counter == 14)//Проверка q f(27)
	begin
		f <= 5'b11011;
	end
//-----------------------------------------------------------
if (counter == 15)//Проверка Автономного режима
	begin
		f <= 5'b11010;
	end
	
	if (counter == 16)//Проверка start
	begin
		start <= 1;
		f <= 5'b11010;
	end
	
	if (counter == 18)
	begin
		start <= 0;
	end
	
	if (counter == 19)//Проверка count
	begin
		count <= 1;
	end
	
	if (counter == 20)
	begin
		count <= 0;
	end
	
	if (counter == 21)
	begin
		count <= 1;
	end
	
	if (counter == 22)
	begin
		count <= 0;
	end
	
	if (counter == 23)//Проверка chanel
	begin
		chanel <= 1'b1;
	end
	
	if (counter == 24)
	begin
		chanel <= 1'b0;
	end
	
		if (counter == 25)
	begin
		chanel <= 1;
	end
	
		if (counter == 26)
	begin
		chanel <= 0;
	end
	
		if (counter == 27)//Проверка start
	begin
		start <= 1;
	end
	
		if (counter == 28)
	begin
		start <= 0;
	end
	
	if (counter == 29)//Проверка q f(27)
	begin
		f <= 5'b11011;
	end
//------------------------------------------------
if (counter == 30)//Возврат в программный обмен
begin
	f <= 5'b01011;
end

	if (counter == 32)//Проверка q f(27)
	begin
		f <= 5'b11011;
	end
//------------------------------------------------
if (counter == 33)//Преход в Амплитудный анализ
begin
	f <= 5'b01011;
end

	if (counter == 35)//Проверка q f(27)
	begin
		f <= 5'b11011;
	end
//-------------------------------------------------
if (counter == 36)//Проверка Амплитудного анализа
	begin
		f <= 5'b11010;
	end
	
	if (counter == 37)//Проверка start
	begin
		start <= 1;
	end
	
	if (counter == 38)
	begin
		start <= 0;
	end
	
	if (counter == 39)//Проверка count
	begin
		count <= 1;
	end
	
	if (counter == 40)
	begin
		count <= 0;
	end
	
	if (counter == 41)
	begin
		count <= 1;
	end
	
	if (counter == 42)
	begin
		count <= 0;
	end
	
	if (counter == 43)//Проверка f(25) + s1
	begin
		f <= 5'b10000;
		s1 <= 1;
	end
	
	if (counter == 44)
	begin
		s1 <= 0;
	end
	
		if (counter == 45)
	begin
		f <= 5'b10000;
		s1 <= 1;
	end
	
		if (counter == 46)
	begin
		s1 <= 0;
	end
	
		if (counter == 47)//Проверка start
	begin
		start <= 1;
	end
	
		if (counter == 48)
	begin
		start <= 0;
	end
//-------------------------------------------------
	if (counter == 49)//Возврат в программный обмен
begin
	f <= 5'b01011;
end

	if (counter == 50)//Проверка q f(27)
	begin
		f <= 5'b11011;
	end
end
// 
 
endmodule
