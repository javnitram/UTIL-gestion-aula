#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_09_ver_espacio_disco() {
    local opcion
    solicitar_hosts \
    && opcion=$(dialogo_n_opciones "Selecciona una opción" "Disco duro" "SSD") \
    && case "$opcion" in
        'Disco duro')
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "df -h | egrep '/home$'")
            confirmar_comando "${comando[@]}"
            ;;
        SSD)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "df -h | egrep '/home/hdssd$'")
            confirmar_comando "${comando[@]}"
            ;;
        *) echo "Acción cancelada"
            ;;
    esac
}