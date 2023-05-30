#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_20_dar_permisos() {
    solicitar_usuario_remoto \
    && solicitar_ruta_remota \
    && solicitar_hosts \
    && comando_remoto=$(
        printf "chown -R %s:%s %q && chmod -R u+rw %q" \
               "$USUARIO_REMOTO" \
               "$USUARIO_REMOTO" \
               "$RUTA_REMOTA" \
               "$RUTA_REMOTA" \
        ) \
    && comando=("parallel-ssh" "${LONG_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto") \
    && confirmar_comando "${comando[@]}"
}