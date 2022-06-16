
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "peripherals.h"

// compiles with sdcc-sdcc version >= 3.7.0

#define CLI __asm cli __endasm;
#define SEI __asm sei __endasm;
#define WAIT __asm wait __endasm;

static volatile unsigned char swic = 0;
static volatile unsigned char hwic = 0;
static volatile unsigned char gpic = 0;
static volatile unsigned char uric = 0;
static volatile unsigned char tmer_ic = 0;



#define ITEMS 256
static unsigned long ar[ITEMS];
static unsigned char dr[ITEMS];

static unsigned char simulation;

void main(void) {

        volatile unsigned char cfg = 0;
        volatile unsigned char freq = 0;
        volatile unsigned char cfg2 = 0;
        unsigned long tdelay = 0;
        int l = 0;

        // get config values
        cfg = *(volatile unsigned char *)GPIO_CFG0_ADDR;
        freq = *(volatile unsigned char *)GPIO_CFG1_ADDR;
        cfg2 = *(volatile unsigned char *)GPIO_CFG2_ADDR;
        simulation = (cfg & (1 << GPIO_CFG0BIT_SIM)) ? 1 : 0;

        // get frequency in MHz
        tdelay = freq;
        // make 1 ms time base for real world
        if (!simulation) {
                tdelay *= 1000;
        } else {
                tdelay *= 20; // scale by 50 for simulation
        }

        // scale to 1 hz
        tdelay *= 1000;

        // output cfg to leds
        *(volatile unsigned char*)GPIO_DATA_ADDR = 0x5a;
        *(volatile unsigned char*)GPIO_DATA_ADDR = cfg;
        *(volatile unsigned char*)GPIO_DATA_ADDR = freq;
        *(volatile unsigned char*)GPIO_DATA_ADDR = cfg2;
        *(volatile unsigned char*)GPIO_DATA_ADDR = simulation ? 0xff : 0;
        *(volatile unsigned char*)GPIO_DATA_ADDR = 0xa5;
        //

        // print info
        if (!simulation) {
                printf("Testprogram %s\r\n",__DATE__);
                printf("cfg: 0x%x\r\n",cfg);
                printf("freq: %d\r\n",freq);
                printf("cfg2: 0x%x\r\n",cfg2);
                printf("tdel: %lu\r\n",tdelay);
        }

        *(volatile unsigned char*)GPIO_DATA_ADDR = 0xc6; 

        // enable gpio irq (for irq test in simulation ...)
        *(volatile unsigned char*)GPIO_CLR_ADDR = 0x0; // default clear
        *(volatile unsigned char*)GPIO_IEN_ADDR = 0xff; // enable all irqs

		// enable uart rxd irq
        *(volatile unsigned char*)UART_IEN_ADDR = 1 << UART_IRQEN_RXD_BIT; // rx data available

        // enable interrupts
        if (!simulation) printf("CLI\r\n");
        CLI

        init_timer();

        // wait for isr
        if (!simulation) printf("Enter loop\r\n");
        while (1) {
                if (0 == (*(volatile unsigned char*)UART_STAT_ADDR & (1 << UART_STATBIT_RXE))) {
                        unsigned char r = *(volatile unsigned char*)UART_DATA_ADDR; // read data
				        *(volatile unsigned char*)UART_IEN_ADDR = 1 << UART_IRQEN_RXD_BIT; // reactivate rx data irq
                        putchar(r);
                }
		        *(volatile unsigned char*)GPIO_DATA_ADDR = uric + gpic + tmer_ic; // show counters on led
                if (!simulation) printf("...WFI...");

                WAIT
        }

}

void init_timer(void){
        *(volatile unsigned char*)TMR_CNTRL_ADDR = 0; // clear control register
        *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 0) = 0x00;
        *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 1) = 0x1b;
        *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 2) = 0xb7;
        *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 3) = 0x00;        // 0xb71b00 is 12 million in decimal


        *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_USE_LOAD_VAL);    // Set use_reload_value bit
        *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_EN_IRQ);          // Set enable_interrupt bit
        *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_EN);              // Set timer_enable bit
}


////////////////////////////////////////////////////////
void swIsr (void) __interrupt (1)    // irq1 is swi
{
        // dummy
        swic++;
        *(volatile unsigned char*)GPIO_DATA_ADDR = swic;

}

void hwIsr (void) __interrupt (2)    // irq2 is pin
{
        // dummy
        hwic++;
        *(volatile unsigned char*)GPIO_DATA_ADDR = hwic;

        // check gpio
        if (*(volatile unsigned char*)GPIO_STAT_ADDR & (1 << GPIO_STATBIT_IRQ)) {
                *(volatile unsigned char*)GPIO_CLR_ADDR = 0x0; // default clear
                gpic++;
        }
        // check uart
        if ((*(volatile unsigned char *)UART_STAT_ADDR & (1 << UART_STATBIT_IRQ))) {
                *((volatile unsigned char *)(UART_IEN_ADDR)) = 0; // turn irq off. no action yet
                uric++;
        }

        // check timer
        if ((*(volatile unsigned char *)TMR_STAT_ADDR & (1 << TMR_STATBIT_IRQ))) {
                *((volatile unsigned char *)(TMR_CLR_ADDR)) = 0x0; // default clear
                tmer_ic++;
        }
}

////////////////////////////////////////////////////////

//void putchar(unsigned char c) __reentrant {
// follow stdio.h declaration here: int putchar(int);
int putchar(int c_) {
        // wait for tx emtpy
        unsigned char c = (unsigned char)c_;
        while (*(volatile unsigned char*)UART_STAT_ADDR & (1 << UART_STATBIT_TXF));
        // send
        *(volatile unsigned char*)UART_DATA_ADDR = c;
        // video output
        return (int)c; // return EOF on error
}


