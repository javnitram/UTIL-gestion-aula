#!/bin/bash
function accion_09_ver_espacio_disco() {
    solicitar_hosts

    local opcion
    opcion=$(dialogo_n_opciones "Selecciona una opción" "'Disco duro'" "SSD")
    case "$opcion" in
        'Disco duro')
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "df -h | egrep '/home$'")
            confirmar_comando "${comando[@]}"
            ;;
        SSD)
            echo "Opción: $opcion"
            comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "df -h | egrep '/home/hdssd$'")
            confirmar_comando "${comando[@]}"
            ;;
        *) echo "Acción cancelada"
            ;;
    esac
}