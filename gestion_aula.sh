#!/bin/bash
source .config

set -u

# Variables globales
declare -a HOSTS=()
declare -a SHORT_OPTS=()
declare -a LONG_OPTS=()
RUTA_LOCAL=""
RUTA_REMOTA=""
USUARIO_REMOTO=""
PASS_USUARIO_REMOTO=""
SHORT_OPTS=("-l" "root" "-t" "$TIMEOUT" "${COMMON_OPTS[@]}")
TMP_DIR=$(mktemp -d)
TMP_STDOUT_DIR="${TMP_DIR}/stdout/"
TMP_STDERR_DIR="${TMP_DIR}/stderr/"
LONG_OPTS=("${SHORT_OPTS[@]}" "-o" "$TMP_STDOUT_DIR/" "-e" "$TMP_STDERR_DIR/")

function dialogo() {
    local mensaje
    local aceptar
    mensaje="$1"
    aceptar=${2:-Aceptar}

    # Si se quiere marcar por defecto Cancelar, añadir -s /^C
    smenu -d -2 "$aceptar" -1 ^C -s /"$aceptar" -x q 30 \
        -m "$mensaje"   \
        <<< "$aceptar Cancelar"
}

function confirmar_comando() {
    local return_code
    printf "Comando a ejecutar:\ncomando=( "
    printf "\"%s\" " "$@"
    printf ")\n"
    printf '${comando[@]}\n'

    confirmacion=$(dialogo "¿Continuar?")
    if [[ -z "$confirmacion" || "$confirmacion" == "Cancelar" ]]; then 
        echo -e "\nAcción cancelada"
        return_code=0
    else
        # Ejecutar comando y mostrarlo tal cual lo lanza bash
        set -x
        "$@"
        { return_code=$?; } 2>/dev/null
        { set +x; } 2>/dev/null
    fi
    return $return_code
}

function solicitar_password() {
    PASS_USUARIO_REMOTO=$(solicitar_cadena "Nueva contraseña: " "$PASS_USUARIO_REMOTO")
}

function solicitar_usuario_remoto() {
    USUARIO_REMOTO=$(solicitar_cadena "Usuario remoto: " "$USUARIO_REMOTO")
}

function solicitar_ruta_local() {
    RUTA_LOCAL=$(solicitar_cadena "Ruta local (TAB para autocompletar): " "$RUTA_LOCAL")
}

function solicitar_ruta_remota() {
    RUTA_REMOTA=$(solicitar_cadena "Ruta remota: " "$RUTA_REMOTA")
}

function solicitar_cadena() {
    local mensaje
    local valor_defecto
    local ruta
    mensaje="$1"
    valor_defecto="$2"

    # -e Permite autocompletar con tabulador, -i inserta un valor por defecto
    read -e -r -p "$mensaje" -i "$valor_defecto" ruta
    ruta=${ruta//\\/}
    #ruta=$(printf %q "$ruta")

    echo "$ruta"
}

function solicitar_hosts() {
    local start
    local hosts

    start=$(head -n 1 "$HOSTS_FILE" | sed 's/.*[^0-9]\(\d*\)/\1/')
    ((start--))
    hosts=$(sed -e '$aTodos' "$HOSTS_FILE" \
            | smenu -m 'Hosts (puedes marcar varios usando "t"): ' -d -s '#last' -a t:4,b c:4,bu ct:0/4,bu -T" " -p -N -D s:$start )
    if  [[ -z "$hosts" ]]; then
        exit 0
    fi
    echo "Hosts: $hosts"
    if [[ "$hosts" =~ "Todos" ]]; then
        HOSTS=("-h" "$HOSTS_FILE")
    else
        HOSTS=("-H" "$hosts")
    fi
}

function accion_09_ver_espacio_HD() {
    solicitar_hosts
    comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "df -h | egrep '/home$'")
    confirmar_comando "${comando[@]}"
}


function accion_10_ver_espacio_SSD() {
    solicitar_hosts
    comando=("parallel-ssh" "-i" "${SHORT_OPTS[@]}" "${HOSTS[@]}" "df -h | egrep '/home/hdssd$'")
    confirmar_comando "${comando[@]}"
}

function accion_18_copiar() {
    solicitar_ruta_local
    solicitar_ruta_remota
    solicitar_hosts
    comando=("parallel-scp" "${LONG_OPTS[@]}" "-r" "${HOSTS[@]}" "$RUTA_LOCAL" "$RUTA_REMOTA")
    confirmar_comando "${comando[@]}"
}

# TO-DO: Pendiente de comprobar
# function accion_19_sincronizar() {
#     solicitar_ruta_local
#     solicitar_ruta_remota
#     solicitar_hosts
#     comando=("parallel-rsync" "${LONG_OPTS[@]}" "-arv" "${HOSTS[@]}" "$RUTA_LOCAL" "$RUTA_REMOTA")
#     confirmar_comando "${comando[@]}"
# }

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

function accion_03_cambiar_contraseña() {
    solicitar_usuario_remoto
    solicitar_password
    solicitar_hosts
    comando_remoto=$(
        printf "echo %s:%s | chpasswd" \
               "$USUARIO_REMOTO" \
               "$PASS_USUARIO_REMOTO"
        )
    comando=("parallel-ssh" "${LONG_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto")
    confirmar_comando "${comando[@]}"
}

function main() {
    local accion
    local funcion
    local confirmacion

    if which smenu >/dev/null; then
        while true; do
            accion=$(
                    declare -F \
                    | grep "accion_" \
                    | sed 's/^declare -f accion_/\\t/' \
                    | sort -n -t_ -k1 \
                    | smenu -F -D f:no n:2 i:1 d:_ -c -d -n 20 -m "Elige una acción (pulsa q para salir):"
                )

            [[ -z $accion ]] && exit 0
            echo "Acción elegida: $accion"

            [[ "$accion" == [1-9]_* ]] && accion="0$accion"
            funcion="accion_$accion"

            if "$funcion"; then
                :; # Comando ejecutado sin errores o confirmación cancelada
            elif [[ -d "$TMP_STDERR_DIR" ]]; then
                confirmacion=$(dialogo "Hubo algunos errores, ¿mostrar en detalle?" "Mostrar")
                if [[ ! "$confirmacion" == "Cancelar" ]]; then 
                    echo "Detalle de errores:"
                    grep ".*" "$TMP_STDERR_DIR"/* 2> /dev/null | sed 's/.*stderr\/*//g'
                fi
            fi
            # Limpiar ficheros temporales
            rm -rf --preserve-root "$TMP_STDOUT_DIR" "$TMP_STDERR_DIR"
            echo
        done
    else
        echo "smenu no está instalado" 2>&1
    fi
}

if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    # Están ejecutando directamente este script, no importándolo con source
    main "$@"
fi

#  Filtrar fallidos
#  grep "FAILURE" prueba.log | sed 's/.* \[[A-Za-z]*\] \(\S*\).*/\1/' | tr '\n' ' '