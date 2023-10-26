#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

COMANDO_COMO_USUARIO=""
function accion_25_ejecutar_como_usuario() {
    solicitar_usuario_remoto \
    && solicitar_ruta_remota \
    && COMANDO_COMO_USUARIO=$(solicitar_cadena "$(describe_accion "${FUNCNAME[0]}")" "Comando a ejecutar como usuario en la ruta: " "$COMANDO_COMO_USUARIO") \
    && solicitar_hosts \
    && comando_remoto=$(
        printf "sudo -H -u %s bash -c 'cd %s && %s' " \
               "$USUARIO_REMOTO" \
               "$RUTA_REMOTA" \
               "$COMANDO_COMO_USUARIO" \
        ) \
    && comando=("parallel-ssh" -i "${SHORT_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto") \
    && confirmar_comando "${comando[@]}"
}
