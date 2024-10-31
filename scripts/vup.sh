#!/bin/bash
MACHINE_ID=$1
OPTION=$2

# Función para mostrar la sintaxis del script
mostrar_ayuda() {
  echo ""
  echo "Uso: vup <ID_INSTANCIA> [-d] | vup --all -d | vup --all -u"
  echo ""
  echo "  <ID_INSTANCIA>    ID o nombre de la instancia Vagrant"
  echo "  -d                Apagar la instancia en lugar de iniciarla"
  echo "  --all -d          Apaga todas las máquinas en ejecución"
  echo "  --all -u          Enciende todas las máquinas disponibles"
  echo ""
}

# Validación de 0 argumentos, muestra ayuda si no hay argumentos
if [ -z "$MACHINE_ID" ]; then
  echo "Error: No se proporcionaron argumentos."
  mostrar_ayuda
  exit 1
fi

# Validar opciones para encender o apagar todas las máquinas usando IDs
if [[ "$MACHINE_ID" == "--all" && "$OPTION" == "-d" ]]; then
  echo "Apagando todas las máquinas en ejecución..."
  vagrant global-status | grep running | awk '{print $1}' | xargs -I {} vagrant halt {}
  exit 0
elif [[ "$MACHINE_ID" == "--all" && "$OPTION" == "-u" ]]; then
  echo "Encendiendo todas las máquinas..."
  vagrant global-status | grep poweroff | awk '{print $1}' | xargs -I {} vagrant up {}
  exit 0
fi

# Validar el segundo argumento
if [ -n "$OPTION" ] && [ "$OPTION" != "-d" ]; then
  echo "Error: Opción desconocida '$OPTION'"
  mostrar_ayuda
  exit 1
fi

# Encontrar la ruta de la instancia de Vagrant considerando que la ruta podría
# contener espacios y que podria existir más de una instancia con el mismo nombre
PROJECT_PATHS=$(vagrant global-status | grep $MACHINE_ID | awk '{$1=$2=$3=$4=""; print substr($0,5)}' | sed 's/^ *//;s/ *$//')

# Al establecer IFS (Internal Field Separator) como salto de línea `IFS=$'\n'`,
# Bash solo separará los elementos en cada nueva línea y no en espacios internos.
# Esta estrategia es fundamental para soportar rutas con espacios en blanco.
IFS=$'\n' read -rd '' -a PROJECT_PATH_ARRAY <<< "$PROJECT_PATHS"

# Si existe más de una instancia con el mismo nombre muestro un menú de selección
if [ ${#PROJECT_PATH_ARRAY[@]} -eq 0 ]; then
  echo "La instancia $MACHINE_ID no fue encontrada."
  exit 1
elif [ ${#PROJECT_PATH_ARRAY[@]} -gt 1 ]; then
  echo "Se encontraron múltiples instancias para el ID $MACHINE_ID:"
  PS3="Ingrese la opción deseada: "
  select PROJECT_PATH in "${PROJECT_PATH_ARRAY[@]}"; do
    if [ -n "$PROJECT_PATH" ]; then
      break
    else
      echo "Opción inválida. Intente de nuevo."
    fi
  done
else
  PROJECT_PATH="${PROJECT_PATH_ARRAY[0]}"
fi

# Se procede con el encendido o apagado individual
if [ -d "$PROJECT_PATH" ]; then
  echo "Accediendo a $PROJECT_PATH..."
  cd "$PROJECT_PATH"
  
  if [ "$OPTION" = "-d" ]; then
    echo "Apagando la instancia $MACHINE_ID..."
    vagrant halt
  else
    echo "Iniciando y accediendo a la instancia $MACHINE_ID..."
    vagrant up
    vagrant ssh
  fi
else
  echo "La instancia $MACHINE_ID no tiene un directorio válido."
fi