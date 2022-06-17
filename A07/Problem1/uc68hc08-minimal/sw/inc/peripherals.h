// hc08 peripherals

#ifndef PERIPHERALS_H
#define PERIPHERALS_H

///
/// \addtogroup peripherals Peripheral Memory Map and Bit Positions
/// @{

/// \addtogroup GPIO GPIO register offsets and bits
/// @{
#define GPIO_BASE 0x80 ///< Base address
#define GPIO_DATA_ADDR (GPIO_BASE + 0) ///< RW, data register, from input on read, to output on write
#define GPIO_IEN_ADDR (GPIO_BASE + 1) ///< WO, interrupt enable/disable control register
#define GPIO_CLR_ADDR (GPIO_BASE + 2) ///< WO, clear interrupt register. data is don't care
#define GPIO_STAT_ADDR (GPIO_BASE + 1) ///< RO, status register 
#define GPIO_CFG0_ADDR (GPIO_BASE + 2) ///< RO, configuration register 0: mode and peripherals
#define GPIO_CFG1_ADDR (GPIO_BASE + 3) ///< RO, configuration register 1: processor frequency in mhz
#define GPIO_CFG2_ADDR (GPIO_BASE + 4) ///< RO, configuration register 2: vga mode
#define GPIO_VGALO_ADDR (GPIO_BASE + 5) ///< WO, VGA framebuffer base address in SRAM, low
#define GPIO_VGAHI_ADDR (GPIO_BASE + 6) ///< WO, VGA framebuffer base address in SRAM, high
#define GPIO_STATBIT_IRQ 0 ///< Status register: interrupt status (1: IRQ active)
#define GPIO_CFG0BIT_SIM 0 ///< Configuration bit, config register 0: simulation mode
#define GPIO_CFG0BIT_TIMER 1 ///< Configuration bit, config register 0: timer present 
#define GPIO_CFG0BIT_UART 2 ///< Configuration bit, config register 0: uart present
#define GPIO_CFG0BIT_PWM 3 ///< Configuration bit, config register 0: pwm present
#define GPIO_CFG0BIT_I2C 4 ///< Configuration bit, config register 0: i2c present
#define GPIO_CFG0BIT_SPI 5 ///< Configuration bit, config register 0: spi present
#define GPIO_CFG0BIT_SDRAM 6 ///< Configuration bit, config register 0: sdram present
#define GPIO_CFG2BIT_VGA 0 ///< Configuration bit, config register 2: vga present 
/// @}

/// \addtogroup TIMER
/// @{
#define TMR_BASE 0x90 ///< Base address
#define TMR_SET_LOAD_VAL (TMR_BASE + 0) ///< WO, set register 0, lower 8 bits of set value. followed by 3 subsequent registers. Set occurs when writing 3. register
#define TMR_GET_VAL (TMR_BASE + 4) ///< RO, get register 0, lower 8 bits of current value, followed by 3 subsequent registers. Capture occurs when reading 1. register
#define TMR_CNTRL_ADDR (TMR_BASE + 8) ///< WO control register
#define TMR_STAT_ADDR (TMR_BASE + 9) ///< RO, status register
#define TMR_CLR_ADDR (TMR_BASE + 10) ///< WO clear interrupt register. data is don't care
#define TMR_STATBIT_IRQ 0 ///< interrupt status (1: active)
#define TMR_CNTRLBIT_EN 0 ///< enable counting (1: active)
#define TMR_CNTRLBIT_USE_LOAD_VAL 1 ///< set to 1 if load_val should be the underflow value (1: active)
#define TMR_CNTRLBIT_EN_IRQ 2 ///< enables interrupts during underflow (1: active)
/// @}

/// \addtogroup UART
/// @{
#define UART_BASE 0xa0 ///< Base address
#define UART_DATA_ADDR (UART_BASE + 0) ///< WO, data address, from RX on read, to TX on write
#define UART_IEN_ADDR (UART_BASE + 1) ///< WO, interrupt enable/disable register
#define UART_STAT_ADDR (UART_BASE + 1) ///< RO, status register
#define UART_IRQEN_RXD_BIT 0 ///< Enable RX data interrupt (acitve if RX fifo not empty)
#define UART_IRQEN_RXF_BIT 1 ///< Enable RX full interrupt (acitve if RX fifo full)
#define UART_IRQEN_TXE_BIT 2 ///< Enable TX data interrupt (acitve if TX fifo empty: ALL data sent)
#define UART_STATBIT_IRQ 0 ///< interrupt status (1: active). Interrupt is cleared on data access
#define UART_STATBIT_RXE 1 ///< RX fifo empty
#define UART_STATBIT_RXF 2 ///< RX fifo full
#define UART_STATBIT_TXE 3 ///< TX empty 
#define UART_STATBIT_TXF 4 ///< TX full
/// @}

/// \addtogroup PWM
/// @{
#define PWM_BASE 0xb0 ///< Base address
#define PWM_CHAN_ADDR (PWM_BASE + 0) ///< WO
#define PWM_IEN_ADDR (PWM_BASE + 1) ///< WO, interrupt enable/disable register
#define PWM_RST_ADDR (PWM_BASE + 2) ///< WO
#define PWM_CLR_ADDR (PWM_BASE + 3) ///< WO
#define PWM_STEPLO_ADDR (PWM_BASE + 4) ///< WO
#define PWM_STEPHI_ADDR (PWM_BASE + 5) ///< WO
#define PWM_VALLO_ADDR (PWM_BASE + 6) ///< WO
#define PWM_VALHI_ADDR (PWM_BASE + 7) ///< WO
#define PWM_IRQ_ADDR (PWM_BASE + 0) ///< RO
#define PWM_DONE_ADDR (PWM_BASE + 1) ///< RO
#define PWM_CFG_ADDR (PWM_BASE + 2) ///< RO
/// @}

/// \addtogroup I2C
/// @{
#define I2C_BASE 0xc0 ///< Base address
#define I2C_DATA_ADDR (I2C_BASE + 0) ///< WO
#define I2C_ADDR_ADDR (I2C_BASE + 1) ///< WO
#define I2C_CTL_ADDR (I2C_BASE + 2) ///< WO
#define I2C_STAT_ADDR (I2C_BASE + 1) ///< RO
#define I2C_CTLBIT_IEN 0
#define I2C_CTLBIT_RW 1
#define I2C_CTLBIT_MORE 2
#define I2C_STATBIT_IRQ 0
#define I2C_STATBIT_ACK 1
#define I2C_STATBIT_BUSY 2
/// @}

/// \addtogroup SDRAM
/// @{
#define SDR_BASE 0xe0 ///< Base address
#define SDR_DATA_ADDR (SDR_BASE + 0) ///< RW
#define SDR_DATAINC_ADDR (SDR_BASE + 1) ///< RW
#define SDR_CAPT_ADDR (SDR_BASE + 2) ///< RO
#define SDR_STAT_ADDR (SDR_BASE + 3) ///< RO
#define SDR_A0_ADDR (SDR_BASE + 4) ///< WO
#define SDR_A1_ADDR (SDR_BASE + 5) ///< WO
#define SDR_A2_ADDR (SDR_BASE + 6) ///< WO
#define SDR_CTL_ADDR (SDR_BASE + 7) ///< WO
#define SDR_STATBIT_WAIT 0
#define SDR_STATBIT_VALID 1
#define SDR_STATBIT_INIT 2
#define SDR_CTLBIT_RST 0
#define SDR_CTLBIT_INV 1
/// @}

/// @}


#endif // PERIPHERALS_H
