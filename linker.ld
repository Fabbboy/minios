ENTRY(_start)

SECTIONS
{
    . = 0x200000;

    .text : {
        KEEP(*(.text.boot))
        *(.text)
    }

    . = ALIGN(4096);

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }
    . = ALIGN(4096);

    .data : {
        *(.data)
         *(.data.*)
    }
    . = ALIGN(4096);

    .bss : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        __bss_end = .;
    }
    __bss_size = __bss_end - __bss_start;
    . = ALIGN(4096);

    .stack : {
        . += 8K;
    }
    __stack_bottom = .;
    . = ALIGN(4096);
}
