#!/bin/bash
MACHINE_ID=$1
OPTION=$2

# Función para mostrar la sintaxis del script
mostrar_ayuda() {
  echo ""
  echo "Uso: vup <ID_DE_LA_MAQUINA> [-d]"
  echo ""
  echo "  <ID_DE_LA_MAQUINA>    ID o nombre de la instancia Vagrant obtenible con 'vagrant global-status'"
  echo "  -d                    Apagar la instancia en lugar de iniciarla"
  echo ""
}

# Validar el segundo argumento
if [ -n "$OPTION" ] && [ "$OPTION" != "-d" ]; then
  echo "Error: Opción desconocida '$OPTION'"
  mostrar_ayuda
  exit 1
fi

# Encontrar la ruta de la instancia de Vagrant
PROJECT_PATH=$(vagrant global-status | grep $MACHINE_ID | awk '{print $5}')

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
  echo "La instancia $MACHINE_ID no fue encontrada."
fi