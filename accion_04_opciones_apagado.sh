#!/bin/bash
function accion_04_opciones_apagado() {
    solicitar_hosts
    local opcion
    opcion=$(dialogo_n_opciones "Selecciona una opción" "Apagar" "Reiniciar")
    case "$opcion" in
        Apagar)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "systemctl poweroff")
            confirmar_comando "${comando[@]}" ;;
        Reiniciar)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "systemctl reboot")
            confirmar_comando "${comando[@]}" ;;
        *) echo "Acción cancelada" ;;
    esac
}