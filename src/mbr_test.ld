MEMORY
{
    BOOTLOADER  (RWX)   :   ORIGIN = 0x0000, LENGTH = 440
    UNIQUE_ID   (R)     :   ORIGIN = 0x01B8, LENGTH = 4
    RESERVED    (R)     :   ORIGIN = 0x01BC, LENGTH = 2
    PTABLE      (R)     :   ORIGIN = 0x01BE, LENGTH = 64
    MBR_MAGIC   (R)     :   ORIGIN = 0x01FE, LENGTH = 2
}

SECTIONS
{
    .text 0x0000 : {
        BOOTLOADER_START = .;
        *(.text)
        *(.rodata)
        BOOTLOADER_END = .;
        *(.bss)
        BOOTLOADER_SIZE = BOOTLOADER_END - BOOTLOADER_START;

        RAM = 0x7E00;
        RAM_SEGMENT = (RAM >> 8);
    }

    .unique_id 0x01B8 : {
        SHORT(0x1234)
    }

    .reserved 0x01BC : {
        SHORT(0x0000)
    }

    .mbr_magic 0x01FE : {
        SHORT(0xAA55)
    }
}

OUTPUT_FORMAT(binary)