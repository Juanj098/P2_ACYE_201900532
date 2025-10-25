# UNIVERSIDAD DE SAN CARLOS DE GUATEMALA
## Facultad de Ingeniería  
### Proyecto: Implementación del Algoritmo AES-128 en ARM64 Assembly  
**Autor:** Juan José Gerardi  
**Curso:** Arquitectura de Computadores I  
**Fecha:** Octubre 2025  

---

## 1. Introducción

El presente documento describe el proceso de desarrollo de una implementación completa del algoritmo **AES-128 (Advanced Encryption Standard)** utilizando lenguaje ensamblador para arquitectura **ARM64**.  
El objetivo principal del proyecto fue comprender a profundidad la manipulación de memoria, el procesamiento de datos a bajo nivel y la interacción directa con el sistema operativo mediante llamadas al kernel (syscalls) para lectura y escritura.

La implementación reproduce fielmente las **10 rondas de cifrado** definidas por el estándar FIPS-197, incluyendo las operaciones:
- **SubBytes**  
- **ShiftRows**  
- **MixColumns**  
- **AddRoundKey**  
- **KeyExpansion**

Adicionalmente, se desarrollaron rutinas auxiliares de entrada/salida, conversión, visualización de matrices y depuración.

---

## 2. Objetivos

### 2.1 Objetivo general
Implementar el algoritmo AES-128 en lenguaje ensamblador ARM64, garantizando su correcto funcionamiento y comprensión a nivel de instrucción.

### 2.2 Objetivos específicos
- Comprender el flujo interno de AES y su relación con la arquitectura de 64 bits.  
- Diseñar un sistema modular basado en funciones (`.s` separados) que representen cada etapa del algoritmo.  
- Implementar mecanismos de lectura de texto y clave desde consola.  
- Visualizar el estado interno del cifrado en cada ronda mediante impresión formateada.  
- Documentar los principales desafíos técnicos y su resolución.

---

## 3. Metodología de Desarrollo

El proyecto fue desarrollado de forma iterativa, empleando herramientas de bajo nivel y simulación.  
Cada módulo fue probado de manera independiente antes de integrarse al flujo principal.

### 3.1 Herramientas utilizadas
- **Assembler:** `as` (GNU Assembler ARM64)  
- **Linker:** `ld`  
- **Debugger:** `gdb-multiarch`  
- **Emulador:** `qemu-aarch64`  
- **Sistema Operativo:** Linux Fedora 40 (ARM64 emulado)  
- **Editor:** Visual Studio Code con plugin ARM Assembly  

### 3.2 Estructura del proyecto

```
AES_ARM64/
│──Src
    ├── constants.s
    ├── readTextInput.s
    ├── addRoundKey.s
    ├── subBytes.s
    ├── shiftRows.s
    ├── mixColumns.s
    ├── keyExpansion.s
    ├── utils.s
    └── main.s
├──Build
    ├── main
    └── main.o
└── compile.sh
```


Cada archivo `.s` contiene una función independiente, declarada con `.global` y documentada mediante comentarios.  
El archivo `main.s` coordina las llamadas y controla el flujo de ejecución.

---

## 4. Desarrollo del sistema

### 4.1 Flujo general del cifrado
1. **Entrada de texto y clave:**  
   Se solicita al usuario una cadena de hasta 16 caracteres para cifrar y una clave de 16 bytes.  
   Las funciones `readTextInput` y `readKeyInput` transforman la entrada ASCII en formato column-major para llenar las matrices `matState` y `key`.

2. **Generación de subclaves:**  
   `keyExpansion` crea las 11 subclaves (ronda 0 a ronda 10) y las almacena en `expandedKeys`.

3. **Ejecución de rondas:**  
   La rutina `AESRounds` implementa las 10 rondas con el siguiente flujo:
```
AddRoundKey (r0)
for ronda in 1..10:
SubBytes
ShiftRows
(MixColumns si ronda < 10)
AddRoundKey(ronda)
```

4. **Impresión del resultado:**  
Tras finalizar las rondas, se imprime el **criptograma final** en formato hexadecimal.

### 4.2 Gestión de memoria y registros
- Cada matriz (`matState`, `key`, `expandedKeys`) se ubica en `.bss` con espacio reservado fijo.  
- Los registros `x19–x29` se utilizan para variables temporales dentro de las funciones.  
- Se emplean `stp` y `ldp` para preservar el marco de pila (`frame pointer`) en cada llamada.

### 4.3 Entradas y salidas (syscalls)
Se implementaron macros reutilizables para simplificar el uso de llamadas al sistema:

```asm
.macro print fd, buffer, len
 mov x0, \fd
 ldr x1, =\buffer
 mov x2, \len
 mov x8, #64   // syscall write
 svc #0
.endm
```
y 

```asm
.macro read fd, buffer, len
    mov x0, \fd
    ldr x1, =\buffer
    mov x2, \len
    mov x8, #63   // syscall read
    svc #0
.endm

```

## 5. Retos encontrados

### 5.1 Gestión de la pila y registros

Uno de los principales retos fue manejar el stack frame y el preservado de registros en llamadas anidadas.  
Inicialmente, algunas funciones sobrescribían valores críticos como `x19` o `x20`, provocando resultados erróneos en las rondas posteriores.

🧩 **Solución:**  
Cada función se encapsuló con:

```asm
stp x29, x30, [sp, #-16]!
...
ldp x29, x30, [sp], #16
```
al inicio y al final, garantizando la integridad del contexto.

### 5.2 Cálculo de índices en column-major

El formato de almacenamiento del AES no es fila-por-fila, sino columna-por-columna.
Inicialmente, los bytes se cargaban en orden lineal, lo que generaba resultados incorrectos en la función mixColumns.

🧩 Solución:
Se implementó la fórmula de indexación:
```
índice = (columna * 4) + fila

```
para todos los accesos de matState, asegurando que la organización cumpla con el estándar AES.

### 5.3 Multiplicación en el campo de Galois (GF(2^8))

Implementar la operación de multiplicación por 2 y 3 fue un reto conceptual, ya que debía hacerse mediante operaciones XOR y desplazamientos lógicos, simulando el comportamiento del campo finito GF(2^8).

🧩 Solución:
Se crearon las funciones auxiliares galois_mul2 y galois_mul3, que aplican la reducción modular por el polinomio irreducible: