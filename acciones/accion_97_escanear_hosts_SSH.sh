#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_97_escanear_hosts_SSH() {
    params=("$(describe_accion "${FUNCNAME[0]}")" "Esta acción debe realizarse una única vez por cada host para añadirlo a la lista de hosts conocidos por SSH. ¿Continuar?" "Aceptar") 
    if dialogo "${params[@]}"; then 
        solicitar_hosts
        local linea
        local host
        local puerto
        local comando_lista_hosts
        declare -a comando=("return_code=0;")

        if [[ ${HOSTS[0]} == "-h" ]]; then
            comando_lista_hosts="leer_fichero_hosts ${HOSTS[1]}"
        else
            HOSTS[0]=""
            comando_lista_hosts="echo ${HOSTS[*]}"
        fi

        for linea in $($comando_lista_hosts)
        do
            host=""
            puerto=""
            host=${linea/*@/}
            host=${host/:*/}
            [[ $linea =~ ":" ]] && puerto=${linea##*:}
            puerto=${puerto:-22}
            comando+=("ssh-keyscan -p $puerto -H $host >> ~/.ssh/known_hosts || return_code=1;")
        done
        comando+=('exit $return_code')
        comando=("bash" "-c" "${comando[*]}")
        confirmar_comando "${comando[@]}"
    fi
}
