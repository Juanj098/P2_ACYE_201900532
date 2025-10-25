.type mixColumns, %function
.global mixColumns
mixColumns:
    stp x29, x30, [sp, #-80]!
    mov x29, sp
    str x19, [sp, #16]
    str x20, [sp, #24]
    str x21, [sp, #32]
    str x22, [sp, #40]
    str x23, [sp, #48]
    str x24, [sp, #56]
    str x25, [sp, #64]
    str x26, [sp, #72]
    ldr x19, =matState
    mov x20, #0
    mixcol_row_loop:
        cmp x20, #4
        b.ge mixcol_done
        ldrb w22, [x19, x20]
        add x0, x20, #4
        ldrb w23, [x19, x0]
        add x0, x20, #8
        ldrb w24, [x19, x0]
        add x0, x20, #12
        ldrb w25, [x19, x0]
        mov w0, w22
        bl galois_mul2
        mov w26, w0
        mov w0, w23
        bl galois_mul3
        eor w26, w26, w0
        eor w26, w26, w24
        eor w26, w26, w25
        sub sp, sp, #16
        str w26, [sp, #0]
        mov w26, w22
        mov w0, w23
        bl galois_mul2
        eor w26, w26, w0
        mov w0, w24
        bl galois_mul3
        eor w26, w26, w0
        eor w26, w26, w25
        str w26, [sp, #4]
        mov w26, w22
        eor w26, w26, w23
        mov w0, w24
        bl galois_mul2
        eor w26, w26, w0
        mov w0, w25
        bl galois_mul3
        eor w26, w26, w0
        str w26, [sp, #8]
        mov w0, w22
        bl galois_mul3
        mov w26, w0
        eor w26, w26, w23
        eor w26, w26, w24
        mov w0, w25
        bl galois_mul2
        eor w26, w26, w0
        str w26, [sp, #12]
        ldr w26, [sp, #0]
        strb w26, [x19, x20]
        add x0, x20, #4
        ldr w26, [sp, #4]
        strb w26, [x19, x0]
        add x0, x20, #8
        ldr w26, [sp, #8]
        strb w26, [x19, x0]
        add x0, x20, #12
        ldr w26, [sp, #12]
        strb w26, [x19, x0]
        add sp, sp, #16
        add x20, x20, #1
        b mixcol_row_loop
    mixcol_done:
        ldr x19, [sp, #16]
        ldr x20, [sp, #24]
        ldr x21, [sp, #32]
        ldr x22, [sp, #40]
        ldr x23, [sp, #48]
        ldr x24, [sp, #56]
        ldr x25, [sp, #64]
        ldr x26, [sp, #72]
        ldp x29, x30, [sp], #80
        ret
        .size mixColumns, (. - mixColumns)
        

.type galois_mul2, %function
galois_mul2:
    and w1, w0, #0x80
    lsl w0, w0, #1
    and w0, w0, #0xFF
    cmp w1, #0x80
    b.ne galois_mul2_done
    mov w2, #0x1B
    eor w0, w0, w2
galois_mul2_done:
    ret
    .size galois_mul2, (. - galois_mul2)

.type galois_mul3, %function
galois_mul3:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]
    mov w19, w0
    bl galois_mul2
    eor w0, w0, w19
    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret
    .size galois_mul3, (. - galois_mul3)