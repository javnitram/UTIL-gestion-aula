#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_96_comprobar_conexión_SSH() {
    solicitar_hosts \
    && comando_remoto='echo "$(whoami)@$(hostname). Uptime: $(uptime -p). Users: $(users)"' \
    && comando=("parallel-ssh" -i "${SHORT_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto") \
    && confirmar_comando "${comando[@]}"
}