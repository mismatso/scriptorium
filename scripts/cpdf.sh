#!/bin/bash

# Verificar si se proporcionó un archivo como argumento
if [ $# -ne 1 ]; then
    echo "Uso: $0 archivo.pdf"
    exit 1
fi

input_pdf="$1"

# Verificar si el archivo existe
if [ ! -f "$input_pdf" ]; then
    echo "El archivo $input_pdf no existe."
    exit 1
fi

# Obtener el nombre base del archivo sin extensión
base_name="${input_pdf%.*}"

# Mensaje al usuario
echo "Comprimiendo el archivo $base_name.pdf"

# Generar nombres para los archivos intermedios y finales
uncompressed_pdf="${base_name}_uncompressed.pdf"
compressed_pdf="${base_name}_comprimido.pdf"

# Descomprimir el PDF original
pdftk "$input_pdf" output "$uncompressed_pdf" uncompress

# Comprimir el PDF descomprimido
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook \
   -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$compressed_pdf" "$uncompressed_pdf"

# Eliminar el archivo descomprimido temporal
rm "$uncompressed_pdf"

echo "Archivo comprimido generado: $compressed_pdf"
