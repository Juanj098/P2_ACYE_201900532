#!/usr/bin/env bash

# TODO: Configuracion de parametros base
AS="aarch64-linux-gnu-as"
LD="aarch64-linux-gnu-ld"
ASFLAGS="-g"                # * incluye símbolos de depuración
LDFLAGS="-g"                # * para gdb
SRC_DIR="./src"                # * carpeta de código fuente
BUILD_DIR="./build"         # * carpeta donde guardar .o
OUTPUT="main"               # * nombre del ejecutable final

if [[ "$1" == "build" ]]; then
    echo "🔧 Modo: Compilar código fuente..."
elif [[ "$1" == "clean" ]]; then
    echo "🧹 Modo: Limpiar build..."

    rm -rf "$BUILD_DIR"

    if [[ -f "./$OUTPUT" ]]; then
        rm "./$OUTPUT"
    fi

    exit 0
fi

if [[ -d "$BUILD_DIR" ]]; then
    echo "🛠️ Ensamblando Archivos..."
else
    echo "📁 Creando directorio build..."
    mkdir "$BUILD_DIR"

    if [[ $? -ne 0 ]]; then
        echo "❌ No Se Pudo Crear Directorio Build"
        exit 1
    fi

    echo "🛠️ Ensamblando Archivos ..."
fi

echo " $OUTPUT.s -> $OUTPUT.o"
$AS $ASFLAGS -I "$SRC_DIR" -o "$BUILD_DIR/$OUTPUT.o" "$SRC_DIR/$OUTPUT.s"

echo "✅ Ensamblado completado."

echo "🔗 Enlazando objetos..."
$LD $LDFLAGS "$BUILD_DIR"/"$OUTPUT".o -o "$BUILD_DIR/$OUTPUT"
if [ $? -ne 0 ]; then
    echo "❌ Error enlazando objetos"
    exit 1
fi

echo "✅ Enlazado completado: $OUTPUT"
echo "🎯 Ejecutable listo."

if [[ "$2" == "exec" ]]; then
    echo "🚀 Ejecutando programa..."
    qemu-aarch64 "$BUILD_DIR/$OUTPUT"
elif [[ "$2" == "debug" ]]; then
    echo "🐞 Iniciando depuración..."
    qemu-aarch64 -g 1234 "$BUILD_DIR/$OUTPUT" &
    gnome-terminal -- bash -c "gdb-multiarch -q --nh \
        -ex 'set architecture aarch64' \
        -ex 'file \"$OUTPUT\"' \
        -ex 'target remote localhost:1234' \
        -ex 'layout split' \
        -ex 'layout regs'; exec bash"
fi