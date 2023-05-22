#!/bin/bash
function accion_98_generar_clave_y_copiar() {
    solicitar_hosts
    local linea
    local usuario
    local host
    local puerto
    local comando

    if [[ ${HOSTS[0]} == "-h" ]]; then
        comando="mostrar_hosts_fichero ${HOSTS[1]}"
    else
        HOSTS[0]=""
        comando="echo ${HOSTS[*]}"
    fi

    ssh-keygen -t rsa
    for linea in $($comando)
    do
        usuario=""
        host=""
        puerto=""
        [[ $linea =~ "@" ]] && usuario=${linea/@*/}
        usuario=${usuario:-root}
        host=${linea/*@/}
        host=${host/:*/}
        [[ $linea =~ ":" ]] && puerto=${linea##*:}
        puerto=${puerto:-22}
        ssh-copy-id -i ~/.ssh/id_rsa.pub "$usuario@$host" -p "$puerto"
    done
}