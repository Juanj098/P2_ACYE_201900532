// ===========================================
// utils.s — funciones auxiliares ARM64
// ===========================================


// ===========================================
// printMatrix: imprime una matriz 4x4 de bytes
// Parámetros:
//   x0 → puntero a la matriz (16 bytes)
//   x1 → puntero al mensaje
//   x2 → longitud del mensaje
// =========================================
.type printMatrix, %function
.global printMatrix
printMatrix:
    stp x29, x30, [sp, #-48]!
    mov x29, sp
    
    // Guardar parametros
    str x0, [sp, #16]         // matriz
    str x1, [sp, #24]         // mensaje
    str x2, [sp, #32]         // longitud mensaje
    
    // Imprimir mensaje
    mov x0, #1
    ldr x1, [sp, #24]
    ldr x2, [sp, #32]
    mov x8, #64
    svc #0
    
    // Imprimir matriz 4x4
    mov x23, #0               // contador de filas
    
print_row_loop:
    cmp x23, #4
    b.ge print_matrix_done
    
    mov x24, #0               // contador de columnas
    
print_col_loop:
    cmp x24, #4
    b.ge print_row_newline
    
    // Calcular índice column-major: fila*4 + columna
    mov x25, #4
    mul x25, x23, x25
    add x25, x25, x24
    
    // Cargar y mostrar byte
    ldr x20, [sp, #16]        // Recuperar puntero a matriz
    ldrb w0, [x20, x25]
    bl print_hex_byte
    
    add x24, x24, #1
    b print_col_loop
    
print_row_newline:
    print 1, newline, 1
    add x23, x23, #1
    b print_row_loop
    
print_matrix_done:
    print 1, newline, 1
    ldp x29, x30, [sp], #48
    ret
    .size printMatrix, (. - printMatrix)

 // Funcion para imprimir byte en hexadecimal
print_hex_byte:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    
    // Separar nibbles
    and w1, w0, #0xF0
    lsr w1, w1, #4
    and w2, w0, #0x0F
    
    // Convertir nibble alto
    cmp w1, #10
    b.lt high_digit
    add w1, w1, #'A' - 10
    b high_done
high_digit:
    add w1, w1, #'0'
high_done:
    
    // Convertir nibble bajo
    cmp w2, #10
    b.lt low_digit
    add w2, w2, #'A' - 10
    b low_done
low_digit:
    add w2, w2, #'0'
low_done:
    
    // Imprimir
    sub sp, sp, #16
    strb w1, [sp]
    strb w2, [sp, #1]
    mov w3, #' '
    strb w3, [sp, #2]
    
    mov x0, #1
    mov x1, sp
    mov x2, #3
    mov x8, #64
    svc #0
    
    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret

/* ===========================================
   readTextInput: convierte una palabra normal a bytes ASCII
   y la guarda en la matriz matState (4x4 column-major)
   Entrada:
    x0 → puntero a la palabra
=========================================== */
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


/* ===========================================
   convertHexKey: convierte una palabra normal a bytes ASCII
   y la guarda en la matriz matKey (4x4 column-major)
   Entrada:
     x0 → puntero a la palabra
=========================================== */
.type convertHexKey, %function
.global convertHexKey
convertHexKey:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, x0            // puntero al texto (palabra)
    ldr x2, =matKey       // puntero a la matriz destino
    mov x3, #0            // índice de lectura

    convert_key_loop:
        cmp x3, #16           // máximo 16 bytes (clave AES-128)
        b.ge pad_key_bytes

        ldrb w4, [x1, x3]     // leer byte actual del texto
        cmp w4, #10           // salto de línea -> termina
        b.eq pad_key_bytes
        cmp w4, #0            // fin de cadena -> termina
        b.eq pad_key_bytes

        // convertir a formato column-major
        mov x7, #4
        udiv x8, x3, x7
        msub x9, x8, x7, x3
        mul x10, x9, x7
        add x10, x10, x8

        strb w4, [x2, x10]    // guardar byte en matriz
        add x3, x3, #1
        b convert_key_loop

    pad_key_bytes:
        cmp x3, #16
        b.ge convert_key_done

        mov x7, #4
        udiv x8, x3, x7
        msub x9, x8, x7, x3
        mul x10, x9, x7
        add x10, x10, x8

        mov w4, #0            // padding con ceros
        strb w4, [x2, x10]
        add x3, x3, #1
        b pad_key_bytes

    convert_key_done:
        ldp x29, x30, [sp], #16
        ret
        .size convertHexKey, (. - convertHexKey)
