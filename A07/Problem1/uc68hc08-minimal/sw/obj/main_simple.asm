;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.8.0 #10562 (Linux)
;--------------------------------------------------------
	.module main_simple
	.optsdcc -mhc08
	
	.area HOME    (CODE)
	.area GSINIT0 (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area CSEG    (CODE)
	.area XINIT   (CODE)
	.area CONST   (CODE)
	.area DSEG    (PAG)
	.area OSEG    (PAG, OVR)
	.area XSEG
	.area XISEG
	.area	CODEIVT (ABS)
	.org	0xfffa
	.dw	_hwIsr
	.dw	_swIsr
	.dw	__sdcc_gs_init_startup

	.area GSINIT0
__sdcc_gs_init_startup:
	ldhx	#0x8000
	txs
	jsr	__sdcc_external_startup
	beq	__sdcc_init_data
	jmp	__sdcc_program_startup
__sdcc_init_data:
; _hc08_genXINIT() start
        ldhx #0
00001$:
        cphx #l_XINIT
        beq  00002$
        lda  s_XINIT,x
        sta  s_XISEG,x
        aix  #1
        bra  00001$
00002$:
; _hc08_genXINIT() end
	.area GSFINAL
	jmp	__sdcc_program_startup

	.area CSEG
__sdcc_program_startup:
	jsr	_main
	bra	.
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _hwIsr
	.globl _swIsr
	.globl _init_timer
	.globl _main
	.globl _printf
	.globl _putchar
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area DSEG    (PAG)
;--------------------------------------------------------
; overlayable items in ram 
;--------------------------------------------------------
;--------------------------------------------------------
; absolute ram data
;--------------------------------------------------------
	.area IABS    (ABS)
	.area IABS    (ABS)
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area XABS    (ABS)
;--------------------------------------------------------
; external initialized ram data
;--------------------------------------------------------
	.area XISEG
_swic:
	.ds 1
_hwic:
	.ds 1
_gpic:
	.ds 1
_uric:
	.ds 1
_tmer_ic:
	.ds 1
;--------------------------------------------------------
; extended address mode data
;--------------------------------------------------------
	.area XSEG
_ar:
	.ds 1024
_dr:
	.ds 256
_simulation:
	.ds 1
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area HOME    (CODE)
	.area GSINIT  (CODE)
	.area GSFINAL (CODE)
	.area GSINIT  (CODE)
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area HOME    (CODE)
	.area HOME    (CODE)
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area CSEG    (CODE)
;------------------------------------------------------------
;Allocation info for local variables in function 'main'
;------------------------------------------------------------
;cfg                       Allocated to stack - sp +7
;freq                      Allocated to stack - sp +6
;cfg2                      Allocated to stack - sp +5
;tdelay                    Allocated to stack - sp +1
;l                         Allocated to registers 
;r                         Allocated to registers a 
;sloc0                     Allocated to stack - sp +8
;------------------------------------------------------------
;./src/main_simple.c:28: void main(void) {
;	-----------------------------------------
;	 function main
;	-----------------------------------------
;	Register assignment is optimal.
;	Stack space usage: 11 bytes.
_main:
	ais	#-11
;./src/main_simple.c:30: volatile unsigned char cfg = 0;
	tsx
	clra
	sta	6,x
;./src/main_simple.c:31: volatile unsigned char freq = 0;
	sta	5,x
;./src/main_simple.c:32: volatile unsigned char cfg2 = 0;
	sta	4,x
;./src/main_simple.c:37: cfg = *(volatile unsigned char *)GPIO_CFG0_ADDR;
	lda	*0x82
	sta	6,x
;./src/main_simple.c:38: freq = *(volatile unsigned char *)GPIO_CFG1_ADDR;
	lda	*0x83
	sta	5,x
;./src/main_simple.c:39: cfg2 = *(volatile unsigned char *)GPIO_CFG2_ADDR;
	lda	*0x84
	sta	4,x
;./src/main_simple.c:40: simulation = (cfg & (1 << GPIO_CFG0BIT_SIM)) ? 1 : 0;
	lda	6,x
	bit	#0x01
	beq	00119$
	ldhx	#0x0001
	bra	00120$
00119$:
	clrh
	clrx
00120$:
	stx	_simulation
;./src/main_simple.c:43: tdelay = freq;
	lda	6,s
	sta	11,s
	clra
	sta	10,s
	sta	9,s
	sta	8,s
;./src/main_simple.c:45: if (!simulation) {
	tstx
	bne	00102$
;./src/main_simple.c:46: tdelay *= 1000;
	tsx
	lda	10,x
	psha
	lda	9,x
	psha
	lda	8,x
	psha
	lda	7,x
	psha
	lda	#0xe8
	psha
	lda	#0x03
	psha
	clra
	psha
	psha
	jsr	__mullong
	sta	12,s
	stx	11,s
	lda	*___SDCC_hc08_ret2
	sta	10,s
	lda	*___SDCC_hc08_ret3
	sta	9,s
	ais	#8
	bra	00103$
00102$:
;./src/main_simple.c:48: tdelay *= 20; // scale by 50 for simulation
	tsx
	lda	10,x
	psha
	lda	9,x
	psha
	lda	8,x
	psha
	lda	7,x
	psha
	lda	#0x14
	psha
	clra
	psha
	psha
	psha
	jsr	__mullong
	sta	12,s
	stx	11,s
	lda	*___SDCC_hc08_ret2
	sta	10,s
	lda	*___SDCC_hc08_ret3
	sta	9,s
	ais	#8
00103$:
;./src/main_simple.c:52: tdelay *= 1000;
	tsx
	lda	3,x
	psha
	lda	2,x
	psha
	lda	1,x
	psha
	lda	,x
	psha
	lda	#0xe8
	psha
	lda	#0x03
	psha
	clra
	psha
	psha
	jsr	__mullong
	sta	12,s
	stx	11,s
	lda	*___SDCC_hc08_ret2
	sta	10,s
	lda	*___SDCC_hc08_ret3
	sta	9,s
	ais	#8
;./src/main_simple.c:55: *(volatile unsigned char*)GPIO_DATA_ADDR = 0x5a;
	mov	#0x5a,*0x80
;./src/main_simple.c:56: *(volatile unsigned char*)GPIO_DATA_ADDR = cfg;
	lda	7,s
	sta	*0x80
;./src/main_simple.c:57: *(volatile unsigned char*)GPIO_DATA_ADDR = freq;
	lda	6,s
	sta	*0x80
;./src/main_simple.c:58: *(volatile unsigned char*)GPIO_DATA_ADDR = cfg2;
	lda	5,s
	sta	*0x80
;./src/main_simple.c:59: *(volatile unsigned char*)GPIO_DATA_ADDR = simulation ? 0xff : 0;
	lda	_simulation
	beq	00121$
	clrx
	lda	#0xff
	bra	00122$
00121$:
	clrx
	txa
00122$:
	sta	*0x80
;./src/main_simple.c:60: *(volatile unsigned char*)GPIO_DATA_ADDR = 0xa5;
	mov	#0xa5,*0x80
;./src/main_simple.c:64: if (!simulation) {
	lda	_simulation
	bne	00105$
;./src/main_simple.c:65: printf("Testprogram %s\r\n",__DATE__);
	lda	#___str_1
	psha
	lda	#>___str_1
	psha
	lda	#___str_0
	psha
	lda	#>___str_0
	psha
	jsr	_printf
	ais	#4
;./src/main_simple.c:66: printf("cfg: 0x%x\r\n",cfg);
	lda	7,s
	clrx
	psha
	pshx
	lda	#___str_2
	psha
	lda	#>___str_2
	psha
	jsr	_printf
	ais	#4
;./src/main_simple.c:67: printf("freq: %d\r\n",freq);
	lda	6,s
	clrx
	psha
	pshx
	lda	#___str_3
	psha
	lda	#>___str_3
	psha
	jsr	_printf
	ais	#4
;./src/main_simple.c:68: printf("cfg2: 0x%x\r\n",cfg2);
	lda	5,s
	clrx
	psha
	pshx
	lda	#___str_4
	psha
	lda	#>___str_4
	psha
	jsr	_printf
	ais	#4
;./src/main_simple.c:69: printf("tdel: %lu\r\n",tdelay);
	tsx
	lda	3,x
	psha
	lda	2,x
	psha
	lda	1,x
	psha
	lda	,x
	psha
	lda	#___str_5
	psha
	lda	#>___str_5
	psha
	jsr	_printf
	ais	#6
00105$:
;./src/main_simple.c:72: *(volatile unsigned char*)GPIO_DATA_ADDR = 0xc6; 
	mov	#0xc6,*0x80
;./src/main_simple.c:75: *(volatile unsigned char*)GPIO_CLR_ADDR = 0x0; // default clear
	mov	#0x00,*0x82
;./src/main_simple.c:76: *(volatile unsigned char*)GPIO_IEN_ADDR = 0xff; // enable all irqs
	mov	#0xff,*0x81
;./src/main_simple.c:79: *(volatile unsigned char*)UART_IEN_ADDR = 1 << UART_IRQEN_RXD_BIT; // rx data available
	mov	#0x01,*0xa1
;./src/main_simple.c:82: if (!simulation) printf("CLI\r\n");
	lda	_simulation
	bne	00107$
	lda	#___str_6
	psha
	lda	#>___str_6
	psha
	jsr	_printf
	ais	#2
00107$:
;./src/main_simple.c:83: CLI
	 cli	
;./src/main_simple.c:85: init_timer();
	jsr	_init_timer
;./src/main_simple.c:88: if (!simulation) printf("Enter loop\r\n");
	lda	_simulation
	bne	00115$
	lda	#___str_7
	psha
	lda	#>___str_7
	psha
	jsr	_printf
	ais	#2
;./src/main_simple.c:89: while (1) {
00115$:
;./src/main_simple.c:90: if (0 == (*(volatile unsigned char*)UART_STAT_ADDR & (1 << UART_STATBIT_RXE))) {
	lda	*0xa1
	bit	#0x02
	bne	00111$
;./src/main_simple.c:91: unsigned char r = *(volatile unsigned char*)UART_DATA_ADDR; // read data
	lda	*0xa0
;./src/main_simple.c:92: *(volatile unsigned char*)UART_IEN_ADDR = 1 << UART_IRQEN_RXD_BIT; // reactivate rx data irq
	mov	#0x01,*0xa1
;./src/main_simple.c:93: putchar(r);
	clrx
	jsr	_putchar
00111$:
;./src/main_simple.c:95: *(volatile unsigned char*)GPIO_DATA_ADDR = uric + gpic + tmer_ic; // show counters on led
	lda	_uric
	add	_gpic
	add	_tmer_ic
	sta	*0x80
;./src/main_simple.c:96: if (!simulation) printf("...WFI...");
	lda	_simulation
	bne	00113$
	lda	#___str_8
	psha
	lda	#>___str_8
	psha
	jsr	_printf
	ais	#2
00113$:
;./src/main_simple.c:98: WAIT
	 wait	
	bra	00115$
;./src/main_simple.c:101: }
	ais	#11
	rts
;------------------------------------------------------------
;Allocation info for local variables in function 'init_timer'
;------------------------------------------------------------
;./src/main_simple.c:103: void init_timer(void){
;	-----------------------------------------
;	 function init_timer
;	-----------------------------------------
;	Register assignment is optimal.
;	Stack space usage: 0 bytes.
_init_timer:
;./src/main_simple.c:104: *(volatile unsigned char*)TMR_CNTRL_ADDR = 0; // clear control register
	mov	#0x00,*0x98
;./src/main_simple.c:105: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 0) = 0x00;
	mov	#0x00,*0x90
;./src/main_simple.c:106: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 1) = 0x1b;
	mov	#0x1b,*0x91
;./src/main_simple.c:107: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 2) = 0xb7;
	mov	#0xb7,*0x92
;./src/main_simple.c:108: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 3) = 0x00;        // 0xb71b00 is 12 million in decimal
	mov	#0x00,*0x93
;./src/main_simple.c:111: *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_USE_LOAD_VAL);    // Set use_reload_value bit
	lda	*0x98
	ora	#0x02
	sta	*0x98
;./src/main_simple.c:112: *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_EN_IRQ);          // Set enable_interrupt bit
	lda	*0x98
	ora	#0x04
	sta	*0x98
;./src/main_simple.c:113: *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_EN);              // Set timer_enable bit
	lda	*0x98
	ora	#0x01
	sta	*0x98
;./src/main_simple.c:114: }
	rts
;------------------------------------------------------------
;Allocation info for local variables in function 'swIsr'
;------------------------------------------------------------
;./src/main_simple.c:118: void swIsr (void) __interrupt (1)    // irq1 is swi
;	-----------------------------------------
;	 function swIsr
;	-----------------------------------------
;	Register assignment is optimal.
;	Stack space usage: 0 bytes.
_swIsr:
	pshh
;./src/main_simple.c:121: swic++;
	ldhx	#_swic
	inc	,x
;./src/main_simple.c:122: *(volatile unsigned char*)GPIO_DATA_ADDR = swic;
	lda	_swic
	sta	*0x80
;./src/main_simple.c:124: }
	pulh
	rti
;------------------------------------------------------------
;Allocation info for local variables in function 'hwIsr'
;------------------------------------------------------------
;./src/main_simple.c:126: void hwIsr (void) __interrupt (2)    // irq2 is pin
;	-----------------------------------------
;	 function hwIsr
;	-----------------------------------------
;	Register assignment is optimal.
;	Stack space usage: 0 bytes.
_hwIsr:
	pshh
;./src/main_simple.c:129: hwic++;
	ldhx	#_hwic
	inc	,x
;./src/main_simple.c:130: *(volatile unsigned char*)GPIO_DATA_ADDR = hwic;
	lda	_hwic
	sta	*0x80
;./src/main_simple.c:133: if (*(volatile unsigned char*)GPIO_STAT_ADDR & (1 << GPIO_STATBIT_IRQ)) {
	lda	*0x81
	bit	#0x01
	beq	00102$
;./src/main_simple.c:134: *(volatile unsigned char*)GPIO_CLR_ADDR = 0x0; // default clear
	mov	#0x00,*0x82
;./src/main_simple.c:135: gpic++;
	ldhx	#_gpic
	inc	,x
00102$:
;./src/main_simple.c:138: if ((*(volatile unsigned char *)UART_STAT_ADDR & (1 << UART_STATBIT_IRQ))) {
	lda	*0xa1
	bit	#0x01
	beq	00104$
;./src/main_simple.c:139: *((volatile unsigned char *)(UART_IEN_ADDR)) = 0; // turn irq off. no action yet
	mov	#0x00,*0xa1
;./src/main_simple.c:140: uric++;
	ldhx	#_uric
	inc	,x
00104$:
;./src/main_simple.c:144: if ((*(volatile unsigned char *)TMR_STAT_ADDR & (1 << TMR_STATBIT_IRQ))) {
	lda	*0x99
	bit	#0x01
	beq	00107$
;./src/main_simple.c:145: *((volatile unsigned char *)(TMR_CLR_ADDR)) = 0x0; // default clear
	mov	#0x00,*0x9a
;./src/main_simple.c:146: tmer_ic++;
	ldhx	#_tmer_ic
	inc	,x
00107$:
;./src/main_simple.c:148: }
	pulh
	rti
;------------------------------------------------------------
;Allocation info for local variables in function 'putchar'
;------------------------------------------------------------
;c_                        Allocated to registers a x 
;c                         Allocated to registers a 
;------------------------------------------------------------
;./src/main_simple.c:154: int putchar(int c_) {
;	-----------------------------------------
;	 function putchar
;	-----------------------------------------
;	Register assignment is optimal.
;	Stack space usage: 0 bytes.
_putchar:
;./src/main_simple.c:156: unsigned char c = (unsigned char)c_;
;./src/main_simple.c:157: while (*(volatile unsigned char*)UART_STAT_ADDR & (1 << UART_STATBIT_TXF));
00101$:
	ldx	*0xa1
	psha
	txa
	bit	#0x10
	pula
	bne	00101$
;./src/main_simple.c:159: *(volatile unsigned char*)UART_DATA_ADDR = c;
	sta	*0xa0
;./src/main_simple.c:161: return (int)c; // return EOF on error
	clrx
;./src/main_simple.c:162: }
	rts
	.area CSEG    (CODE)
	.area CONST   (CODE)
___str_0:
	.ascii "Testprogram %s"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_1:
	.ascii "Jun 17 2022"
	.db 0x00
___str_2:
	.ascii "cfg: 0x%x"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_3:
	.ascii "freq: %d"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_4:
	.ascii "cfg2: 0x%x"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_5:
	.ascii "tdel: %lu"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_6:
	.ascii "CLI"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_7:
	.ascii "Enter loop"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_8:
	.ascii "...WFI..."
	.db 0x00
	.area XINIT   (CODE)
__xinit__swic:
	.db #0x00	; 0
__xinit__hwic:
	.db #0x00	; 0
__xinit__gpic:
	.db #0x00	; 0
__xinit__uric:
	.db #0x00	; 0
__xinit__tmer_ic:
	.db #0x00	; 0
	.area CABS    (ABS,CODE)
