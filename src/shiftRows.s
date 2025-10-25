.type shiftRows, %function
.global shiftRows
shiftRows:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    str x19, [sp, #16]
    str x20, [sp, #24]
    str x21, [sp, #32]
    str x22, [sp, #40]
    ldr x19, =matState
    ldrb w20, [x19, #4]
    ldrb w21, [x19, #5]
    strb w21, [x19, #4]
    ldrb w21, [x19, #6]
    strb w21, [x19, #5]
    ldrb w21, [x19, #7]
    strb w21, [x19, #6]
    strb w20, [x19, #7]
    ldrb w20, [x19, #8]
    ldrb w21, [x19, #9]
    ldrb w22, [x19, #10]
    strb w22, [x19, #8]
    ldrb w22, [x19, #11]
    strb w22, [x19, #9]
    strb w20, [x19, #10]
    strb w21, [x19, #11]
    ldrb w20, [x19, #12]
    ldrb w21, [x19, #15]
    strb w21, [x19, #12]
    ldrb w21, [x19, #14]
    strb w21, [x19, #15]
    ldrb w21, [x19, #13]
    strb w21, [x19, #14]
    strb w20, [x19, #13]
    ldr x19, [sp, #16]
    ldr x20, [sp, #24]
    ldr x21, [sp, #32]
    ldr x22, [sp, #40]
    ldp x29, x30, [sp], #48
    ret
    .size shiftRows, (. - shiftRows)