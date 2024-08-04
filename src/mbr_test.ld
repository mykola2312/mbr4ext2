MEMORY
{
    RAM         (RWX)   :   ORIGIN = 0x0000, LENGTH = 492032
}

SECTIONS
{
    RAM = 0x7E00;
    RAM_SEGMENT = (RAM >> 8);

    .text       0x0000 : {
        BOOTLOADER_START = .;
        *(.text)
        *(.rodata)
        BOOTLOADER_END = .;
        BOOTLOADER_SIZE = BOOTLOADER_END - BOOTLOADER_START;
    } > RAM

    .stack (NOLOAD): {
        . = ALIGN(8);
        STACK_SIZE = 0x100;
        
        STACK_START = .;
        . = . + STACK_SIZE;
        . = ALIGN(8);
        STACK_END = .;
    } > RAM

    .bss (NOLOAD) : {
        . = ALIGN(8);
        *(.bss)
    } > RAM

    .unique_id  0x01B8 : {
        SHORT(0x1234)
    }

    .reserved   0x01BC : {
        SHORT(0x0000)
    }

    .mbr_magic  0x01FE : {
        SHORT(0xAA55)
    }
}

OUTPUT_FORMAT(binary)