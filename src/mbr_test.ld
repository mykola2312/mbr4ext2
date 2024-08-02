MEMORY
{
    BOOTLOADER  (RWX)   :   ORIGIN = 0x7C00, LENGTH = 440
    UNIQUE_ID   (R)     :   ORIGIN = 0x7DB8, LENGTH = 4
    RESERVED    (R)     :   ORIGIN = 0x7DBC, LENGTH = 2
    PTABLE      (R)     :   ORIGIN = 0x7DBE, LENGTH = 64
    MBR_MAGIC   (R)     :   ORIGIN = 0x7DFE, LENGTH = 2
}

SECTIONS
{
    . = 0x7C00;
    .text : {
        *(.text)
        *(.data)
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