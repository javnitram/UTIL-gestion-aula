#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_04_opciones_apagado() {
    local opcion
    opcion=$(dialogo_n_opciones "Selecciona una opción" "Apagar" "Reiniciar") \
    && solicitar_hosts \
    && case "$opcion" in
        Apagar)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "systemctl poweroff")
            confirmar_comando "${comando[@]}"
            ;;
        Reiniciar)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "systemctl reboot")
            confirmar_comando "${comando[@]}"
            ;;
        *) echo "Acción cancelada"
            ;;
    esac
}