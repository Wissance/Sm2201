#include <windows.h>
#include <dos.h>


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

#define OVERRUN 1
#define PARITY 2
#define FRAME 3
#define TIMEOUT 4
#define PRTCL 5
#define BREAK 6

static unsigned char
       old_ie, old_ii, old_lc, old_mc, old_ls, old_ms, old_dl, old_dh;
static unsigned long itimer;

/*------------------------------------------------------------------------*/
unsigned long FAR PASCAL iclock(void)
{itimer++;
 return (itimer/1000);
}

/*------------------------------------------------------------------------*/
int FAR PASCAL outrs(int comb, unsigned char data)
{
unsigned long int  t0;
t0=iclock();
while( (inportb(comb+LS)&0x20)==0 )
	{if( (iclock()-t0) > 100l ) return(TIMEOUT);}
outportb(comb+DR, data);
return(0);
}
/*------------------------------------------------------------------------*/
int FAR PASCAL  inrs(int comb, unsigned char far* data)
{
int ic;
unsigned long int t0;
do
 {
 t0=iclock();
 while( ( (ic=inportb(comb+LS)) &1) == 0 )
	{if( (iclock()-t0) > 100l ) return(TIMEOUT);}

 *data=inportb(comb+DR);
 if(ic&2) return (OVERRUN);
 if(ic&4) return (PARITY);
 if(ic&8) return (FRAME);
 }
while( (*data)==LAM );
 return(0);

}
/*------------------------------------------------------------------------*/
int FAR PASCAL naf(int far *base, int n,int a,int f,unsigned long far* data,int far* xq )
{
int ic,comb;
unsigned char dd;
comb=*base;
inportb(comb+MS);
inportb(comb+DR);
inportb(comb+LS);

if((ic=outrs(comb,(n&0x3f)|FIRST))!=0) return(ic);
if((ic=outrs(comb,a&0x3f))!=0) return(ic);

if( (f>=16) && (f<24) )
      {  if((ic=outrs(comb,f&0x3f))!=0) return(ic);
         if((ic=outrs(comb,(*data)&0x3f))!=0) return(ic);
         if((ic=outrs(comb,((*data)>>6)&0x3f))!=0) return(ic);
         if((ic=outrs(comb,((*data)>>12)&0x3f))!=0) return(ic);
         dd=((*data)>>18)&0x3fl;
         if((ic=outrs(comb,dd|LAST))!=0) return(ic);
      }
else     if((ic=outrs(comb,(f&0x3f)|LAST))!=0) return(ic);

*xq=0;
if((ic=inrs(comb,&dd))!=0)   return(ic);
if(((*xq=dd)&0xC0)==LAST)    {*xq=*xq & 0xF; return(0);}
if( (dd&0xC0)!=0)            return(BREAK); 
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=dd&0x3f;
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=*data|(((long)(dd&0x3f))<<6);
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=*data|(((long)(dd&0x3f))<<12);
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=*data|(((long)(dd&0x3f))<<18);
if((dd&LAST)!=LAST)     return(PRTCL);
 return(0);
}
/*------------------------------------------------------------------------*/
int FAR PASCAL  naf16(int far *base,int n,int a,int f,unsigned int far * data,int far* xq )
{
int ic,comb;
unsigned char dd;
comb=*base;
inportb(comb+MS);
inportb(comb+DR);
inportb(comb+LS);

if((ic=outrs(comb,(n&0x3f)|FIRST))!=0) return(ic);
if((ic=outrs(comb,a&0x3f))!=0) return(ic);

if( (f>=16) && (f<24) )
      {  if((ic=outrs(comb,f&0x3f))!=0) return(ic);
         if((ic=outrs(comb,(*data)&0x3f))!=0) return(ic);
         if((ic=outrs(comb,((*data)>>6)&0x3f))!=0) return(ic);
         dd=((*data)>>12)&0xfl;
         if((ic=outrs(comb,dd|LAST))!=0) return(ic);
      }
else     if((ic=outrs(comb,(f&0x3f)|LAST))!=0) return(ic);

*xq=0;
if((ic=inrs(comb,&dd))!=0)   return(ic);
if(((*xq=dd)&0xC0)==LAST)   {*xq=*xq & 0xF; return(0);}
if( (dd&0xC0)!=0)            return(BREAK); 
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=dd&0x3f;
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=*data|((dd&0x3f)<<6);
if((dd&LAST)==LAST)     return(0);
if((ic=outrs(comb,NEXT))!=0) return(ic);

if((ic=inrs(comb,&dd))!=0)    return(ic);
*data=*data|((dd&0xf)<<12);
if((dd&LAST)==LAST)     return(PRTCL);
return(0);
}

/*------------------------------------------------------------------------*/
int FAR PASCAL initport(int far *base,int com,long baud)
{
unsigned long data=0l;
int xq,ic,comb;
comb=*base;
if(com==2) {comb=COM2; *base=COM2;}
else       {comb=COM1; *base=COM1;}

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


ic=naf(base,0,0,16,&data,&xq);  /* No Lam allowed */
ic=naf(base,0,3,16,&data,&xq);  /* Clear reset counter*/
ic=naf(base,0,1,0,&data,&xq );  /* Read LAM register , LAM led off */

return(ic);
}
/*------------------------------------------------------------------------*/

void FAR PASCAL  restoreport(int comb)
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


