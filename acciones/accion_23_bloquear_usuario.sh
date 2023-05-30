#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_23_bloquear_usuario() {
    solicitar_usuario_remoto \
    && solicitar_hosts \
    && comando_remoto=$(printf "usermod -L %s" "$USUARIO_REMOTO") \
    && comando=("parallel-ssh" "${LONG_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto") \
    && confirmar_comando "${comando[@]}"
}