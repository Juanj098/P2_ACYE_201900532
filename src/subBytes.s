.type subBytes, %function
.global subBytes
subBytes:
    // Prólogo de la función
    stp x29, x30, [sp, #-32]!    // Guardar frame pointer y link register
    mov x29, sp                   // Establecer nuevo frame pointer
    
    // Guardar registros que vamos a usar
    str x19, [sp, #16]           // Guardar x19
    str x20, [sp, #24]           // Guardar x20
    
    // Cargar direcciones base
    ldr x19, = matState           // x19 = puntero a matriz de estado
    ldr x20, = SBox               // x20 = puntero a S-box
    
    mov x0, #0                   // x0 = contador de bytes (0-15)
    
    subbytes_loop:
        // Verificar si hemos procesado los 16 bytes
        cmp x0, #16
        b.ge subbytes_done
        
        // Cargar byte actual de la matriz de estado
        ldrb w1, [x19, x0]          // w1 = matState[x0]
        
        // Extender w1 a 64 bits para usar como índice
        uxtw x1, w1                 // x1 = (uint64_t)w1
        
        // Usar el byte como índice en la S-box
        // La S-box es una tabla de 256 bytes (0x00 a 0xFF)
        ldrb w2, [x20, x1]          // w2 = Sbox[matState[x0]]
        
        // Almacenar el byte transformado de vuelta en la matriz
        strb w2, [x19, x0]          // matState[x0] = Sbox[matState[x0]]
        
        // Incrementar contador y continuar
        add x0, x0, #1
        b subbytes_loop
        
    subbytes_done:
        // Restaurar registros
        ldr x19, [sp, #16]
        ldr x20, [sp, #24]
        
        // Epílogo de la función
        ldp x29, x30, [sp], #32
        ret
        .size subBytes, (. - subBytes)
