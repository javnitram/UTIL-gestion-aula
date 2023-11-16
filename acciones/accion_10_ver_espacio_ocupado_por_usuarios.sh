#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_10_ver_espacio_ocupado_por_usuarios() {
    local opcion
    solicitar_hosts \
    && opcion=$(dialogo_n_opciones "Selecciona una opción" "Disco duro" "SSD") \
    && case "$opcion" in
        'Disco duro')
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "du -h -d 1 /home/ | grep -E 'alumno|examen' | sort -hr")
            confirmar_comando "${comando[@]}"
            ;;
        SSD)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "du -h -d 1 /home/hdssd/ | grep -E 'alumno|examen' | sort -hr")
            confirmar_comando "${comando[@]}"
            ;;
        *) echo "Acción cancelada"
            ;;
    esac
}