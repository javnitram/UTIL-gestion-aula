#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Variables globales...
# ... para configurar algunos parámetros de comandos parallel-*
declare -a SHORT_OPTS=()
declare -a LONG_OPTS=()
SHORT_OPTS=("-l" "root" "-t" "$TIMEOUT" "${COMMON_OPTS[@]}")
TMP_DIR=$(mktemp -d)
TMP_STDOUT_DIR="${TMP_DIR}/stdout/"
TMP_STDERR_DIR="${TMP_DIR}/stderr/"
LONG_OPTS=("${SHORT_OPTS[@]}" "-o" "$TMP_STDOUT_DIR/" "-e" "$TMP_STDERR_DIR/")

# ... para solicitar (y recordar como predefinidos) valores indicados por el usuario
declare -a HOSTS=()
RUTA_LOCAL=""
RUTA_REMOTA=""
USUARIO_REMOTO=""
PASS_USUARIO_REMOTO=""

# Literales
BTN_ACEPTAR="Aceptar"
BTN_CANCELAR="Cancelar"

ANCHO_VENTANA=78
# export NEWT_COLORS="
# root=,blue
# roottext=white,blue"

function salir() {
    printf '\nSaliendo\n'
    read -st 1 -n 1000000
    [[ $# -gt 0 ]] && exit $1
    exit 0
}

function confirmar_continuacion_asistente() {
    # Establece el modo de edición de línea como "emacs"
    set -o emacs
    # Asigna algunos atajos
    bind '"\C-w": kill-whole-line' # Ctrl + W limpia línea completa
    bind '"\e": "\C-w\C-d"' # Escape envía Ctrl + W y Ctrl + D
    bind '"\e\e": "\C-w\C-d"' # Escape + Escape hace lo mismo
    IFS= read -n1 -s -rep "Pulsa ENTER para seguir en el asistente o ESCAPE para salir" || {
        # Control + D cierra stdin y produce que read acabe con error, entrando en este bloque
        salir 0
    }
    set +o emacs
    echo
}

function fullscreen() {
    stty size
}

function altura_opciones_menu() {
    echo $(($# / 2))
}

function altura_opciones_checkbox() {
    echo $(($# / 3))
}

function altura_dialogo() {
    local longitud_mensaje
    local n_saltos_linea
    longitud_mensaje=${#1}
    n_saltos_linea=$(contar_saltos_linea "$1")
    echo $((longitud_mensaje / ANCHO_VENTANA + n_saltos_linea + 4))
}

function altura_menu() {
    local nOpciones
    nOpciones=0
    [[ $# -gt 0 ]] && nOpciones="$1"
    echo $((nOpciones + 8))
}

function contar_saltos_linea() {
    tr -cd '\n' <<< "$*" | wc -c
}

function describe_accion() {
    # Se espera el nombre de la función que implementa la acción
    # con formato accion_N_texto_descriptivo
    # para devolver "Texto descriptivo"
    cut -d_ -f3- <<< "$1" | tr '_' ' ' | sed -e "s/^\(.\)/\u\1/g"
}

function dialogo() {
    local titulo
    local mensaje
    local aceptar
    titulo="$1"
    mensaje="$2"
    aceptar=""
    [[ $# -ge 3 ]] && aceptar="$3"
    [[ -z "$aceptar" ]] && aceptar="$BTN_ACEPTAR"

    whiptail --title "$titulo" \
             --yesno "$mensaje" \
             --yes-button "$aceptar" \
             --no-button "${BTN_CANCELAR}" 12 ${ANCHO_VENTANA}
}

function dialogo_n_opciones() {
    local mensaje
    mensaje="$1"
    shift
    opciones=()
    for i in "$@"
    do
        opciones+=("$i" "")
    done

    local nOpciones
    nOpciones=$(altura_opciones_menu "${opciones[@]}")
    whiptail --title "$(describe_accion "${FUNCNAME[1]}")" --menu "$mensaje" $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones \
        "${opciones[@]}"  3>&2 2>&1 1>&3
}

function confirmar_comando() {
    local return_code
    mensaje=("Comando a ejecutar:\ncomando=( ")
    mensaje+=($(printf "\"%s\" " "$@"))
    mensaje+=(")\n")
    mensaje+=('${comando[@]}\n')
    mensaje+=('¿Continuar?\n')

    if dialogo "$(describe_accion "${FUNCNAME[1]}")" "${mensaje[*]}"; then 
        # Ejecutar comando y mostrarlo tal cual lo lanza bash
        # Para ello ponemos temporalmente el modo debug con set -x
        # "$@" se expande a una lista de parámetros entrecomillados,
        # es decir, "$1" "$2" ... cada uno se trata de forma 
        # independiente y se evitan problemas con espacios en blanco 
        set -x
        "$@"
        { return_code=$?; } 2>/dev/null
        { set +x; } 2>/dev/null
    else
        echo -e "\nAcción cancelada"
        return_code=0
    fi
    return $return_code
}

function dialogo_password_oculto() {
    whiptail --title "$(describe_accion "${FUNCNAME[1]}")" --passwordbox "Introduce contraseña (texto oculto)" 8 78 --title "Contraseña común para conexiones remotas" 3>&1 1>&2 2>&3
}

function solicitar_password() {
    PASS_USUARIO_REMOTO=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Nueva contraseña (texto visible): " "$PASS_USUARIO_REMOTO")
}

function solicitar_usuario_remoto() {
    USUARIO_REMOTO=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Usuario remoto: " "$USUARIO_REMOTO")
    echo "Usuario remoto: $USUARIO_REMOTO"
}

function solicitar_ruta_local() {
    RUTA_LOCAL=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Ruta local: " "$RUTA_LOCAL")
    echo "Ruta local: $RUTA_LOCAL"
}

function solicitar_ruta_remota() {
    RUTA_REMOTA=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Ruta remota: " "$RUTA_REMOTA")
    echo "Ruta remota: $RUTA_REMOTA"
}

function solicitar_cadena() {
    local mensaje
    local valor_defecto
    local cadena
    titulo="$1"
    mensaje="$2"
    valor_defecto="$3"

    cadena=$(whiptail --inputbox "$mensaje" 8 78 "$valor_defecto" --title "$titulo" 3>&1 1>&2 2>&3)
    # Quitamos las secuencias de escape con '\'
    # porque la cadena se utilizará siempre entre comillas dobles, que también 
    # evitan problemas al interpretar los espacios en blanco.
    cadena=${cadena//\\/}

    # Si se prefiere escapar caracteres especiales, podemos usar la siguiente
    # instrucción
    #cadena=$(printf %q "$cadena")

    echo "$cadena"
}

function leer_fichero_hosts() {
    grep -v '^\s*#' "$1"
}

function solicitar_hosts() {
    local start
    local hosts

    # Identifica el número más bajo de la lista de hosts
    # para calcular los números de opción que propondrá el menú
    start=$(leer_fichero_hosts "$HOSTS_FILE" | sort | head -n 1 | sed 's/.*[^0-9]\(\d*\)/\1/')
    start=$((start%1000))
    opciones=("Todos" OFF)
    for i in $(leer_fichero_hosts "$HOSTS_FILE")
    do
        opciones+=("$i" OFF)
    done
    hosts=$(whiptail --title "$(describe_accion "${FUNCNAME[1]}")" --checklist "Elige hosts" --noitem $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones "${opciones[@]}" 3>&1 1>&2 2>&3)
    hosts="$(tr '\n' ' ' <<< $hosts)"
    hosts="$(tr '"' ' ' <<< $hosts)"
    hosts=${hosts:-Todos}
    echo "Hosts: $hosts"
    if [[ "$hosts" == ' ' || "$hosts" =~ "Todos" ]]; then
        HOSTS=("-h" "$HOSTS_FILE")
    else
        HOSTS=("-H" "$hosts")
    fi
}