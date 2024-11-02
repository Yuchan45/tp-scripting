#!/bin/bash

VERSION="1.0"

# Función para mostrar el uso del script
print_use() {
    echo "Uso: $0 [-t] [-M] [-v] <nombre_grupo|gid>"
    echo "   -t : Mostrar el espacio de todos los grupos"
    echo "   -M : Mostrar los tamaños en MB (con un decimal)"
    echo "   -v : Mostrar la versión del script"
    exit 1
}

# Función para mostrar la versión del script
print_version() {
    echo "$0, versión $VERSION"
    echo "Este script muestra el espacio ocupado por los directorios home de los usuarios de un grupo."
    echo "Opciones:"
    echo "   -t : Calcula el espacio para todos los grupos del sistema"
    echo "   -M : Muestra los tamaños en MB (con un decimal)"
    echo "   -v : Muestra la versión del script"
    exit 0
}

# Variables
print_all=false
in_megabytes=false
total_space=0  # Variable para acumular el espacio total

# Procesar opciones
while getopts ":tMv" option; do
    case ${option} in
        t) print_all=true ;;
        M) in_megabytes=true ;;
        v) print_version ;;
        *) print_use ;;
    esac
done

# Se eliminan parámetros ya procesados por getopts
shift $((OPTIND -1))

# Validación de argumentos
if [ "$print_all" = false ] && [ -z "$1" ]; then
    echo "Error: Falta el nombre del grupo o gid." >&2
    print_use
fi

# Verificación de que el grupo existe
if [ "$print_all" = false ]; then
    while ! getent group "$1" >/dev/null; do
        echo "Error: El grupo '$1' no existe." >&2
        read -p "Por favor, ingrese un nombre de grupo válido o GID: " group
        set -- "$group"  # Actualiza el parámetro $1 con el nuevo nombre
    done
fi

# Función para calcular espacio utilizado
calculate_space() {
    local group=$1
    local gid=$(getent group "$group" | cut -d: -f3)
    local users=$(getent passwd | awk -F: -v gid="$gid" '$4 == gid {print $1}')
    local group_space=0

    # Sumar el espacio ocupado por cada usuario en el grupo
    for user in $users; do
        local dir_home=$(eval echo "~$user")
        if [ -d "$dir_home" ]; then
            local space=$(du -s "$dir_home"  2>/dev/null | awk '{print $1}')
            group_space=$((group_space + space))
        fi
    done

    # Acumular el espacio total
    total_space=$((total_space + group_space))

    # Mostrar el total en el formato deseado
    if [ "$in_megabytes" = true ]; then
        local space_mb=$(echo "scale=1; $group_space / 1024" | bc)
        printf "%-30s %-10s MB\n" "$group - GID: $gid" "$space_mb"
    else
        printf "%-30s %-10s KB\n" "$group - GID: $gid" "$group_space"
    fi
}

# Ejecución principal con paginación
{
    # Mostrar los encabezados
    echo -e "Grupo                          Espacio Ocupado"

    if [ "$print_all" = true ]; then
        for group in $(getent group | cut -d: -f1 | sort); do
            calculate_space "$group"
        done

        # Mostrar el total acumulado
        if [ "$in_megabytes" = true ]; then
            total_space_mb=$(echo "scale=1; $total_space / 1024" | bc) # Verificar si cumple con que muestre un decimal
            echo -e "Total                         $total_space_mb MB"
        else
            echo -e "Total                         $total_space KB"
        fi
    else
        calculate_space "$1"
    fi
} > temp_output.txt

# Contar el número de líneas en el archivo temporal
line_count=$(wc -l < temp_output.txt)

# Mostrar la salida con less solo si es necesario
if [ "$line_count" -gt 20 ]; then
    less temp_output.txt
else
    cat temp_output.txt
fi

# Eliminar el archivo temporal
rm temp_output.txt