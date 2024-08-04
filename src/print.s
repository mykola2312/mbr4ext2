.section .text
.code16

.globl print

# (%bp)     - old bp
# 2(%bp)   - ret addr
# 4(%bp)   - arg 1

# arg 1 - string addr
print:
    push %bp
    mov %sp, %bp

    push %bx
    push %si

    mov 4(%bp), %si
    cld
.putc:
    lodsb
    or %al, %al
    jz .end

    mov $0x0E, %ah
    xor %bh, %bh
    int $0x10
    jmp .putc
.end:

    pop %si
    pop %bx

    pop %bp
    ret
