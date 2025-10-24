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


// ===========================================
// print_hex_byte: imprime un byte como “AB ”
// Entrada:
//   w0 → byte a imprimir
// ===========================================
.type print_hex_byte, %function
print_hex_byte:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // separar nibbles
    and w1, w0, #0xF0
    lsr w1, w1, #4
    and w2, w0, #0x0F

    // convertir nibble alto
    cmp w1, #10
    b.lt phb_digit
    add w1, w1, #'A' - 10
    b phb_done
phb_digit:
    add w1, w1, #'0'
phb_done:

    // convertir nibble bajo
    cmp w2, #10
    b.lt plb_digit
    add w2, w2, #'A' - 10
    b plb_done
plb_digit:
    add w2, w2, #'0'
plb_done:

    // imprimir los dos caracteres + espacio
    sub sp, sp, #16
    strb w1, [sp]
    strb w2, [sp, #1]
    mov w3, #' '
    strb w3, [sp, #2]

    mov x0, #1        // stdout
    mov x1, sp
    mov x2, #3
    mov x8, #64
    svc #0

    add sp, sp, #16
    ldp x29, x30, [sp], #16
    ret
.size print_hex_byte, (. - print_hex_byte)
