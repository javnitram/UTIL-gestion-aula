#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_18_copiar() {
    solicitar_ruta_local \
    && solicitar_ruta_remota \
    && solicitar_hosts \
    && comando=("parallel-scp" "${LONG_OPTS[@]}" "-r" "${HOSTS[@]}" "$RUTA_LOCAL" "$RUTA_REMOTA") \
    && confirmar_comando "${comando[@]}"
}