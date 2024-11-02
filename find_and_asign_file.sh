#!/bin/bash

VERSION="1.0"

# Declarar un array global para almacenar los archivos encontrados
files_array=()

# Lista los elementos de un array que contiene rutas de archivos, dando detalles de sus permisos.
list_array() {
  local array=("$@")  # Recibir todos los argumentos como elementos de un array
  local i=1

  # Iterar sobre los archivos (rutas) encontrados y mostrarlos
  for file in "${array[@]}"; do
    permissions=$(ls -l "$file" | awk '{print $1}')  # Obtiene los permisos del archivo
    echo "$i- $file --> Permisos actuales: $permissions"
    ((i++))  # Incrementa el contador
  done
}

# Buscar el archivo y almacenar sus rutas en files_array
find_file() {
  local file_to_find="$1"
  
  # Buscar el archivo en el sistema y almacenar los resultados en found_files
  found_files=$(find / -type f -name "$file_to_find" 2>/dev/null)

  if [[ -z "$found_files" ]]; then
      echo "No se encontró ningún archivo con el nombre '$file_to_find' en el sistema."
      exit 1
  fi

  # Agregar los archivos encontrados a files_array
  while read -r file; do
    files_array+=("$file")
  done <<< "$found_files"
}

# Cambiar permisos de archivo
change_permissions() {
  local file_path="$1"
  
  # Cambiar permisos del archivo
  chmod u+w,go-w "$file_path"
  echo "Permisos de escritura para el propietario establecidos en el archivo '$file_path'."
}

# Función para mostrar el uso del script
print_use() {
    echo "Uso: $0 [-v] <nombre_de_archivo>"
    echo "Este script busca un archivo/s en el sistema y cambia sus permisos a escritura para el propietario."
    echo "   -v : Mostrar la versión del script"
    exit 1
}

# Función para mostrar la versión del script
print_version() {
    echo "$0, versión $VERSION"
    print_use
    exit 0
}


# Main
# Comprobar si se ha pasado un argumento.
if [ -z "$1" ]; then
    echo "Error en llamada!"
    print_use
fi

# Comprobar si el argumento es la opción de versión
if [[ "$1" == "-v" ]]; then
    print_version
fi


# Archivo a buscar
file_name="$1"

# Llamar a la función para buscar el archivo y almacenar los resultados en files_array
find_file "$file_name"

# Listar los archivos encontrados
echo "Archivos encontrados..."
list_array "${files_array[@]}"

# Llamar a la función de cambio de permisos por cada archivo
echo -e "\nCambiando los permisos..."
for file in "${files_array[@]}"; do
  change_permissions "$file"
done

# Listar los archivos nuevamente, pero ahora con los permisos actualizados
echo -e "\nArchivos modificados..."
list_array "${files_array[@]}"
