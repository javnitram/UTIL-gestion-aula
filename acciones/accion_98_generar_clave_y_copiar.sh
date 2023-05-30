#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_98_generar_clave_y_copiar() {
    params=("$(describe_accion "${FUNCNAME[0]}")" "Esta acción debe realizarse una única vez por cada host para que no pida contraseña por SSH para el usuario configurado. ¿Continuar?" "Aceptar") \
    && if dialogo "${params[@]}"; then 
        local linea
        local usuario
        local host
        local puerto
        local comando_lista_hosts
        local password
        declare -a comando=("return_code=0;")

        solicitar_hosts \
        && if [[ ${HOSTS[0]} == "-h" ]]; then
            comando_lista_hosts="leer_fichero_hosts ${HOSTS[1]}"
        else
            HOSTS[0]=""
            comando_lista_hosts="echo ${HOSTS[*]}"
        fi \
        && ssh-keygen -t rsa \
        && which sshpass >& /dev/null && password=$(dialogo_password_oculto) \
        && for linea in $($comando_lista_hosts)
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
                comando+=("sshpass -p $password ssh-copy-id -i ~/.ssh/id_rsa.pub -p $puerto $usuario@$host || return_code=1;")
            else
                comando+=("ssh-copy-id -i ~/.ssh/id_rsa.pub -p $puerto $usuario@$host || return_code=1;")
            fi            
        done \
        && comando+=('exit $return_code') \
        && comando=("bash" "-c" "${comando[*]}") \
        && confirmar_comando "${comando[@]}"
    fi
}
