ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 1.
Hexadecimal [16-Bits]



                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.8.0 #10562 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module main_simple
                              6 	.optsdcc -mhc08
                              7 	
                              8 	.area HOME    (CODE)
                              9 	.area GSINIT0 (CODE)
                             10 	.area GSINIT  (CODE)
                             11 	.area GSFINAL (CODE)
                             12 	.area CSEG    (CODE)
                             13 	.area XINIT   (CODE)
                             14 	.area CONST   (CODE)
                             15 	.area DSEG    (PAG)
                             16 	.area OSEG    (PAG, OVR)
                             17 	.area XSEG
                             18 	.area XISEG
                             19 	.area	CODEIVT (ABS)
   FFFA                      20 	.org	0xfffa
   FFFA 81 F0                21 	.dw	_hwIsr
   FFFC 81 E4                22 	.dw	_swIsr
   FFFE 80 00                23 	.dw	__sdcc_gs_init_startup
                             24 
                             25 	.area GSINIT0
   8000                      26 __sdcc_gs_init_startup:
   8000 45 80 00      [ 3]   27 	ldhx	#0x8000
   8003 94            [ 2]   28 	txs
   8004 CD 82 30      [ 5]   29 	jsr	__sdcc_external_startup
   8007 27 03         [ 3]   30 	beq	__sdcc_init_data
   8009 CC 80 21      [ 3]   31 	jmp	__sdcc_program_startup
   800C                      32 __sdcc_init_data:
                             33 ; _hc08_genXINIT() start
   800C 45 00 00      [ 3]   34         ldhx #0
   800F                      35 00001$:
   800F 65 00 05      [ 3]   36         cphx #l_XINIT
   8012 27 0A         [ 3]   37         beq  00002$
   8014 D6 91 3A      [ 4]   38         lda  s_XINIT,x
   8017 D7 65 01      [ 4]   39         sta  s_XISEG,x
   801A AF 01         [ 2]   40         aix  #1
   801C 20 F1         [ 3]   41         bra  00001$
   801E                      42 00002$:
                             43 ; _hc08_genXINIT() end
                             44 	.area GSFINAL
   801E CC 80 21      [ 3]   45 	jmp	__sdcc_program_startup
                             46 
                             47 	.area CSEG
   8021                      48 __sdcc_program_startup:
   8021 CD 80 26      [ 5]   49 	jsr	_main
   8024 20 FE         [ 3]   50 	bra	.
                             51 ;--------------------------------------------------------
                             52 ; Public variables in this module
                             53 ;--------------------------------------------------------
                             54 	.globl _hwIsr
                             55 	.globl _swIsr
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 2.
Hexadecimal [16-Bits]



                             56 	.globl _init_timer
                             57 	.globl _main
                             58 	.globl _printf
                             59 	.globl _putchar
                             60 ;--------------------------------------------------------
                             61 ; ram data
                             62 ;--------------------------------------------------------
                             63 	.area DSEG    (PAG)
                             64 ;--------------------------------------------------------
                             65 ; overlayable items in ram 
                             66 ;--------------------------------------------------------
                             67 ;--------------------------------------------------------
                             68 ; absolute ram data
                             69 ;--------------------------------------------------------
                             70 	.area IABS    (ABS)
                             71 	.area IABS    (ABS)
                             72 ;--------------------------------------------------------
                             73 ; absolute external ram data
                             74 ;--------------------------------------------------------
                             75 	.area XABS    (ABS)
                             76 ;--------------------------------------------------------
                             77 ; external initialized ram data
                             78 ;--------------------------------------------------------
                             79 	.area XISEG
   6501                      80 _swic:
   6501                      81 	.ds 1
   6502                      82 _hwic:
   6502                      83 	.ds 1
   6503                      84 _gpic:
   6503                      85 	.ds 1
   6504                      86 _uric:
   6504                      87 	.ds 1
   6505                      88 _tmer_ic:
   6505                      89 	.ds 1
                             90 ;--------------------------------------------------------
                             91 ; extended address mode data
                             92 ;--------------------------------------------------------
                             93 	.area XSEG
   6000                      94 _ar:
   6000                      95 	.ds 1024
   6400                      96 _dr:
   6400                      97 	.ds 256
   6500                      98 _simulation:
   6500                      99 	.ds 1
                            100 ;--------------------------------------------------------
                            101 ; global & static initialisations
                            102 ;--------------------------------------------------------
                            103 	.area HOME    (CODE)
                            104 	.area GSINIT  (CODE)
                            105 	.area GSFINAL (CODE)
                            106 	.area GSINIT  (CODE)
                            107 ;--------------------------------------------------------
                            108 ; Home
                            109 ;--------------------------------------------------------
                            110 	.area HOME    (CODE)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 3.
Hexadecimal [16-Bits]



                            111 	.area HOME    (CODE)
                            112 ;--------------------------------------------------------
                            113 ; code
                            114 ;--------------------------------------------------------
                            115 	.area CSEG    (CODE)
                            116 ;------------------------------------------------------------
                            117 ;Allocation info for local variables in function 'main'
                            118 ;------------------------------------------------------------
                            119 ;cfg                       Allocated to stack - sp +7
                            120 ;freq                      Allocated to stack - sp +6
                            121 ;cfg2                      Allocated to stack - sp +5
                            122 ;tdelay                    Allocated to stack - sp +1
                            123 ;l                         Allocated to registers 
                            124 ;r                         Allocated to registers a 
                            125 ;sloc0                     Allocated to stack - sp +8
                            126 ;------------------------------------------------------------
                            127 ;./src/main_simple.c:28: void main(void) {
                            128 ;	-----------------------------------------
                            129 ;	 function main
                            130 ;	-----------------------------------------
                            131 ;	Register assignment is optimal.
                            132 ;	Stack space usage: 11 bytes.
   8026                     133 _main:
   8026 A7 F5         [ 2]  134 	ais	#-11
                            135 ;./src/main_simple.c:30: volatile unsigned char cfg = 0;
   8028 95            [ 2]  136 	tsx
   8029 4F            [ 1]  137 	clra
   802A E7 06         [ 3]  138 	sta	6,x
                            139 ;./src/main_simple.c:31: volatile unsigned char freq = 0;
   802C E7 05         [ 3]  140 	sta	5,x
                            141 ;./src/main_simple.c:32: volatile unsigned char cfg2 = 0;
   802E E7 04         [ 3]  142 	sta	4,x
                            143 ;./src/main_simple.c:37: cfg = *(volatile unsigned char *)GPIO_CFG0_ADDR;
   8030 B6 82         [ 3]  144 	lda	*0x82
   8032 E7 06         [ 3]  145 	sta	6,x
                            146 ;./src/main_simple.c:38: freq = *(volatile unsigned char *)GPIO_CFG1_ADDR;
   8034 B6 83         [ 3]  147 	lda	*0x83
   8036 E7 05         [ 3]  148 	sta	5,x
                            149 ;./src/main_simple.c:39: cfg2 = *(volatile unsigned char *)GPIO_CFG2_ADDR;
   8038 B6 84         [ 3]  150 	lda	*0x84
   803A E7 04         [ 3]  151 	sta	4,x
                            152 ;./src/main_simple.c:40: simulation = (cfg & (1 << GPIO_CFG0BIT_SIM)) ? 1 : 0;
   803C E6 06         [ 3]  153 	lda	6,x
   803E A5 01         [ 2]  154 	bit	#0x01
   8040 27 05         [ 3]  155 	beq	00119$
   8042 45 00 01      [ 3]  156 	ldhx	#0x0001
   8045 20 02         [ 3]  157 	bra	00120$
   8047                     158 00119$:
   8047 8C            [ 1]  159 	clrh
   8048 5F            [ 1]  160 	clrx
   8049                     161 00120$:
   8049 CF 65 00      [ 4]  162 	stx	_simulation
                            163 ;./src/main_simple.c:43: tdelay = freq;
   804C 9E E6 06      [ 4]  164 	lda	6,s
   804F 9E E7 0B      [ 4]  165 	sta	11,s
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 4.
Hexadecimal [16-Bits]



   8052 4F            [ 1]  166 	clra
   8053 9E E7 0A      [ 4]  167 	sta	10,s
   8056 9E E7 09      [ 4]  168 	sta	9,s
   8059 9E E7 08      [ 4]  169 	sta	8,s
                            170 ;./src/main_simple.c:45: if (!simulation) {
   805C 5D            [ 1]  171 	tstx
   805D 26 2D         [ 3]  172 	bne	00102$
                            173 ;./src/main_simple.c:46: tdelay *= 1000;
   805F 95            [ 2]  174 	tsx
   8060 E6 0A         [ 3]  175 	lda	10,x
   8062 87            [ 2]  176 	psha
   8063 E6 09         [ 3]  177 	lda	9,x
   8065 87            [ 2]  178 	psha
   8066 E6 08         [ 3]  179 	lda	8,x
   8068 87            [ 2]  180 	psha
   8069 E6 07         [ 3]  181 	lda	7,x
   806B 87            [ 2]  182 	psha
   806C A6 E8         [ 2]  183 	lda	#0xe8
   806E 87            [ 2]  184 	psha
   806F A6 03         [ 2]  185 	lda	#0x03
   8071 87            [ 2]  186 	psha
   8072 4F            [ 1]  187 	clra
   8073 87            [ 2]  188 	psha
   8074 87            [ 2]  189 	psha
   8075 CD 82 6A      [ 5]  190 	jsr	__mullong
   8078 9E E7 0C      [ 4]  191 	sta	12,s
   807B 9E EF 0B      [ 4]  192 	stx	11,s
   807E B6 00         [ 3]  193 	lda	*___SDCC_hc08_ret2
   8080 9E E7 0A      [ 4]  194 	sta	10,s
   8083 B6 01         [ 3]  195 	lda	*___SDCC_hc08_ret3
   8085 9E E7 09      [ 4]  196 	sta	9,s
   8088 A7 08         [ 2]  197 	ais	#8
   808A 20 29         [ 3]  198 	bra	00103$
   808C                     199 00102$:
                            200 ;./src/main_simple.c:48: tdelay *= 20; // scale by 50 for simulation
   808C 95            [ 2]  201 	tsx
   808D E6 0A         [ 3]  202 	lda	10,x
   808F 87            [ 2]  203 	psha
   8090 E6 09         [ 3]  204 	lda	9,x
   8092 87            [ 2]  205 	psha
   8093 E6 08         [ 3]  206 	lda	8,x
   8095 87            [ 2]  207 	psha
   8096 E6 07         [ 3]  208 	lda	7,x
   8098 87            [ 2]  209 	psha
   8099 A6 14         [ 2]  210 	lda	#0x14
   809B 87            [ 2]  211 	psha
   809C 4F            [ 1]  212 	clra
   809D 87            [ 2]  213 	psha
   809E 87            [ 2]  214 	psha
   809F 87            [ 2]  215 	psha
   80A0 CD 82 6A      [ 5]  216 	jsr	__mullong
   80A3 9E E7 0C      [ 4]  217 	sta	12,s
   80A6 9E EF 0B      [ 4]  218 	stx	11,s
   80A9 B6 00         [ 3]  219 	lda	*___SDCC_hc08_ret2
   80AB 9E E7 0A      [ 4]  220 	sta	10,s
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 5.
Hexadecimal [16-Bits]



   80AE B6 01         [ 3]  221 	lda	*___SDCC_hc08_ret3
   80B0 9E E7 09      [ 4]  222 	sta	9,s
   80B3 A7 08         [ 2]  223 	ais	#8
   80B5                     224 00103$:
                            225 ;./src/main_simple.c:52: tdelay *= 1000;
   80B5 95            [ 2]  226 	tsx
   80B6 E6 03         [ 3]  227 	lda	3,x
   80B8 87            [ 2]  228 	psha
   80B9 E6 02         [ 3]  229 	lda	2,x
   80BB 87            [ 2]  230 	psha
   80BC E6 01         [ 3]  231 	lda	1,x
   80BE 87            [ 2]  232 	psha
   80BF F6            [ 2]  233 	lda	,x
   80C0 87            [ 2]  234 	psha
   80C1 A6 E8         [ 2]  235 	lda	#0xe8
   80C3 87            [ 2]  236 	psha
   80C4 A6 03         [ 2]  237 	lda	#0x03
   80C6 87            [ 2]  238 	psha
   80C7 4F            [ 1]  239 	clra
   80C8 87            [ 2]  240 	psha
   80C9 87            [ 2]  241 	psha
   80CA CD 82 6A      [ 5]  242 	jsr	__mullong
   80CD 9E E7 0C      [ 4]  243 	sta	12,s
   80D0 9E EF 0B      [ 4]  244 	stx	11,s
   80D3 B6 00         [ 3]  245 	lda	*___SDCC_hc08_ret2
   80D5 9E E7 0A      [ 4]  246 	sta	10,s
   80D8 B6 01         [ 3]  247 	lda	*___SDCC_hc08_ret3
   80DA 9E E7 09      [ 4]  248 	sta	9,s
   80DD A7 08         [ 2]  249 	ais	#8
                            250 ;./src/main_simple.c:55: *(volatile unsigned char*)GPIO_DATA_ADDR = 0x5a;
   80DF 6E 5A 80      [ 4]  251 	mov	#0x5a,*0x80
                            252 ;./src/main_simple.c:56: *(volatile unsigned char*)GPIO_DATA_ADDR = cfg;
   80E2 9E E6 07      [ 4]  253 	lda	7,s
   80E5 B7 80         [ 3]  254 	sta	*0x80
                            255 ;./src/main_simple.c:57: *(volatile unsigned char*)GPIO_DATA_ADDR = freq;
   80E7 9E E6 06      [ 4]  256 	lda	6,s
   80EA B7 80         [ 3]  257 	sta	*0x80
                            258 ;./src/main_simple.c:58: *(volatile unsigned char*)GPIO_DATA_ADDR = cfg2;
   80EC 9E E6 05      [ 4]  259 	lda	5,s
   80EF B7 80         [ 3]  260 	sta	*0x80
                            261 ;./src/main_simple.c:59: *(volatile unsigned char*)GPIO_DATA_ADDR = simulation ? 0xff : 0;
   80F1 C6 65 00      [ 4]  262 	lda	_simulation
   80F4 27 05         [ 3]  263 	beq	00121$
   80F6 5F            [ 1]  264 	clrx
   80F7 A6 FF         [ 2]  265 	lda	#0xff
   80F9 20 02         [ 3]  266 	bra	00122$
   80FB                     267 00121$:
   80FB 5F            [ 1]  268 	clrx
   80FC 9F            [ 1]  269 	txa
   80FD                     270 00122$:
   80FD B7 80         [ 3]  271 	sta	*0x80
                            272 ;./src/main_simple.c:60: *(volatile unsigned char*)GPIO_DATA_ADDR = 0xa5;
   80FF 6E A5 80      [ 4]  273 	mov	#0xa5,*0x80
                            274 ;./src/main_simple.c:64: if (!simulation) {
   8102 C6 65 00      [ 4]  275 	lda	_simulation
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 6.
Hexadecimal [16-Bits]



   8105 26 5B         [ 3]  276 	bne	00105$
                            277 ;./src/main_simple.c:65: printf("Testprogram %s\r\n",__DATE__);
   8107 A6 50         [ 2]  278 	lda	#___str_1
   8109 87            [ 2]  279 	psha
   810A A6 91         [ 2]  280 	lda	#>___str_1
   810C 87            [ 2]  281 	psha
   810D A6 3F         [ 2]  282 	lda	#___str_0
   810F 87            [ 2]  283 	psha
   8110 A6 91         [ 2]  284 	lda	#>___str_0
   8112 87            [ 2]  285 	psha
   8113 CD 82 4F      [ 5]  286 	jsr	_printf
   8116 A7 04         [ 2]  287 	ais	#4
                            288 ;./src/main_simple.c:66: printf("cfg: 0x%x\r\n",cfg);
   8118 9E E6 07      [ 4]  289 	lda	7,s
   811B 5F            [ 1]  290 	clrx
   811C 87            [ 2]  291 	psha
   811D 89            [ 2]  292 	pshx
   811E A6 5C         [ 2]  293 	lda	#___str_2
   8120 87            [ 2]  294 	psha
   8121 A6 91         [ 2]  295 	lda	#>___str_2
   8123 87            [ 2]  296 	psha
   8124 CD 82 4F      [ 5]  297 	jsr	_printf
   8127 A7 04         [ 2]  298 	ais	#4
                            299 ;./src/main_simple.c:67: printf("freq: %d\r\n",freq);
   8129 9E E6 06      [ 4]  300 	lda	6,s
   812C 5F            [ 1]  301 	clrx
   812D 87            [ 2]  302 	psha
   812E 89            [ 2]  303 	pshx
   812F A6 68         [ 2]  304 	lda	#___str_3
   8131 87            [ 2]  305 	psha
   8132 A6 91         [ 2]  306 	lda	#>___str_3
   8134 87            [ 2]  307 	psha
   8135 CD 82 4F      [ 5]  308 	jsr	_printf
   8138 A7 04         [ 2]  309 	ais	#4
                            310 ;./src/main_simple.c:68: printf("cfg2: 0x%x\r\n",cfg2);
   813A 9E E6 05      [ 4]  311 	lda	5,s
   813D 5F            [ 1]  312 	clrx
   813E 87            [ 2]  313 	psha
   813F 89            [ 2]  314 	pshx
   8140 A6 73         [ 2]  315 	lda	#___str_4
   8142 87            [ 2]  316 	psha
   8143 A6 91         [ 2]  317 	lda	#>___str_4
   8145 87            [ 2]  318 	psha
   8146 CD 82 4F      [ 5]  319 	jsr	_printf
   8149 A7 04         [ 2]  320 	ais	#4
                            321 ;./src/main_simple.c:69: printf("tdel: %lu\r\n",tdelay);
   814B 95            [ 2]  322 	tsx
   814C E6 03         [ 3]  323 	lda	3,x
   814E 87            [ 2]  324 	psha
   814F E6 02         [ 3]  325 	lda	2,x
   8151 87            [ 2]  326 	psha
   8152 E6 01         [ 3]  327 	lda	1,x
   8154 87            [ 2]  328 	psha
   8155 F6            [ 2]  329 	lda	,x
   8156 87            [ 2]  330 	psha
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 7.
Hexadecimal [16-Bits]



   8157 A6 80         [ 2]  331 	lda	#___str_5
   8159 87            [ 2]  332 	psha
   815A A6 91         [ 2]  333 	lda	#>___str_5
   815C 87            [ 2]  334 	psha
   815D CD 82 4F      [ 5]  335 	jsr	_printf
   8160 A7 06         [ 2]  336 	ais	#6
   8162                     337 00105$:
                            338 ;./src/main_simple.c:72: *(volatile unsigned char*)GPIO_DATA_ADDR = 0xc6;
   8162 6E C6 80      [ 4]  339 	mov	#0xc6,*0x80
                            340 ;./src/main_simple.c:75: *(volatile unsigned char*)GPIO_CLR_ADDR = 0x0; // default clear
   8165 6E 00 82      [ 4]  341 	mov	#0x00,*0x82
                            342 ;./src/main_simple.c:76: *(volatile unsigned char*)GPIO_IEN_ADDR = 0xff; // enable all irqs
   8168 6E FF 81      [ 4]  343 	mov	#0xff,*0x81
                            344 ;./src/main_simple.c:79: *(volatile unsigned char*)UART_IEN_ADDR = 1 << UART_IRQEN_RXD_BIT; // rx data available
   816B 6E 01 A1      [ 4]  345 	mov	#0x01,*0xa1
                            346 ;./src/main_simple.c:82: if (!simulation) printf("CLI\r\n");
   816E C6 65 00      [ 4]  347 	lda	_simulation
   8171 26 0B         [ 3]  348 	bne	00107$
   8173 A6 8C         [ 2]  349 	lda	#___str_6
   8175 87            [ 2]  350 	psha
   8176 A6 91         [ 2]  351 	lda	#>___str_6
   8178 87            [ 2]  352 	psha
   8179 CD 82 4F      [ 5]  353 	jsr	_printf
   817C A7 02         [ 2]  354 	ais	#2
   817E                     355 00107$:
                            356 ;./src/main_simple.c:83: CLI
   817E 9A            [ 2]  357 	 cli	
                            358 ;./src/main_simple.c:85: init_timer();
   817F CD 81 C2      [ 5]  359 	jsr	_init_timer
                            360 ;./src/main_simple.c:88: if (!simulation) printf("Enter loop\r\n");
   8182 C6 65 00      [ 4]  361 	lda	_simulation
   8185 26 0B         [ 3]  362 	bne	00115$
   8187 A6 92         [ 2]  363 	lda	#___str_7
   8189 87            [ 2]  364 	psha
   818A A6 91         [ 2]  365 	lda	#>___str_7
   818C 87            [ 2]  366 	psha
   818D CD 82 4F      [ 5]  367 	jsr	_printf
   8190 A7 02         [ 2]  368 	ais	#2
                            369 ;./src/main_simple.c:89: while (1) {
   8192                     370 00115$:
                            371 ;./src/main_simple.c:90: if (0 == (*(volatile unsigned char*)UART_STAT_ADDR & (1 << UART_STATBIT_RXE))) {
   8192 B6 A1         [ 3]  372 	lda	*0xa1
   8194 A5 02         [ 2]  373 	bit	#0x02
   8196 26 09         [ 3]  374 	bne	00111$
                            375 ;./src/main_simple.c:91: unsigned char r = *(volatile unsigned char*)UART_DATA_ADDR; // read data
   8198 B6 A0         [ 3]  376 	lda	*0xa0
                            377 ;./src/main_simple.c:92: *(volatile unsigned char*)UART_IEN_ADDR = 1 << UART_IRQEN_RXD_BIT; // reactivate rx data irq
   819A 6E 01 A1      [ 4]  378 	mov	#0x01,*0xa1
                            379 ;./src/main_simple.c:93: putchar(r);
   819D 5F            [ 1]  380 	clrx
   819E CD 82 23      [ 5]  381 	jsr	_putchar
   81A1                     382 00111$:
                            383 ;./src/main_simple.c:95: *(volatile unsigned char*)GPIO_DATA_ADDR = uric + gpic + tmer_ic; // show counters on led
   81A1 C6 65 04      [ 4]  384 	lda	_uric
   81A4 CB 65 03      [ 4]  385 	add	_gpic
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 8.
Hexadecimal [16-Bits]



   81A7 CB 65 05      [ 4]  386 	add	_tmer_ic
   81AA B7 80         [ 3]  387 	sta	*0x80
                            388 ;./src/main_simple.c:96: if (!simulation) printf("...WFI...");
   81AC C6 65 00      [ 4]  389 	lda	_simulation
   81AF 26 0B         [ 3]  390 	bne	00113$
   81B1 A6 9F         [ 2]  391 	lda	#___str_8
   81B3 87            [ 2]  392 	psha
   81B4 A6 91         [ 2]  393 	lda	#>___str_8
   81B6 87            [ 2]  394 	psha
   81B7 CD 82 4F      [ 5]  395 	jsr	_printf
   81BA A7 02         [ 2]  396 	ais	#2
   81BC                     397 00113$:
                            398 ;./src/main_simple.c:98: WAIT
   81BC 8F            [ 1]  399 	 wait	
   81BD 20 D3         [ 3]  400 	bra	00115$
                            401 ;./src/main_simple.c:101: }
   81BF A7 0B         [ 2]  402 	ais	#11
   81C1 81            [ 4]  403 	rts
                            404 ;------------------------------------------------------------
                            405 ;Allocation info for local variables in function 'init_timer'
                            406 ;------------------------------------------------------------
                            407 ;./src/main_simple.c:103: void init_timer(void){
                            408 ;	-----------------------------------------
                            409 ;	 function init_timer
                            410 ;	-----------------------------------------
                            411 ;	Register assignment is optimal.
                            412 ;	Stack space usage: 0 bytes.
   81C2                     413 _init_timer:
                            414 ;./src/main_simple.c:104: *(volatile unsigned char*)TMR_CNTRL_ADDR = 0; // clear control register
   81C2 6E 00 98      [ 4]  415 	mov	#0x00,*0x98
                            416 ;./src/main_simple.c:105: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 0) = 0x00;
   81C5 6E 00 90      [ 4]  417 	mov	#0x00,*0x90
                            418 ;./src/main_simple.c:106: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 1) = 0x1b;
   81C8 6E 1B 91      [ 4]  419 	mov	#0x1b,*0x91
                            420 ;./src/main_simple.c:107: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 2) = 0xb7;
   81CB 6E B7 92      [ 4]  421 	mov	#0xb7,*0x92
                            422 ;./src/main_simple.c:108: *(volatile unsigned char*)(TMR_SET_LOAD_VAL + 3) = 0x00;        // 0xb71b00 is 12 million in decimal
   81CE 6E 00 93      [ 4]  423 	mov	#0x00,*0x93
                            424 ;./src/main_simple.c:111: *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_USE_LOAD_VAL);    // Set use_reload_value bit
   81D1 B6 98         [ 3]  425 	lda	*0x98
   81D3 AA 02         [ 2]  426 	ora	#0x02
   81D5 B7 98         [ 3]  427 	sta	*0x98
                            428 ;./src/main_simple.c:112: *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_EN_IRQ);          // Set enable_interrupt bit
   81D7 B6 98         [ 3]  429 	lda	*0x98
   81D9 AA 04         [ 2]  430 	ora	#0x04
   81DB B7 98         [ 3]  431 	sta	*0x98
                            432 ;./src/main_simple.c:113: *(volatile unsigned char*)TMR_CNTRL_ADDR |= (1 << TMR_CNTRLBIT_EN);              // Set timer_enable bit
   81DD B6 98         [ 3]  433 	lda	*0x98
   81DF AA 01         [ 2]  434 	ora	#0x01
   81E1 B7 98         [ 3]  435 	sta	*0x98
                            436 ;./src/main_simple.c:114: }
   81E3 81            [ 4]  437 	rts
                            438 ;------------------------------------------------------------
                            439 ;Allocation info for local variables in function 'swIsr'
                            440 ;------------------------------------------------------------
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 9.
Hexadecimal [16-Bits]



                            441 ;./src/main_simple.c:118: void swIsr (void) __interrupt (1)    // irq1 is swi
                            442 ;	-----------------------------------------
                            443 ;	 function swIsr
                            444 ;	-----------------------------------------
                            445 ;	Register assignment is optimal.
                            446 ;	Stack space usage: 0 bytes.
   81E4                     447 _swIsr:
   81E4 8B            [ 2]  448 	pshh
                            449 ;./src/main_simple.c:121: swic++;
   81E5 45 65 01      [ 3]  450 	ldhx	#_swic
   81E8 7C            [ 3]  451 	inc	,x
                            452 ;./src/main_simple.c:122: *(volatile unsigned char*)GPIO_DATA_ADDR = swic;
   81E9 C6 65 01      [ 4]  453 	lda	_swic
   81EC B7 80         [ 3]  454 	sta	*0x80
                            455 ;./src/main_simple.c:124: }
   81EE 8A            [ 2]  456 	pulh
   81EF 80            [ 7]  457 	rti
                            458 ;------------------------------------------------------------
                            459 ;Allocation info for local variables in function 'hwIsr'
                            460 ;------------------------------------------------------------
                            461 ;./src/main_simple.c:126: void hwIsr (void) __interrupt (2)    // irq2 is pin
                            462 ;	-----------------------------------------
                            463 ;	 function hwIsr
                            464 ;	-----------------------------------------
                            465 ;	Register assignment is optimal.
                            466 ;	Stack space usage: 0 bytes.
   81F0                     467 _hwIsr:
   81F0 8B            [ 2]  468 	pshh
                            469 ;./src/main_simple.c:129: hwic++;
   81F1 45 65 02      [ 3]  470 	ldhx	#_hwic
   81F4 7C            [ 3]  471 	inc	,x
                            472 ;./src/main_simple.c:130: *(volatile unsigned char*)GPIO_DATA_ADDR = hwic;
   81F5 C6 65 02      [ 4]  473 	lda	_hwic
   81F8 B7 80         [ 3]  474 	sta	*0x80
                            475 ;./src/main_simple.c:133: if (*(volatile unsigned char*)GPIO_STAT_ADDR & (1 << GPIO_STATBIT_IRQ)) {
   81FA B6 81         [ 3]  476 	lda	*0x81
   81FC A5 01         [ 2]  477 	bit	#0x01
   81FE 27 07         [ 3]  478 	beq	00102$
                            479 ;./src/main_simple.c:134: *(volatile unsigned char*)GPIO_CLR_ADDR = 0x0; // default clear
   8200 6E 00 82      [ 4]  480 	mov	#0x00,*0x82
                            481 ;./src/main_simple.c:135: gpic++;
   8203 45 65 03      [ 3]  482 	ldhx	#_gpic
   8206 7C            [ 3]  483 	inc	,x
   8207                     484 00102$:
                            485 ;./src/main_simple.c:138: if ((*(volatile unsigned char *)UART_STAT_ADDR & (1 << UART_STATBIT_IRQ))) {
   8207 B6 A1         [ 3]  486 	lda	*0xa1
   8209 A5 01         [ 2]  487 	bit	#0x01
   820B 27 07         [ 3]  488 	beq	00104$
                            489 ;./src/main_simple.c:139: *((volatile unsigned char *)(UART_IEN_ADDR)) = 0; // turn irq off. no action yet
   820D 6E 00 A1      [ 4]  490 	mov	#0x00,*0xa1
                            491 ;./src/main_simple.c:140: uric++;
   8210 45 65 04      [ 3]  492 	ldhx	#_uric
   8213 7C            [ 3]  493 	inc	,x
   8214                     494 00104$:
                            495 ;./src/main_simple.c:144: if ((*(volatile unsigned char *)TMR_STAT_ADDR & (1 << TMR_STATBIT_IRQ))) {
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 10.
Hexadecimal [16-Bits]



   8214 B6 99         [ 3]  496 	lda	*0x99
   8216 A5 01         [ 2]  497 	bit	#0x01
   8218 27 07         [ 3]  498 	beq	00107$
                            499 ;./src/main_simple.c:145: *((volatile unsigned char *)(TMR_CLR_ADDR)) = 0x0; // default clear
   821A 6E 00 9A      [ 4]  500 	mov	#0x00,*0x9a
                            501 ;./src/main_simple.c:146: tmer_ic++;
   821D 45 65 05      [ 3]  502 	ldhx	#_tmer_ic
   8220 7C            [ 3]  503 	inc	,x
   8221                     504 00107$:
                            505 ;./src/main_simple.c:148: }
   8221 8A            [ 2]  506 	pulh
   8222 80            [ 7]  507 	rti
                            508 ;------------------------------------------------------------
                            509 ;Allocation info for local variables in function 'putchar'
                            510 ;------------------------------------------------------------
                            511 ;c_                        Allocated to registers a x 
                            512 ;c                         Allocated to registers a 
                            513 ;------------------------------------------------------------
                            514 ;./src/main_simple.c:154: int putchar(int c_) {
                            515 ;	-----------------------------------------
                            516 ;	 function putchar
                            517 ;	-----------------------------------------
                            518 ;	Register assignment is optimal.
                            519 ;	Stack space usage: 0 bytes.
   8223                     520 _putchar:
                            521 ;./src/main_simple.c:156: unsigned char c = (unsigned char)c_;
                            522 ;./src/main_simple.c:157: while (*(volatile unsigned char*)UART_STAT_ADDR & (1 << UART_STATBIT_TXF));
   8223                     523 00101$:
   8223 BE A1         [ 3]  524 	ldx	*0xa1
   8225 87            [ 2]  525 	psha
   8226 9F            [ 1]  526 	txa
   8227 A5 10         [ 2]  527 	bit	#0x10
   8229 86            [ 2]  528 	pula
   822A 26 F7         [ 3]  529 	bne	00101$
                            530 ;./src/main_simple.c:159: *(volatile unsigned char*)UART_DATA_ADDR = c;
   822C B7 A0         [ 3]  531 	sta	*0xa0
                            532 ;./src/main_simple.c:161: return (int)c; // return EOF on error
   822E 5F            [ 1]  533 	clrx
                            534 ;./src/main_simple.c:162: }
   822F 81            [ 4]  535 	rts
                            536 	.area CSEG    (CODE)
                            537 	.area CONST   (CODE)
   913F                     538 ___str_0:
   913F 54 65 73 74 70 72   539 	.ascii "Testprogram %s"
        6F 67 72 61 6D 20
        25 73
   914D 0D                  540 	.db 0x0d
   914E 0A                  541 	.db 0x0a
   914F 00                  542 	.db 0x00
   9150                     543 ___str_1:
   9150 4A 75 6E 20 31 37   544 	.ascii "Jun 17 2022"
        20 32 30 32 32
   915B 00                  545 	.db 0x00
   915C                     546 ___str_2:
   915C 63 66 67 3A 20 30   547 	.ascii "cfg: 0x%x"
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 11.
Hexadecimal [16-Bits]



        78 25 78
   9165 0D                  548 	.db 0x0d
   9166 0A                  549 	.db 0x0a
   9167 00                  550 	.db 0x00
   9168                     551 ___str_3:
   9168 66 72 65 71 3A 20   552 	.ascii "freq: %d"
        25 64
   9170 0D                  553 	.db 0x0d
   9171 0A                  554 	.db 0x0a
   9172 00                  555 	.db 0x00
   9173                     556 ___str_4:
   9173 63 66 67 32 3A 20   557 	.ascii "cfg2: 0x%x"
        30 78 25 78
   917D 0D                  558 	.db 0x0d
   917E 0A                  559 	.db 0x0a
   917F 00                  560 	.db 0x00
   9180                     561 ___str_5:
   9180 74 64 65 6C 3A 20   562 	.ascii "tdel: %lu"
        25 6C 75
   9189 0D                  563 	.db 0x0d
   918A 0A                  564 	.db 0x0a
   918B 00                  565 	.db 0x00
   918C                     566 ___str_6:
   918C 43 4C 49            567 	.ascii "CLI"
   918F 0D                  568 	.db 0x0d
   9190 0A                  569 	.db 0x0a
   9191 00                  570 	.db 0x00
   9192                     571 ___str_7:
   9192 45 6E 74 65 72 20   572 	.ascii "Enter loop"
        6C 6F 6F 70
   919C 0D                  573 	.db 0x0d
   919D 0A                  574 	.db 0x0a
   919E 00                  575 	.db 0x00
   919F                     576 ___str_8:
   919F 2E 2E 2E 57 46 49   577 	.ascii "...WFI..."
        2E 2E 2E
   91A8 00                  578 	.db 0x00
                            579 	.area XINIT   (CODE)
   913A                     580 __xinit__swic:
   913A 00                  581 	.db #0x00	; 0
   913B                     582 __xinit__hwic:
   913B 00                  583 	.db #0x00	; 0
   913C                     584 __xinit__gpic:
   913C 00                  585 	.db #0x00	; 0
   913D                     586 __xinit__uric:
   913D 00                  587 	.db #0x00	; 0
   913E                     588 __xinit__tmer_ic:
   913E 00                  589 	.db #0x00	; 0
                            590 	.area CABS    (ABS,CODE)
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 12.
Hexadecimal [16-Bits]

Symbol Table

    .__.$$$.=  2710 GL  |     .__.ABS.=  0000 G   |     .__.CPU.=  0000 GL
    .__.H$L.=  0001 GL  |     ___SDCC_   **** GX  |     ___SDCC_   **** GX
  7 ___str_0   0000 GR  |   7 ___str_1   0011 GR  |   7 ___str_2   001D GR
  7 ___str_3   0029 GR  |   7 ___str_4   0034 GR  |   7 ___str_5   0041 GR
  7 ___str_6   004D GR  |   7 ___str_7   0053 GR  |   7 ___str_8   0060 GR
    __mullon   **** GX  |     __sdcc_e   **** GX  |   2 __sdcc_g   0000 GR
  2 __sdcc_i   000C GR  |   5 __sdcc_p   0000 GR  |   6 __xinit_   0002 GR
  6 __xinit_   0001 GR  |   6 __xinit_   0000 GR  |   6 __xinit_   0004 GR
  6 __xinit_   0003 GR  |   A _ar        0000 GR  |   A _dr        0400 GR
  B _gpic      0002 GR  |   5 _hwIsr     01CF GR  |   B _hwic      0001 GR
  5 _init_ti   01A1 GR  |   5 _main      0005 GR  |     _printf    **** GX
  5 _putchar   0202 GR  |   A _simulat   0500 GR  |   5 _swIsr     01C3 GR
  B _swic      0000 GR  |   B _tmer_ic   0004 GR  |   B _uric      0003 GR
    l_XINIT    **** GX  |     s_XINIT    **** GX  |     s_XISEG    **** GX

ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Motorola 68HC(S)08), page 13.
Hexadecimal [16-Bits]

Area Table

   0 _CODE      size    0   flags    0
   1 HOME       size    0   flags   20
   2 GSINIT0    size   1E   flags   20
   3 GSINIT     size    0   flags   20
   4 GSFINAL    size    3   flags   20
   5 CSEG       size  20F   flags   20
   6 XINIT      size    5   flags   20
   7 CONST      size   6A   flags   20
   8 DSEG       size    0   flags   10
   9 OSEG       size    0   flags   14
   A XSEG       size  501   flags    0
   B XISEG      size    5   flags    0
   C CODEIVT    size    0   flags    8
   D CODEIVT0   size    6   flags    8
   E IABS       size    0   flags    8
   F XABS       size    0   flags    8
  10 CABS       size    0   flags   28

