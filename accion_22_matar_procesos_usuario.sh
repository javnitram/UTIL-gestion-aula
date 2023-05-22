#!/bin/bash
function accion_22_matar_procesos_usuario() {
    solicitar_usuario_remoto
    solicitar_hosts
    comando_remoto=$(printf "killall -u %s" "$USUARIO_REMOTO")
    comando=("parallel-ssh" "${LONG_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto")
    confirmar_comando "${comando[@]}"
}