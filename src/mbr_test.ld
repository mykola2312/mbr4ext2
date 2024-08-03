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
    . = 0;
    .text : {
        BOOTLOADER_START = .;
        *(.text)
        *(.data)
        BOOTLOADER_END = .;
        BOOTLOADER_SIZE = BOOTLOADER_END - BOOTLOADER_START;
    } > BOOTLOADER

    .unique_id : {
        SHORT(0x1234)
    } > UNIQUE_ID

    .reserved : {
        SHORT(0x0000)
    } > RESERVED

    .mbr_magic : {
        SHORT(0xAA55)
    } > MBR_MAGIC
}

OUTPUT_FORMAT(binary)