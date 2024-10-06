/*  Header file for EASYLIB.lib */

#include<stdio.h>
#include<dos.h>
#include<time.h>

#ifndef __LARGE__
#error EASYLIB valid in LARGE model only
#endif

/*  functions can return following values:*/
#define CC_OK           0
#define OVERRUN         1
#define PARITY          2
#define FRAME           3
#define TIMEOUT         4
#define PRTCL           5


int  portinit(int com,long baudrate);
/*   Example:
     portinit(2,57600l) store old port settings in static vars and
     initialize port 2 to baudrate 57600baud.
     No interrupt handler or driver allowed to be  active on  COM2 port.
*/


int  naf(int n,int a,int f,long *data,int *xq);
/*   Execute 24 bit naf */



int  naf16(int n,int a,int f,unsigned int *data,int *xq);
/*   Execute 16 bit naf , state of high 8 bits not defined. */




void restoreport(void);
/*   Restore old port settings */











