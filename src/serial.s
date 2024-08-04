.section .text
.code16

.globl serial_init
.globl serial_putc
.globl prints

.equ    CONFIG_DIVISOR,     1  # we want maximum baud rate
.equ    CONFIG_DATA_BITS,   8
.equ    CONFIG_STOP_BITS,   1
.equ    CONFIG_PORT,        0x3F8

.equ    SERIAL_R_BUFFER,    CONFIG_PORT + 0
.equ    SERIAL_W_BUFFER,    CONFIG_PORT + 0
.equ    SERIAL_RW_IER,      CONFIG_PORT + 1
.equ    SERIAL_DLAB_L,      CONFIG_PORT + 0
.equ    SERIAL_DLAB_H,      CONFIG_PORT + 0
.equ    SERIAL_R_II,        CONFIG_PORT + 2
.equ    SERIAL_W_FIFO,      CONFIG_PORT + 2
.equ    SERIAL_RW_LCR,      CONFIG_PORT + 3
.equ    SERIAL_RW_MCR,      CONFIG_PORT + 4
.equ    SERIAL_R_LSR,       CONFIG_PORT + 5
.equ    SERIAL_MSR,         CONFIG_PORT + 6
.equ    SERIAL_RW_SCRATCH,  CONFIG_PORT + 7

serial_init:
    # enable DLAB to setup baud divisor
    mov $(1 << 7), %al
    mov $SERIAL_RW_LCR, %dx
    out %al, %dx

    # divisor low byte
    mov $(CONFIG_DIVISOR & 0xFF), %al
    mov $SERIAL_DLAB_L, %dx
    out %al, %dx

    # divisor high byte
    mov $(CONFIG_DIVISOR >> 8), %al
    mov $SERIAL_DLAB_H, %dx
    out %al, %dx

    # config port, but also keep high bit zero to clear DLAB
    mov $((CONFIG_STOP_BITS << 2) | (CONFIG_DATA_BITS & 0b11)), %al
    mov $SERIAL_RW_LCR, %dx
    out %al, %dx

    ret

# al - data byte
# dx overwritten
serial_putc:
    # write byte
    mov $SERIAL_W_BUFFER, %dx
    out %al, %dx

    # poll state
    mov $SERIAL_R_LSR, %dx
.poll:
    in %dx, %al
    and $(1 << 6), %al
    jz .poll

    ret

# ds:si - asciz
prints:
    push %dx
    cld
.putc:
    lodsb
    or %al, %al
    jz .end

    call serial_putc
    jmp .putc
.end:
    pop %dx
    ret
