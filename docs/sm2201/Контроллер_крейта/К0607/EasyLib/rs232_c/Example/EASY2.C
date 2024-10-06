#include <stdio.h>
#include <dos.h>
#include <time.h>
#include <conio.h>
#include <stdlib.h>
#include "easylib.h"

#define  DR 0xf8
#define  IE 0xf9
#define  II 0xfa
#define  LC 0xfb
#define  MC 0xfc
#define  LS 0xfd
#define  MS 0xfe

/*#define  COM1 0x300
#define  COM2 0x200

#define  LAST 0x80
#define  NEXT 0x40
#define  FIRST 0xC0

#define OVERRUN 1
#define PARITY 2
#define FRAME 3
#define TIMEOUT 4
#define PRTCL 5*/

/*------------------------------------------------------------------------*/
void lamps(void)
{
int n,xq,i;
long data;
	printf("\n Enter N= ");
	scanf("%i",&n);

while(!kbhit())
	{
	data=2;
	naf(0,2,16,&data,&xq);
	delay(300);

	data=4;
	naf(0,2,16,&data,&xq);
	delay(300);

	data=1;
	naf(0,2,16,&data,&xq);
	delay(300);
	data=0;
	naf(0,2,16,&data,&xq);


	for(i=0;i<5;i++)
	  {data=0;
	   naf(n,0,1<<i,&data,&xq);
	   delay(300);
	   if(kbhit()) break;
	  }

	for(i=0;i<4;i++)
	  {data=0;
	   naf(n,1<<i,0,&data,&xq);
	   delay(300);
	   if(kbhit()) break;
	  }

	for(i=0;i<24;i++)
	  {data=1l<<i;
	   naf(n,0,16,&data,&xq);
	   delay(300);
	   naf(n,0,0,&data,&xq);
	   if(data!=(1l<<i) )printf("\n Data Error %lx|%lx",data,(1l<<i));
	   delay(300);
	   if(kbhit()) break;
	  }

	}
while(kbhit()) getch();

}

/*------------------------------------------------------------------------*/
void randomtest(void)
{
int n,xq,ic,i;
long er[8]={0,0,0,0,0,0,0,0};
long data,dd;
	printf("\n Enter N= ");
	scanf("%i",&n);

while(!kbhit())
  {
    data=rand()+((long)rand()<<15);
    dd=data;
    ic=naf(n,0,16,&data,&xq);
    er[ic]++;

    data=0;
    ic=naf(n,0,0,&data,&xq);
    if((xq!=3)&&(ic==0) ) {ic=7;
			   printf("\n xq=%x",xq);
			  }
    if(((dd&0xffffffl)!=(data&0xffffffl))&&(ic==0)  ) {ic=6;
					  printf("\n %lx - %lx",dd,data);
					 }
    er[ic]++;
    if((ic!=0)||(((er[ic]&0xfffffffel)%100)==0) )
       {printf("\n");
	for(i=0;i<8;i++)
	   printf("  %li",er[i]);
       }
  }

while(kbhit()) getch();

}
/*------------------------------------------------------------------------*/
void randomtest16(void)
{
int n,xq,ic,i;
long er[8]={0,0,0,0,0,0,0,0};
unsigned data,dd;
	printf("\n Enter N= ");
	scanf("%i",&n);

while(!kbhit())
  {
    data=rand()+((unsigned int)rand()<<15);
    dd=data;
    ic=naf16(n,0,16,&data,&xq);
    er[ic]++;

    data=0;
    ic=naf16(n,0,0,&data,&xq);
    if((xq!=3)&&(ic==0) ) {ic=7;
			   printf("\n xq=%x",xq);
			  }
    if(((dd&0xffff)!=(data&0xffff))&&(ic==0)  ) {ic=6;
					  printf("\n %x - %x",dd,data);
					 }
    er[ic]++;
    if((ic!=0)||(((er[ic]&0xfffffffel)%100)==0) )
       {printf("\n");
	for(i=0;i<8;i++)
	   printf("  %li",er[i]);
       }
  }

while(kbhit()) getch();

}
/*------------------------------------------------------------------------*/
void naftest(void)
{int ic,n,a,f,xq;
 long data;
 while(1)
 {printf("\n N,A,F,0xDATA\n");
  scanf("%i%i%i%lx",&n,&a,&f,&data);
  ic=naf(n,a,f,&data,&xq);
  printf("   ic=%i, xq=%i, data=%lx",ic,xq,data);
 }
}

/*------------------------------------------------------------------------*/
void naftestc(void)
{int ic,n,a,f,xq;
 long data;
  printf("\n N,A,F,0xDATA\n");
  scanf("%i%i%i%lx",&n,&a,&f,&data);

  while(!kbhit()) naf(n,a,f,&data,&xq);
  getch();

}
/*------------------------------------------------------------------------*/
void ntestc(void)
{int ic,n=1,a=0,f=24,xq;
 long data;
 while(1)
 {
  printf("\n N=%i",n);
  while(!kbhit()) naf(n,a,f,&data,&xq);
  ic=getch();
  switch (ic)
   {
   case '+':	n++;
		if(n>23) {n=23; sound(200);delay(200);nosound();}
		break;

   case '-':	n--;
		if(n<1) {n=1; sound(200);delay(200);nosound();}
		break;
   default :	return;
   }
 }
}

/*------------------------------------------------------------------------*/
void readreset(void)
{int xq,ic;
 long data;
 ic=naf(0,3,0,&data,&xq);
 printf("\n Reset counter=%i    xq=%i    ic=%i",(int)(data&0xffl),xq,ic );

}
/*------------------------------------------------------------------------*/
void readlam(void)
{int xq,ic,i;
 long data;
 do{
 ic=naf(0,1,0,&data,&xq);
 printf("\r xq=%2i   ic=%2i  ",xq,ic );
    for(i=0;i<24;i++) printf("%i",(data>>(23-i))&1);
 }
 while(!kbhit());

}

/*------------------------------------------------------------------------*/
void main(void)
{
int n,comn;
printf("\n Enter COM No=");
scanf("%i",&comn);
portinit(comn,57600l);

while(1)
{
	printf("\n EASY test.");
	printf("\n Enter Test number  ");
	printf("\n 0 - Indicator lamps test");
	printf("\n 1 - 24 bit write/read random test");
	printf("\n 2 - 16 bit write/read random test");
	printf("\n 3 - NAF");
	printf("\n 4 - Read reset counter register.");
	printf("\n 5 - Read LAM state");
	printf("\n 6 - cycle NAF");
	printf("\n 7 - N Test");
	printf("\n 8 - EXIT");
	printf("\n->");
	n=getch();
  switch(n)
    {case '0': lamps();break;
     case '1': randomtest();break;
     case '2': randomtest16();break;
     case '3': naftest();break;
     case '4': readreset();break;
     case '5': readlam();break;
     case '6': naftestc();break;
     case '7': ntestc();break;
     default:exit(0);

    }
 }
}


