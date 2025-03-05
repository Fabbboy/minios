.section ".text.boot"
.globl _start
.org 0x80000

_start:
    mrs     x0, mpidr_el1
    and     x0, x0, #0xFF 

    cbz     x0, 1f
    wfe
    b .

1:  ldr     x5, =__stack_bottom
    mov     sp, x5

    ldr     x5, =__bss_start
    ldr     w6, =__bss_size
2:  cbz     w6, 3f
    str     xzr, [x5], #8
    sub     w6, w6, #1
    cbnz    w6, 2b

3:  bl      kernel_main

halt:
    wfe
    b halt
