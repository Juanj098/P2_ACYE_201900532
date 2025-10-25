//AddroundKey

.type addRoundKey, %function
.global addRoundKey
addRoundKey:
    // Prólogo de la función
    stp x29, x30, [sp, #-32]!    // Guardar frame pointer y link register
    mov x29, sp                   // Establecer nuevo frame pointer
    
    // Guardar registros que vamos a usar
    str x21, [sp, #16]           // Guardar x19
    str x22, [sp, #24]           // Guardar x20
    
    // Cargar direcciones base
    ldr x21, =matState           // x19 = puntero a matriz de estado
    ldr x22, =matKey                // x20 = puntero a clave
    
    mov x0, #0                   // x0 = contador de bytes (0-15)
    
    addroundkey_loop:
        // Verificar si hemos procesado los 16 bytes
        cmp x0, #16
        b.ge addroundkey_done
        
        // Cargar byte actual del estado y de la clave
        ldrb w1, [x21, x0]          // w1 = matState[x0]
        ldrb w2, [x22, x0]          // w2 = key[x0]
        
        // Realizar operación XOR
        eor w3, w1, w2              // w3 = matState[x0] XOR key[x0]
        
        // Almacenar el resultado de vuelta en la matriz de estado
        strb w3, [x21, x0]          // matState[x0] = matState[x0] XOR key[x0]
        
        // Incrementar contador y continuar
        add x0, x0, #1
        b addroundkey_loop
        
    addroundkey_done:
        // Restaurar registros
        ldr x21, [sp, #16]
        ldr x22, [sp, #24]
        
        // Epílogo de la función
        ldp x29, x30, [sp], #32
        ret
        .size addRoundKey, (. - addRoundKey)
