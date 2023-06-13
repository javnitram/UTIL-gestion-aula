#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Identifica el directorio en el que está el script, independientemente de dónde se ubique
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Importar configuración
source "${script_dir}/.config"

# Importar funciones auxiliares y variables globales
source "${script_dir}/lib/common.sh"

# Importar funciones que implementan opciones de menú
for f in "${script_dir}"/acciones/accion_*.sh; do
    source "$f"
done

# Provoca que el script termine si se usa una variable no declarada
set -u

function main() {
    local funcion

    if which whiptail >/dev/null; then
        while true; do
            mapfile -t funciones_opciones < <(declare -F \
                        | grep " accion_" \
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
            funcion=$(dialogo_base --title "Gestión de aula (opciones de usuario ${SUDO_USER:-root})" --menu "Elige una acción" --notags $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones \
                "${opciones[@]}"  3>&2 2>&1 1>&3)

            [[ -z $funcion ]] && exit 0
            echo "Acción elegida: $(describe_accion "$funcion")"

            ejecutar "$funcion"
        done
    else
        echo "whiptail no está instalado" 2>&1
    fi
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    # Están ejecutando directamente este script, no importándolo con source
    if [[ "$(id -u)" -eq 0 ]]; then
        main "$@"
    else
        echo "Ejecuta el script con sudo o como usuario root" >&2
        exit 255
    fi
fi