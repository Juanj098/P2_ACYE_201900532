.include "macros.s"
.include "utils.s"
.include "constants.s"
.include "addRoundKey.s"
.include "subBytes.s"
.include "mixColums.s"
.include "shiftRows.s"
.include "keyExpansion.s"

.section .bss
    key:   .skip 16
    clave: .skip 16
    matState: .space 16, 0
    matKey: .space 16, 0
    matEncrypt: .space 16, 0
    tempWord: .space 4, 0
    expandedKeys: .space 176, 0

    .global matState
    .global matKey
    .global matEncrypt
    .global tempWord
    .global expandedKeys

.section .data
    msg_encryp: .asciz "Ingresa cadena a encriptar: "
    lenMsg_encryp = . - msg_encryp
    msg_key:    .asciz "Ingresa llave: "
    lenMsg_Key = . - msg_key
    msg_MtzC: .asciz "matriz Clave \n"
    lenmsg_MtzC = . - msg_MtzC
    msg_MtzK: .asciz "matriz Key \n"
    lenmsg_MtzK = . - msg_MtzK
    msg_add: .asciz "addRoundKey \n"
    lenmsg_add = . - msg_add
    msg_sub: .asciz "subBytes \n"
    lenmsg_sub = . - msg_sub
    msg_mix: .asciz "mixColumns \n"
    lenmsg_mix = . - msg_mix
    msg_shif: .asciz "shiftRows \n"
    lenmsg_shif = . - msg_shif
    msg_kex: .asciz "keyExpansion \n"
    lenmsg_kex = . - msg_kex
    key_err_msg: .asciz "Error: Valor de clave incorrecto\n"
    lenKeyErr = . - key_err_msg
    ronda:      .asciz "Ronda "
    lenronda = . - ronda
    rondaD:      .asciz "Ronda Final"
    lenrondaD = . - rondaD
    newline:    .asciz "\n"

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
    ldr x1, =newline
    mov x2, #1
    mov x8, #63
    svc #0

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

    ldr x0, =key
    bl convertHexKey

    print 1, newline, 1

    ldr x0, =matState
    ldr x1, =msg_MtzC
    mov x2, lenmsg_MtzC
    bl printMatrix


    ldr x0, =matKey
    ldr x1, =msg_MtzK
    mov x2, lenmsg_MtzK
    bl printMatrix

    //addRoundkey
    ldr x19, =matState
    ldr x20, =matKey
    bl addRoundKey

    ldr x0, =matState
    ldr x1, =msg_add
    mov x2, lenmsg_add
    bl printMatrix

    // for (i =0; i<4; i++){sum +=i;}

    mov x19, #0 // inicializa (i=0)

    for_loop:
    cmp x19, #8
    bge end_for

    mov x0, #1
    ldr x1, =ronda
    mov x2, lenronda
    mov x8, #64
    svc #0

    mov x21, x19

    cmp x21, #10
    blt single_digit

    mov w1, #'1'
    sub sp, sp, #16
    strb w1, [sp]
    mov x0, #1          // stdout
    mov x1, sp          // puntero al carácter
    mov x2, #1          // longitud
    mov x8, #64         // syscall write
    svc #0
    add sp, sp, #16

    sub x21, x21, #10

    single_digit:
        mov w1, w21         // copia del contador
        add w1, w1, #'0'    
        sub sp, sp, #16
        strb w1, [sp]
        mov x0, #1          // stdout
        mov x1, sp          // puntero al carácter
        mov x2, #1          // longitud
        mov x8, #64         // syscall write
        svc #0
        add sp, sp, #16

        print 1, newline, 1
// <-----------inicio de ciclo----------->

    //subBytes
    bl subBytes

     //shiftRows
    bl shiftRows

    //mixColumns
    bl mixColumns

    //keyExpansion
    ldr x0, =key
    mov x1, x19
    bl keyExpansion

    //addRoundkey
    ldr x21, =matState
    ldr x22, =matKey
    bl addRoundKey

    ldr x0, =matState
    ldr x1, =msg_add
    mov x2, lenmsg_add
    bl printMatrix

// <------------------------------------>  
    add x19, x19, #1
    b for_loop
    end_for:

    print 1, rondaD, lenrondaD
    print 1, newline, 1
    //SubBytes
    bl subBytes

    ldr x0, =matState
    ldr x1, =msg_sub
    mov x2, lenmsg_sub
    bl printMatrix

    //shiftRows
    bl shiftRows

    ldr x0, =matState
    ldr x1, =msg_shif
    mov x2, lenmsg_shif
    bl printMatrix

    //addRoundkey
    ldr x19, =matState
    ldr x20, =matKey
    bl addRoundKey

    ldr x0, =matState
    ldr x1, =msg_add
    mov x2, lenmsg_add
    bl printMatrix

    // --- Salir ---
    mov x0, #0
    mov x8, #93
    svc #0