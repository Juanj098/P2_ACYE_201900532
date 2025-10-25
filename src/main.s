.include "macros.s"
.include "utils.s"
.include "constants.s"
.include "addRoundKey.s"
.include "subBytes.s"

.section .bss
    key:   .skip 16
    clave: .skip 16
    matState: .space 16, 0
    matKey: .space 16, 0
    matEncrypt: .space 16, 0

    .global matState
    .global matKey
    .global matEncrypt


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
    key_err_msg: .asciz "Error: Valor de clave incorrecto\n"
    lenKeyErr = . - key_err_msg
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

    //subBytes
    bl subBytes

    ldr x0, =matState
    ldr x1, =msg_sub
    mov x2, lenmsg_sub
    bl printMatrix

    // --- Salir ---
    mov x0, #0
    mov x8, #93
    svc #0