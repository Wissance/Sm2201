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

#define  COM1 0x300
#define  COM2 0x200

#define  LAST 0x80
#define  NEXT 0x40
#define  FIRST 0xC0

#define OVERRUN 1
#define PARITY 2
#define FRAME 3
#define TIMEOUT 4
#define PRTCL 5

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
	  }

	for(i=0;i<4;i++)
	  {data=0;
	   naf(n,1<<i,0,&data,&xq);
	   delay(300);
	  }

	for(i=0;i<24;i++)
	  {data=1l<<i;
	   naf(n,0,16,&data,&xq);
	   delay(300);
	   naf(n,0,0,&data,&xq);
	   if(data!=(1l<<i) )printf("\n Data Error %lx");
	   delay(300);
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
    if((ic!=0)||((er[ic]%100)==0) )
       {printf("\n");
	for(i=0;i<8;i++)
	   printf("  %i",er[i]);
       }
  }

while(kbhit()) getch();

}
/*------------------------------------------------------------------------*/
void main(void)
{
int n;
portinit(2,57600l);
	printf("\n EASY test.");
	printf("\n Enter Test number  ");
	scanf("%i",&n);
switch(n)
    {case 0: lamps();break;
     case 1: randomtest();
     default:break;

    }
}


