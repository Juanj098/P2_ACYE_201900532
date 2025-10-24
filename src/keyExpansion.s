//key_expansion
.include "utils.s"
.section .bss
    keyAux:     .space 16, 0

.section .text

.type keyExpansion, %function
keyExpansion:   // Parametros x0: key, x1: ronda
    STP x29, x30, [SP, #-16]!

    MOV x15, #0     // Indice de primera palabra de la matriz de clave
    MOV x16, #3     // Indice de ultima palabra de la matriz de clave
    MOV x17, #0     // Contador de bytes cargados
    MOV x20, xzr    // Limpiamos registro 20
    MOV x21, xzr    // Limpiamos registro 21
    load_words:
        MOV x17, #4             // Aplicamos column-major para cargar el primer
        MUL x17, x17, x15       // byte de la primera palabra

        LDRB w2, [x0, x17]      // Cargamos el byte 0 de la palabra 1
        
        ADD x17, x17, #3        // Sumamos 3 unidades para cargar el primer byte de
                                // la primera palabra
        LDRB w3, [x0, x17]      // Cargamos el byte 0 de la palabra

        LSL x16, x15, #3        // Hacemos el calculo de cuantos bits debemos desplazar los bytes a la izquierda
        LSL w2, w2, w16         // Desplazamos el contenido de los bytes que cargamos primer palabra
        LSL w3, w3, w16         // Seguna palabra

        ORR w20, w2, w20        // Hacemos OR con el registro 20 para almacenar el resultado al final de la primera palabra
        ORR w21, w3, w21        // Hacemos OR con el registro 21 para almacenar el resultado al final de la ultima palabra

        ADD x15, x15, #1        // Sumamos uno al contador de bytes
        CMP x15, #4             // Si ya cargamos los 4 bytes de cada palabra, terminamos el ciclo
        BNE load_words

    // RotWord(W(i-1))
    MOV w2, w20
    MOV w3, w21
    REV w2, w2          // Invertimos el orden del registro 2
    REV w3, w3          // Invertimos el orden del registro 3
    
    ROR w3, w3, #24     // Hacemos rotacion para cumplir con la funcion RotWord

    // Funcion ByteSub(RotWord(W(i-1)))
    LDR x10, =SBox
    MOV x5, #0      // Multiplicador de bits a desplazar
    MOV x6, #8      // Constante de bits a desplazar
    MOV x7, 0xFF    // Mascara De Bits
    MOV x15, #0     // Contador de bytes sustituidos

    loop_sub_bytes:
        MUL x9, x5, x6      // Calcular desplzamiento para enviar al fondo el byte
        AND w4, w3, w7      // Obtener solo byte a trabajar 
        LSR w4, w4, w9      // Desplazar al fondo el byte
        ADD x5, x5, #1      // Agregar uno al contador de bytes
        LSL x7, x7, #8      // Desplzar mascara 8 bits a la derecha

        MOV w11, w4         // Copiar byte a registro 11
        LSR w11, w11, #4    // Obtener bits mas significativos
        BIC w12, w4, 0xF0   // Obtener bits menos significativos

        // w11 => fila, w12 => columna
        // Aplicamos row-major
        MOV w13, #16
        MUL w13, w13, w11
        ADD w13, w13, w12

        MOV x14, #0                 // Limpiamos registro 14
        LDRB w14, [x10, x13]        // Cargamos byte de Sbox
        LSL w14, w14, w9            // Desplzamos el byte segun la iteracion
        ORR w15, w14, w15           // Suma logica con el registro 15, este tendra el resultado

        CMP x5, #4                  // Si ya se hizo la sustitucion de los 4 bytes terminamos el ciclo
        BNE loop_sub_bytes

    LDR x10, =RCon                  // Cargamos direccion de RCon
    LDR w11, [x10, x1, LSL #2]      // Cargamos fila del RCon a utilizar segun la ronda que ha recibido la funcion como parametro
    REV w11, w11

    // ByteSub(RotWord(W(i-1))) XOR RCon(i/4)
    EOR w11, w11, w15

    // W(i-N) XOR [ByteSub(RotWord(W(i-1))) XOR RCon(i/4)]
    EOR w2, w2, w11     // Resultado para la primera palabra de la nueva clave

    // Almacenar la primera palabra de la clave
    LDR x1, =keyAux     // Cargamos la direccion de memoria de la matriz auxiliar
    REV w2, w2          // Invertimos el orden del registro 2
    MOV x4, #0          // El registro 4 sra el contador de bytes guardados
    MOV w0, w2          // hacemos una copia de la palabra a guardar

    save_byte:
        AND w3, w2, 0xFF    // Obtenemos unicamente el primer byte a guardar
        LSR w2, w2, #8      // Desplazamos hacia la derecha 8 bits
        STRB w3, [x1], #4   // Almacenamos el byte del registro 3. luego sumamos 4 unidades para que almacene el siguiente byte en la proxima fila
        ADD x4, x4, #1      // Incrementamos el contador de bytes
        CMP x4, #4          // Si ya almacenamos los 4 bytes terminamos el ciclo
        BNE save_byte

    MOV w21, w0             // Hacemos una copia de la primera palabra obtenida de la nueva clave en el registro 21
    LDR x0, =key            // Cargamos direccion de memoria de la clave original
    MOV x5, #1              // Contador de la columna a utilizar de la matriz de clave
    MOV x17, #0
    calculate_words:
        MOV x20, xzr        // Limpiamos el registro 20
        MOV x6, #0          // Contador de bytes a cargados
        load_word:
            MOV x17, #4             // Aplicamos column major para cargar el byte de la columna indicada en el registro 5
            MUL x17, x17, x6
            ADD x17, x17, x5
            LDRB w2, [x0, x17]      // Cargamos el byte en cuestion, indicado por el indice x17

            LSL x16, x6, #3         // Hacemos el calculo de cuantos bits a la izquierda desplazaremos el byte
            LSL w2, w2, w16         // Desplazamos el byte segun los bits calculados
            ORR w20, w2, w20        // Hacemos OR con el registro 20 para cargar la palabra en cuestion
            ADD x6, x6, #1          // Incrementamos el contador de bytes cargados
            CMP x6, #4              // Si hemos cargado los 4 bytes de la palabra, terminamos el ciclo
            BNE load_word

        MOV w2, w20                 // Copiamos la palabra recien cargada al registro 2
        EOR w2, w2, w21             // W(i-N) XOR W(i-1), registro 2 tiene la palabra (i-N), registro 21 tiene la palabra (i-1) 

        // Almacenar la palabra de la clave
        LDR x1, =keyAux             // Cargarmos direccion de la matriz auxiliar
        MOV x4, #0                  // Contador de bytes cargados
        MOV w21, w2                 // Copiamos la nueva palabra generada al registro 21, para la proxima operacion
        ADD x1, x1, x5              // Incrementamos el contador de columna a calcular

        save_byte_2:
            AND w3, w2, 0xFF            // Obtenemos unicamente el primer byte a guardar
            LSR w2, w2, #8              // Desplazamos hacia la derecha 8 bits
            STRB w3, [x1], #4           // Almacenamos el byte del registro 3. luego sumamos 4 unidades para que almacene el siguiente byte en la proxima fila
            ADD x4, x4, #1              // Incrementamos el contador de bytes
            CMP x4, #4                  // Si ya almacenamos los 4 bytes terminamos el ciclo
            BNE save_byte_2

        ADD x5, x5, #1              // Incrementamos contador
        CMP x5, #4                  // Si ya se calcularon el resto de columnas, terminamos el ciclo
        BNE calculate_words

    LDR x0, =key                    // Cargar direccion de matriz de estado
    LDR x1, =keyAux                 // Cargar direccion de matriz auxiliar
    MOV x3, #0                      // Indice para la cantidad de bytes recorridos
    replace_key:                    // Mover valores de matriz auxiliar a matriz de estado
        LDRB w4, [x1, x3]           // Cargamos el byte del key auxiliar
        STRB w4, [x0, x3]           // Almacenamos el byte en la key principal
        ADD x3, x3, #1              // Aumentamos en 1 el contador de palabras actualizadas
        CMP x3, #16                 // Si llegamos a 16 bytes copiados, terminamos el ciclo
        BNE replace_key

    LDP x29, x30, [SP], #16
    RET
    .size keyExpansion, (. - keyExpansion)

