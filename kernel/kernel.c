#include <stddef.h>
#include <stdint.h>

#define MMIO_BASE 0xFE000000
#define GPIO_BASE (MMIO_BASE + 0x200000)
#define UART0_BASE (MMIO_BASE + 0x201000)
#define MBOX_BASE (MMIO_BASE + 0xB880)

#define GPPUD (GPIO_BASE + 0x94)
#define GPPUDCLK0 (GPIO_BASE + 0x98)

#define UART0_DR (UART0_BASE + 0x00)
#define UART0_FR (UART0_BASE + 0x18)
#define UART0_IBRD (UART0_BASE + 0x24)
#define UART0_FBRD (UART0_BASE + 0x28)
#define UART0_LCRH (UART0_BASE + 0x2C)
#define UART0_CR (UART0_BASE + 0x30)
#define UART0_IMSC (UART0_BASE + 0x38)
#define UART0_ICR (UART0_BASE + 0x44)

#define MBOX_READ (MBOX_BASE + 0x00)
#define MBOX_STATUS (MBOX_BASE + 0x18)
#define MBOX_WRITE (MBOX_BASE + 0x20)

static inline void mmio_write(uint32_t reg, uint32_t data) {
    *(volatile uint32_t *)(reg) = data;
}

static inline uint32_t mmio_read(uint32_t reg) {
    return *(volatile uint32_t *)(reg);
}

static inline void delay(int32_t count) {
    while (count-- > 0) {
        asm volatile("nop");
    }
}

volatile unsigned int __attribute__((aligned(16))) mbox[9] = {
    9 * 4, 0, 0x38002, 12, 8, 2, 3000000, 0, 0};

void uart_init() {
    mmio_write(UART0_CR, 0x00000000);
    mmio_write(GPPUD, 0x00000000);
    delay(150);
    mmio_write(GPPUDCLK0, (1 << 14) | (1 << 15));
    delay(150);
    mmio_write(GPPUDCLK0, 0x00000000);
    mmio_write(UART0_ICR, 0x7FF);

    mmio_write(UART0_IBRD, 1);
    mmio_write(UART0_FBRD, 40);
    mmio_write(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));
    mmio_write(UART0_IMSC, 0);
    mmio_write(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}

void uart_putc(unsigned char c) {
    while (mmio_read(UART0_FR) & (1 << 5)) {}
    mmio_write(UART0_DR, c);
}

unsigned char uart_getc() {
    while (mmio_read(UART0_FR) & (1 << 4)) {}
    return mmio_read(UART0_DR);
}

void uart_puts(const char *str) {
    while (*str) {
        uart_putc((unsigned char)*str++);
    }
}

void kernel_main(uint64_t dtb_ptr32, uint64_t x1, uint64_t x2, uint64_t x3) {
    uart_init();
    uart_puts("Hello, kernel World!\r\n");
    while (1)
        uart_putc(uart_getc());
}
