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
#define  LAM   0x40

/*#define OVERRUN 1
#define PARITY 2
#define FRAME 3
#define TIMEOUT 4
#define PRTCL 5*/

static unsigned char
       old_ie, old_ii, old_lc, old_mc, old_ls, old_ms, old_dl, old_dh;

static int
       comb;

/*------------------------------------------------------------------------*/
int outrs(unsigned char data)
{
clock_t t0;
t0=clock();
while( (inportb(comb+LS)&0x20)==0 )
	{if( (clock()-t0) > 2 ) return(TIMEOUT);}
outportb(comb+DR, data);
return(0);
}
/*------------------------------------------------------------------------*/
int inrs(unsigned char* data)
{
int ic;
clock_t t0;
do
 {
 t0=clock();
 while( ( (ic=inportb(comb+LS)) &1) == 0 )
	{if( (clock()-t0) > 2 ) return(TIMEOUT);}

 *data=inportb(comb+DR);
 if(ic&2) return (OVERRUN);
 if(ic&4) return (PARITY);
 if(ic&8) return (FRAME);
 }
while( (*data)==LAM );
 return(0);

}
/*------------------------------------------------------------------------*/
int naf(int n,int a,int f,long* data,int* xq )
{
int ic;
unsigned char dd;
inportb(comb+MS);
inportb(comb+DR);
inportb(comb+LS);

if((ic=outrs((n&0x3f)|FIRST))!=0) return(ic);
if((ic=outrs(a&0x3f))!=0) return(ic);

if( (f>=16) && (f<24) )
      {  if((ic=outrs(f&0x3f))!=0) return(ic);
	 if((ic=outrs((*data)&0x3f))!=0) return(ic);
	 if((ic=outrs(((*data)>>6)&0x3f))!=0) return(ic);
	 if((ic=outrs(((*data)>>12)&0x3f))!=0) return(ic);
	 dd=((*data)>>18)&0x3fl;
	 if((ic=outrs(dd|LAST))!=0) return(ic);
      }
else     if((ic=outrs((f&0x3f)|LAST))!=0) return(ic);

*xq=0;
if((ic=inrs(&dd))!=0)   return(ic);
if(((*xq=dd)&LAST)==LAST)    return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=dd&0x3f;
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=*data|(((long)(dd&0x3f))<<6);
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=*data|(((long)(dd&0x3f))<<12);
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=*data|(((long)(dd&0x3f))<<18);
if((dd&LAST)!=LAST)     return(PRTCL);
 return(0);
}
/*------------------------------------------------------------------------*/
int naf16(int n,int a,int f,unsigned int* data,int* xq )
{
int ic;
unsigned char dd;
inportb(comb+MS);
inportb(comb+DR);
inportb(comb+LS);

if((ic=outrs((n&0x3f)|FIRST))!=0) return(ic);
if((ic=outrs(a&0x3f))!=0) return(ic);

if( (f>=16) && (f<24) )
      {  if((ic=outrs(f&0x3f))!=0) return(ic);
	 if((ic=outrs((*data)&0x3f))!=0) return(ic);
	 if((ic=outrs(((*data)>>6)&0x3f))!=0) return(ic);
	 dd=((*data)>>12)&0xfl;
	 if((ic=outrs(dd|LAST))!=0) return(ic);
      }
else     if((ic=outrs((f&0x3f)|LAST))!=0) return(ic);

*xq=0;
if((ic=inrs(&dd))!=0)   return(ic);
if(((*xq=dd)&LAST)==LAST)    return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=dd&0x3f;
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=*data|((dd&0x3f)<<6);
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(NEXT))!=0) return(ic);

if((ic=inrs(&dd))!=0)    return(ic);
*data=*data|((dd&0xf)<<12);
if((dd&LAST)==LAST)     return(0);
return(0);
}

/*------------------------------------------------------------------------*/
int portinit(int com,long baud)
{
long data=0l;
int xq,ic;
if(com==2) comb=COM2;
else       comb=COM1;

old_ie=inportb(comb+IE);
old_ii=inportb(comb+II);
old_lc=inportb(comb+LC);
old_mc=inportb(comb+MC);
old_ls=inportb(comb+LS);
old_ms=inportb(comb+MS);
outportb(comb+LC,0x80);
old_dl=inportb(comb+DR);
old_dh=inportb(comb+IE);

outportb(comb+DR,(unsigned char)(115200l/baud)&0xff);
outportb(comb+IE,(unsigned char)((115200l/baud)>>8)&0xff);
outportb(comb+LC,0x1f);
outportb(comb+IE,0);
outportb(comb+MC,0xb);


ic=naf(0,0,16,&data,&xq);  /* No Lam allowed */
ic=naf(0,3,16,&data,&xq);  /* Clear reset counter*/
ic=naf(0,1,0,&data,&xq );  /* Read LAM register , LAM led off */

return(ic);
}
/*------------------------------------------------------------------------*/

void restoreport(void)
{
outportb(comb+LC,0x80);
outportb(comb+DR,old_dl);
outportb(comb+IE,old_dh);
outportb(comb+LC,old_lc);
outportb(comb+IE,old_ie);
outportb(comb+II,old_ii);
outportb(comb+MC,old_mc);
outportb(comb+LS,old_ls);
outportb(comb+MS,old_ms);
}


