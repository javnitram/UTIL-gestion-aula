#!/bin/bash
function accion_18_copiar() {
    solicitar_ruta_local
    solicitar_ruta_remota
    solicitar_hosts
    comando=("parallel-scp" "${LONG_OPTS[@]}" "-r" "${HOSTS[@]}" "$RUTA_LOCAL" "$RUTA_REMOTA")
    confirmar_comando "${comando[@]}"
}