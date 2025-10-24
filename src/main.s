.include "macros.s"
.include "utils.s"
//.include "keyExpansion.s"

.section .bss
    key:   .skip 16
    clave: .skip 16
    matState: .space 16, 0

    .global matState

.section .data
    msg_encryp: .asciz "Ingresa cadena a encriptar: "
    lenMsg_encryp = . - msg_encryp
    msg_key:    .asciz "Ingresa llave: "
    lenMsg_Key = . - msg_key
    newline:    .asciz "\n"
    msg_Mtz: .asciz "matriz debug \n"
    lenmsg_Mtz = . - msg_Mtz

.section .text

    .global _start

_start:
    // --- Pedir cadena a encriptar ---
    mov x0, #1
    ldr x1, =msg_encryp
    mov x2, lenMsg_encryp
    mov x8, #64
    svc #0

    mov x0, #0
    ldr x1, =clave
    mov x2, #16
    mov x8, #63
    svc #0

    mov x0, #0
    sub sp, sp, #8     
    mov x1, sp        
    mov x2, #1
    mov x8, #63
    svc #0
    add sp, sp, #8  

    // --- Pedir llave ---
    mov x0, #1
    ldr x1, =msg_key
    mov x2, lenMsg_Key
    mov x8, #64
    svc #0

    mov x0, #0
    ldr x1, =key
    mov x2, #16
    mov x8, #63
    svc #0

    ldr x0, =clave
    bl readTextInput

    print 1, newline, 1
    print 1, key, 16
    print 1, newline, 1


    ldr x0, =matState
    ldr x1, =msg_Mtz
    mov x2, lenmsg_Mtz
    bl printMatrix

    // --- Salir ---
    mov x0, #0
    mov x8, #93
    svc #0


.type readTextInput, %function
.global readTextInput
readTextInput:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    mov x1, x0
    ldr x2, =matState
    mov x3, #0

    convert_text_loop:
        cmp x3,#16
        b.ge pad_remaining_bytes

        ldrb w4, [x1, x3]
        cmp w4, #10
        b.eq pad_remaining_bytes
        ldrb w4, [x1, x3]
        cmp w4, #0
        b.eq pad_remaining_bytes

        mov x7, #4
        udiv x8, x3, x7
        msub x9, x8, x7, x3
        mul x10, x9, x7
        add x10, x10, x8

        strb w4, [x2, x10]
        add x3, x3, #1
        b convert_text_loop

    pad_remaining_bytes:
        cmp x3, #16
        b.ge convert_text_done

        mov x7, #4
        udiv x8, x3, x7
        msub x9, x8, x7, x3
        mul x10, x9, x7
        add x10, x10, x8

        mov w4, #0
        strb w4, [x2, x10]
        add x3, x3, #1
        b pad_remaining_bytes

    convert_text_done:
        ldp x29, x30, [sp], #16
        ret
        .size readTextInput, (. - readTextInput)

    ldp x29, x30, [sp], #16
    ret

