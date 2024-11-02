#!/bin/bash

VERSION="1.0"
DIR="$(dirname "$(realpath "$0")")"  # Obtener la ruta del directorio donde está el script

# Función para mostrar la versión del menú
mostrar_version() {
    echo "Menú de Scripts, versión $VERSION"
    exit 0
}

# Función para mostrar el uso del menú
mostrar_uso() {
    echo "Uso: $0 [-v] [opción]"
    echo "Opciones:"
    echo "   1 : Calcular espacio utilizado por grupo"
    echo "   2 : Buscar archivo y asignar permiso de escritura al propietario"
    echo "   3 : Calcular porcentaje"
    echo "   -v : Mostrar versión del menú"
    exit 1
}

# Menú principal
while true; do
    echo "-------------------"
    echo "Menú de Scripts"
    echo "-------------------"
    echo "1) Calcular espacio utilizado por grupo"
    echo "2) Buscar archivo y asignar permiso de escritura al propietario"
    echo "3) Calcular porcentaje"
    echo "4) Salir"
    echo "-------------------"
    echo -n "Seleccione una opción: "
    read opcion

    case $opcion in
        1)
            echo -n "Ingrese el nombre del grupo o GID: "
            read grupo
            "$DIR/used-space.sh" "$grupo"  # Ejecutar script de espacio
            ;;
        2)
            echo -n "Ingrese el nombre del archivo: "
            read archivo
            "$DIR/find_and_asign_file.sh" "$archivo"  # Ejecutar script de permisos
            ;;
        3)
            echo -n "Ingrese un número: "
            read numero
            echo -n "Ingrese un porcentaje: "
            read porcentaje
            "$DIR/percentage.sh" "$numero" "$porcentaje"  # Ejecutar script de porcentaje
            ;;
        4)
            echo "Saliendo..."
            exit 0
            ;;
        -v)
            mostrar_version
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac

    echo "-------------------"
    echo "¿Desea realizar otra operación? (s/n)"
    read continuar
    if [[ "$continuar" != "s" ]]; then
        break
    fi
done