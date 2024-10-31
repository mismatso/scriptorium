#!/bin/bash

# Función para mostrar ayuda
mostrar_ayuda() {
    echo "┏━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃ DB Backup — By.Mizaq ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━┛"
    echo
    echo "Uso: $0 --key=passphrase --env=/path-to/.env [--name=name]"
    echo
    echo "Parámetros:"
    echo "  --set-password           Establece una nueva contraseña cifrada en el archivo .env"
    echo "  --key=passphrase         Llave para descifrar la contraseña de la base de datos"
    echo "  --env=/path-to/.env      Ruta al archivo .env que contiene las configuraciones"
    echo "  --name=name              Nombre para el respaldo (opcional, sin timestamp)"
    echo
    echo "Ejemplos:"
    echo "  $0 --set-password --env=/path-to/.env"
    echo "  $0 --key=passphrase --env=/path-to/.env"
    echo "  $0 --key=passphrase --name=martes --env=/path-to/.env"
    echo
}

# Función para cifrar la contraseña
cifrar_password() {
    read -sp "Ingrese la llave para cifrar: " key
    echo
    read -sp "Ingrese la contraseña a cifrar: " password
    echo
    # Usar -pbkdf2 para evitar el warning y fortalecer el cifrado
    encrypted_password=$(echo "$password" | openssl enc -aes-256-cbc -a -salt -pbkdf2 -pass pass:"$key")

    # Verificar si DB_PASSWORD ya existe en el archivo .env
    if grep -q "^DB_PASSWORD=" "$env_file"; then
        # Reemplazar la línea existente de DB_PASSWORD
        sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=\"$encrypted_password\"|" "$env_file"
    else
        # Añadir la línea si no existe
        echo "DB_PASSWORD=\"$encrypted_password\"" >> "$env_file"
    fi

    echo "Contraseña cifrada y guardada en $env_file"
}

# Función para descifrar la contraseña
descifrar_password() {
    openssl enc -aes-256-cbc -d -a -pbkdf2 -pass pass:"$key" <<< "$1"
}

# Leer el archivo .env y cargar variables
cargar_env() {
    if [[ -f "$env_file" ]]; then
        export $(grep -v '^#' "$env_file" | xargs)
    else
        echo "Error: No se encontró el archivo .env en la ruta especificada."
        exit 1
    fi
}

# Validar que todas las variables requeridas estén definidas en el archivo .env
validar_variables_env() {
    required_vars=(DB_NAME DB_USER DB_PASSWORD DB_HOST DB_FILENAME DB_DIRECTORY)
    missing_vars=()

    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done

    if [[ ${#missing_vars[@]} -ne 0 ]]; then
        missing_vars_str=$(printf ", %s" "${missing_vars[@]}")
        missing_vars_str=${missing_vars_str:2}  # Eliminar la primera coma y espacio
        echo "Error: Las siguientes variables faltan en el archivo .env: $missing_vars_str"
        exit 1
    fi
}

# Validar que el directorio de respaldo existe y es escribible
validar_directorio() {
    if [[ ! -d "$DB_DIRECTORY" ]]; then
        echo "Error: El directorio de respaldo '$DB_DIRECTORY' no existe."
        exit 1
    elif [[ ! -w "$DB_DIRECTORY" ]]; then
        echo "Error: No se tienen permisos de escritura en el directorio '$DB_DIRECTORY'."
        exit 1
    fi
}

# Verificar y procesar los argumentos
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --set-password)
            set_password=true
            ;;
        --key=*)
            key="${1#*=}"
            ;;
        --env=*)
            env_file="${1#*=}"
            ;;
        --name=*)
            name="${1#*=}"
            ;;
        *)
            mostrar_ayuda
            exit 1
            ;;
    esac
    shift
done

# Si no hay argumentos, mostrar ayuda
if [[ -z "$env_file" ]]; then
    mostrar_ayuda
    exit 1
fi

# Establecer nueva contraseña cifrada si --set-password está presente
if [[ "$set_password" == true ]]; then
    cifrar_password
    exit 0
fi

# Validar si --key y --env están presentes antes de cargar variables o descifrar
if [[ -z "$key" || -z "$env_file" ]]; then
    echo "Error: Parámetros --key y --env son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Cargar variables desde el archivo .env
cargar_env

# Validar que el archivo .env contenga todas las variables necesarias
validar_variables_env

# Validar que el directorio de respaldo existe y es escribible
validar_directorio

# Descifrar la contraseña
db_password=$(descifrar_password "$DB_PASSWORD")

# Generar el nombre del archivo de respaldo
timestamp=$(date +"%Y%m%d_%H%M%S")
backup_name="${DB_FILENAME}_${name:-$timestamp}.sql"
backup_path="$DB_DIRECTORY/$backup_name"
compressed_backup="$backup_path.tar.gz"

# Ejecuta el comando mysqldump y redirige la salida estándar al archivo de respaldo
mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$db_password" "$DB_NAME" > "$backup_path" 2>&1

# Captura el código de salida del comando
resultado=$?
error_msg=""

# Verifica si hubo algún error
if [[ $resultado -ne 0 ]]; then
  result="[—FAIL——]"
  error_msg=$(<${backup_path})
  rm "$backup_path"
  echo "Ocurrió un error al realizar el respaldo."
  echo $error_msg
else
  # Comprimir el respaldo
  result="[SUCCESS]"
  tar -czf "$compressed_backup" -C "$DB_DIRECTORY" "$backup_name"
  rm "$backup_path"
  echo "Respaldo y compresión completados exitosamente."
fi

# Registrar en backup.log
USER=$(whoami)
log_entry="$result - [$USER] - [$(date +"%Y-%m-%d %H:%M:%S")] - env=$env_file, name=${name:-$timestamp}"
if [[ -n "$error_msg" ]]; then
    log_entry="$log_entry - Error: $error_msg"
fi
echo "$log_entry" >> "$DB_DIRECTORY/backup.log"