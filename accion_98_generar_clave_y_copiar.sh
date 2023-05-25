#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_98_generar_clave_y_copiar() {
    solicitar_hosts
    local linea
    local usuario
    local host
    local puerto
    local comando
    local password
    local ok

    ok=true
    if [[ ${HOSTS[0]} == "-h" ]]; then
        comando="mostrar_hosts_fichero ${HOSTS[1]}"
    else
        HOSTS[0]=""
        comando="echo ${HOSTS[*]}"
    fi

    ssh-keygen -t rsa
    which sshpass >& /dev/null && password=$(dialogo_password_oculto)
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
        if which sshpass >& /dev/null; then
            sshpass -p "$password" ssh-copy-id -i ~/.ssh/id_rsa.pub -p "$puerto" "$usuario@$host" || ok=false
        else
            ssh-copy-id -i ~/.ssh/id_rsa.pub -p "$puerto" "$usuario@$host" || ok=false
        fi            
    done
    $ok
}