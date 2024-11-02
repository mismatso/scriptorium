#!/bin/bash

# Constante de versión
VERSION="0.8.2"

# Función para mostrar ayuda
show_help() {
    echo
    echo "┏━━━━━━━━━━━━━━━━┓"
    echo "┃ VUP — By.Mizaq ┃"
    echo "┗━━━━━━━━━━━━━━━━┛"
    echo "Version $VERSION"
    echo
    echo "NOMBRE"
    echo "     vup - Facilita la gestión de máquinas virtuales Vagrant,"
    echo "           permitiendo arrancarlas y conectarse a ellas,"
    echo "           o bien apagarlas, sin necesidad de navegar al"
    echo "           directorio del Vagrantfile."
    echo   
    echo "SINTAXIS"
    echo "     vup [opciones] [máquinas...]"
    echo "     vup [-u|--up|-d|--down] [-a|-all|<máquina>] ..."
    echo "     vup [-c|--connect] [-q|--quiet] [<máquina>]"
    echo "     vup [-v|-h|-p|-s]"
    echo
    echo "OPCIONES"
    echo "     -u, --up            Inicia la(s) máquina(s) especificada(s)"
    echo "     -d, --down          Apaga la(s) máquina(s) especificada(s)"
    echo "     -a, --all           Aplica la operación a todas las máquinas"
    echo "     -c, --connect       Conecta a la máquina especificada"
    echo "     -q, --quiet         Enciende la máquina sin preguntar (se utiliza con -c)"
    echo "     -v, --version       Muestra la versión del script"
    echo "     -h, --help          Muestra esta ayuda"
    echo "     -p, --paths         Muestra las rutas de las máquinas Vagrant"
    echo "     -s, --status        Muestra el estado completo de las máquinas Vagrant"
    echo
    echo "EJEMPLOS"
    echo "     vup webserver       # Inicia la máquina 'webserver'"
    echo "     vup -u webserver    # Igual a lo anterior"
    echo "     vup -d webserver    # Apaga la máquina 'webserver'"
    echo "     vup -u --all        # Inicia todas las máquinas"
    echo "     vup -d --all        # Apaga todas las máquinas"
    echo "     vup -p              # Muestra las rutas de las máquinas"
    echo "     vup -s              # Muestra el estado completo de las máquinas Vagrant"
    echo "     vup -c webserver    # Conecta a la máquina 'webserver'"
    echo "     vup -c -q webserver # Conecta a 'webserver', encendiéndola si está apagada"
    echo
    if [ ! -z "$ERROR_MSG" ]; then
        echo $ERROR_MSG
        echo
    fi
}

# Variables de acción y listas de máquinas
UP_MACHINES=()
DOWN_MACHINES=()
ALL_FLAG=false
SHOW_HELP=false
SHOW_VERSION=false
SHOW_PATHS=false
SHOW_STATUS=false
CONNECT_MACHINE=""
QUIET_MODE=false
ACTION=""
IS_RUNNING=false
MULTI_UP_MODE=false
ERROR_MSG=""

# Función para obtener el ID y la ruta completa de la máquina según acción
get_machine_id_and_path() {
    local MACHINE=$1
    local ACTION=$2
    IS_RUNNING=false  # Reinicia la bandera de estado de la máquina

    # Buscar la instancia según el estado
    if [[ "$ACTION" == "down" ]]; then
        MACHINES_PATHS=$(vagrant global-status | grep "$MACHINE" | grep "running" | awk '{id=$1; $1=$2=$3=$4=""; print id,substr($0,5)}')
    elif [[ "$ACTION" == "up" ]]; then
        MACHINES_PATHS=$(vagrant global-status | grep "$MACHINE" | grep "poweroff" | awk '{id=$1; $1=$2=$3=$4=""; print id,substr($0,5)}')
        
        # Si la máquina está en estado `running`, cambia `IS_RUNNING` a true y devuelve su ID y PATH
        if [ -z "$MACHINES_PATHS" ]; then
            MACHINES_PATHS=$(vagrant global-status | grep "$MACHINE" | grep "running" | awk '{id=$1; $1=$2=$3=$4=""; print id,substr($0,5)}')
            if [ -n "$MACHINES_PATHS" ]; then
                IS_RUNNING=true
            fi
        fi
    else
        MACHINES_PATHS=$(vagrant global-status | grep "$MACHINE" | grep "running\|poweroff" | awk '{id=$1; $1=$2=$3=$4=""; print id,substr($0,5)}')
    fi

    IFS=$'\n' read -rd '' -a MACHINES_PATHS_ARRAY <<< "$MACHINES_PATHS"

    if [ ${#MACHINES_PATHS_ARRAY[@]} -eq 0 ]; then
        echo "La máquina '$MACHINE' no fue encontrada en el estado deseado."
        exit 1
    elif [ ${#MACHINES_PATHS_ARRAY[@]} -gt 1 ]; then
        echo "Se encontraron múltiples instancias para '$MACHINE':"
        PS3="Seleccione la opción deseada: "
        
        select project in "${MACHINES_PATHS_ARRAY[@]}"; do
            if [ -n "$project" ]; then
                MACHINE_ID=$(echo "$project" | awk '{print $1}')
                MACHINE_PATH=$(echo "$project" | cut -d' ' -f2-)
                break
            else
                echo "Opción inválida. Intente de nuevo."
            fi
        done
    else
        MACHINE_ID=$(echo "${MACHINES_PATHS_ARRAY[0]}" | awk '{print $1}')
        MACHINE_PATH=$(echo "${MACHINES_PATHS_ARRAY[0]}" | cut -d' ' -f2-)
    fi
}

# Función para realizar la operación en una máquina
perform_action() {
    ACTION=$1
    MACHINE_ID=$2
    get_machine_id_and_path "$MACHINE_ID" "$ACTION"
    
    if [ "$IS_RUNNING" = true ] && [ "$ACTION" = "up" ]; then
        # Si la máquina ya está encendida, mostrar mensaje y omitir conexión SSH si es modo múltiple
        if [ "$MULTI_UP_MODE" = true ]; then
            echo "La máquina '$MACHINE_ID' ya está encendida. Omitiendo conexión."
        else
            echo "La máquina '$MACHINE_ID' ya está encendida. Conectando mediante SSH..."
            vagrant ssh "$MACHINE_ID"
        fi
    elif [ -d "$MACHINE_PATH" ]; then
        echo "Accediendo a $MACHINE_PATH..."
        cd "$MACHINE_PATH"
        if [ "$ACTION" = "down" ]; then
            echo "Apagando la instancia $MACHINE_ID..."
            vagrant halt
        else
            echo "Iniciando la instancia $MACHINE_ID..."
            vagrant up
        fi
    else
        echo "La instancia $MACHINE_ID no tiene un directorio válido."
    fi
}

# Si no se pasan argumentos, mostrar la ayuda
if [ "$#" -eq 0 ]; then
    SHOW_HELP=true
fi

# Procesamiento de argumentos
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -u|--up)
            ACTION="up"
            if [[ "$2" && "$2" != -* ]]; then
                UP_MACHINES+=("$2")
                shift
            fi
            ;;
        -d|--down)
            ACTION="down"
            if [[ "$2" && "$2" != -* ]]; then
                DOWN_MACHINES+=("$2")
                shift
            fi
            ;;
        -a|--all)
            ALL_FLAG=true
            ;;
        -v|--version)
            SHOW_VERSION=true
            ;;
        -h|--help)
            SHOW_HELP=true
            ;;
        -p|--paths)
            SHOW_PATHS=true
            ;;
        -s|--status)
            SHOW_STATUS=true
            ;;
        -c|--connect)
            CONNECT_MACHINE="$2"
            shift
            ;;
        -q|--quiet)
            QUIET_MODE=true
            ;;
        *)
            if [[ -z "$1" || "$1" == -* ]]; then
                echo "Error: opción o argumento no reconocido: $1"
                exit 1
            fi
            UP_MACHINES+=("$1")
            ;;
    esac
    shift
done

# Validación de combinaciones de argumentos no válidas
if $ALL_FLAG && [ -z "$ACTION" ]; then
    ERROR_MSG="Error: La opción --all (-a) requiere que se especifique una acción con -u (up) o -d (down)."
    SHOW_HELP=true
elif [[ "$ACTION" == "up" && ${#UP_MACHINES[@]} -eq 0 && "$ALL_FLAG" == false ]]; then
    ERROR_MSG="Error: La opción --up (-u) requiere que se especifique una máquina o la opción --all (-a)."
    SHOW_HELP=true
elif [[ "$ACTION" == "down" && ${#DOWN_MACHINES[@]} -eq 0 && "$ALL_FLAG" == false ]]; then
    ERROR_MSG="Error: La opción --down (-d) requiere que se especifique una máquina o la opción --all (-a)."
    SHOW_HELP=true
fi

# Activar modo múltiple si hay más de una máquina en UP_MACHINES
if [ ${#UP_MACHINES[@]} -gt 1 ]; then
    MULTI_UP_MODE=true
fi

# Mostrar la versión
if $SHOW_VERSION; then
    echo "vup.sh v$VERSION"
    exit 0
fi

# Mostrar la ayuda
if $SHOW_HELP; then
    show_help
    exit 0
fi

# Mostrar las rutas de las máquinas Vagrant
if $SHOW_PATHS; then
    echo
    echo "Rutas de las máquinas Vagrant"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"    
    vagrant global-status | grep "running\|poweroff" | awk '{$1=$2=$3=$4=""; print substr($0,5)}' | sed 's/^ *//;s/ *$//'
    echo    
    exit 0
fi

# Mostrar el estado completo de las máquinas Vagrant
if $SHOW_STATUS; then
    echo
    printf "%-8s %-9s %s\n" "ID" "Estado" "Ruta"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    vagrant global-status | grep "running\|poweroff" | awk '{id=$1; state=$4; $1=$2=$3=$4=""; printf "%-8s %-9s %s\n", id, state, substr($0,5)}'
    echo
    exit 0
fi

# Conectar a la máquina especificada
if [[ -n "$CONNECT_MACHINE" ]]; then
    get_machine_id_and_path "$CONNECT_MACHINE" "connect"

    # Verificar si la máquina está encendida
    if ! vagrant global-status | grep -q "^$MACHINE_ID .* running"; then
        if $QUIET_MODE; then
            echo "Encendiendo la máquina '$CONNECT_MACHINE' automáticamente."
            vagrant up "$MACHINE_ID"
        else
            read -p "La máquina '$CONNECT_MACHINE' está apagada. ¿Desea encenderla? [S/n]: " choice
            choice=${choice:-S}
            if [[ "$choice" =~ ^[Ss]$ ]]; then
                vagrant up "$MACHINE_ID"
            else
                echo "Conexión cancelada."
                exit 0
            fi
        fi
    fi

    # Conectarse a la máquina por SSH
    echo "Conectando a la máquina '$CONNECT_MACHINE' (ID: $MACHINE_ID)..."
    vagrant ssh "$MACHINE_ID"
    exit 0
fi

# Ejecutar la acción para todas las máquinas solo si `ALL_FLAG` y `ACTION` están presentes
if $ALL_FLAG && [[ "$ACTION" == "up" || "$ACTION" == "down" ]]; then
    if [[ "$ACTION" == "up" ]]; then
        echo "Encendiendo todas las máquinas..."
        vagrant global-status | grep poweroff | awk '{print $1}' | xargs -I {} vagrant up {}
    elif [[ "$ACTION" == "down" ]]; then
        echo "Apagando todas las máquinas en ejecución..."
        vagrant global-status | grep running | awk '{print $1}' | xargs -I {} vagrant halt {}
    fi
    exit 0
else
    # Ejecutar acciones para máquinas individuales en UP_MACHINES y DOWN_MACHINES
    for machine in "${UP_MACHINES[@]}"; do
        perform_action "up" "$machine"
    done
    for machine in "${DOWN_MACHINES[@]}"; do
        perform_action "down" "$machine"
    done
fi