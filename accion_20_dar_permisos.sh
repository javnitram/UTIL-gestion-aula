#!/bin/bash
function accion_20_dar_permisos() {
    solicitar_usuario_remoto
    solicitar_ruta_remota
    solicitar_hosts
    comando_remoto=$(
        printf "chown -R %s:%s %q && chmod -R u+rw %q" \
               "$USUARIO_REMOTO" \
               "$USUARIO_REMOTO" \
               "$RUTA_REMOTA" \
               "$RUTA_REMOTA" \
        )
    comando=("parallel-ssh" "${LONG_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto")
    confirmar_comando "${comando[@]}"
}