#!/bin/bash

VERSION="1.0"

# Función para mostrar el uso del script
print_use() {
    echo "Uso: $0 [-v] <número> <porcentaje>"
    echo "Este script muestra el porcentaje de un número y lo indica a todos los usuarios conectados."
    echo "   -v : Mostrar la versión del script"
    exit 1
}

# Función para mostrar la versión del script
print_version() {
    echo "$0, versión $VERSION"
    print_use
    exit 0
}

# Procesar opciones
while getopts ":v" option; do
    case ${option} in
        v) print_version ;;
    esac
done

# Validación de argumentos
if [ $# -ne 2 ]; then
    echo "Error en llamada!"
    print_use
fi

number=$1
percentage=$2

# Verificación de que los parámetros son números
if ! [[ "$number" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$percentage" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: Los parámetros deben ser números."
    print_use
fi

# Cálculo del porcentaje
result=$(echo "scale=2; $number * $percentage / 100" | bc)

echo "Resultado: El $percentage% de $number es $result"

# Enviar el resultado a todos los usuarios conectados
wall "Resultado: El $percentage% de $number es $result"