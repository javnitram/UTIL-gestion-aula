#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Importar configuración
source .config

# Importar funciones auxiliares y variables globales
source common.sh

# Importar funciones que implementan opciones de menú
for f in accion_*.sh; do
    source "$f"
done

# Provoca que el script termine si se usa una variable no declarada
set -u

function main() {
    local funcion

    if which whiptail >/dev/null; then
        while true; do
            mapfile -t funciones_opciones < <(declare -F \
                        | grep "accion_" \
                        | sed 's/^declare -f//' \
                        | sort -n -t_ -k1 \
                        | tr '\n' ' ')
            opciones=()
            for i in $funciones_opciones
            do
                local item
                item=$(describe_accion $i)
                opciones+=("$i" "$item")
            done

            nOpciones=$(altura_opciones_menu "${opciones[@]}")
            funcion=$(whiptail --title "Gestión de puesto del aula" --menu "Elige una acción" --notags $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones \
                "${opciones[@]}"  3>&2 2>&1 1>&3)

            [[ -z $funcion ]] && exit 0
            echo "Acción elegida: $(describe_accion "$funcion")"

            if "$funcion"; then
                echo "Acción completada con éxito o cancelada por el usuario"
                confirmar_continuacion_asistente
            elif [[ -d "$TMP_STDERR_DIR" ]]; then
                echo "Todas las conexiones completadas, hubo uno o varios errores"
                confirmar_continuacion_asistente
                # Esta ruta existe si ha habido errores y el comando se lanzó con opción -e <dir>
                # para redirigir errores a un fichero por cada conexión
                params=("$(describe_accion "$funcion")" "Hubo uno o varios errores, pueden verse en la traza del terminal\n¿Mostrar?" "Mostrar") 
                if dialogo "${params[@]}"; then 
                    echo "Detalle de errores:"
                    # Mostramos errores, para ello usamos grep que, cuando recibe
                    # varios ficheros, identifica en cada línea el nombre del fichero
                    # que la contiene
                    # A continuación dejamos únicamente el nombre del fichero (sin el
                    # directorio padre), dicho nombre identifica la conexión
                    # que produjo fallos
                    grep ".*" "$TMP_STDERR_DIR"/* 2> /dev/null | sed 's/.*stderr\/*//g'
                    confirmar_continuacion_asistente
                fi
            else
                echo "Acción completada con posibles errores en la traza anterior"
                confirmar_continuacion_asistente
            fi
            # Limpiar ficheros temporales
            rm -rf --preserve-root "$TMP_STDOUT_DIR" "$TMP_STDERR_DIR"
            echo
        done
    else
        echo "whiptail no está instalado" 2>&1
    fi
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    # Están ejecutando directamente este script, no importándolo con source
    main "$@"
fi