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
LONG_OPTS=("${SHORT_OPTS[@]}")
    TMP_DIR=$(mktemp -d)
    TMP_STDOUT_DIR="${TMP_DIR}/stdout/"
    TMP_STDERR_DIR="${TMP_DIR}/stderr/"
if ! which "$SHOW_ERRORS" > /dev/null; then
    # Configurado como dialogo, se guardan temporalmente algunas salidas
    LONG_OPTS+=("-o" "$TMP_STDOUT_DIR/" "-e" "$TMP_STDERR_DIR/")
elif "$SHOW_ERRORS"; then
    # configurado a true
    LONG_OPTS+=("-o" "$TMP_STDOUT_DIR/" "-i") # Mostrar errores inmediatamente
fi

# ... para solicitar (y recordar como predefinidos) valores indicados por el usuario
declare -a HOSTS=()
RUTA_LOCAL=""
RUTA_REMOTA=""
USUARIO_REMOTO=""
PASS_USUARIO_REMOTO=""
FILE_SELECTED="" # Ruta a fichero o a directorio

# Literales
BTN_ACEPTAR="Aceptar"
BTN_CANCELAR="Cancelar"
BACK_TITLE="Atrás"

MIN_ALTURA=25
MIN_ANCHO=80
ANCHO_VENTANA=78
## Set newt color palette for dialogs
NEWT_COLORS_0='
    root=,blue
'
NEWT_COLORS_1='
    root=,blue
    checkbox=,blue
    entry=,blue
    label=blue,
    helpline=,blue
    roottext=,blue
    emptyscale=blue
    disabledentry=blue,
    listbox=blue,
    actlistbox=,red
    sellistbox=blue,
    actsellistbox=,red
    textbox=blue
    acttextbox=,red
'
NEWT_COLORS_2='
    root=green,black
    border=green,black
    title=green,black
    roottext=white,black
    window=green,black
    textbox=white,black
    button=black,green
    compactbutton=white,black
    listbox=white,black
    actlistbox=black,white
    actsellistbox=black,green
    checkbox=green,black
    actcheckbox=black,green
'
NEWT_COLORS_3='
    root=white,black
    border=black,lightgray
    window=lightgray,lightgray
    shadow=black,gray
    title=black,lightgray
    button=black,cyan
    actbutton=white,cyan
    compactbutton=black,lightgray
    checkbox=black,lightgray
    actcheckbox=lightgray,cyan
    entry=black,lightgray
    disentry=gray,lightgray
    label=black,lightgray
    listbox=black,lightgray
    actlistbox=black,cyan
    sellistbox=lightgray,black
    actsellistbox=lightgray,black
    textbox=black,lightgray
    acttextbox=black,cyan
    emptyscale=,gray
    fullscale=,cyan
    helpline=white,black
    roottext=lightgrey,black
'
export NEWT_COLORS=$NEWT_COLORS_1

function dialogo_base() {
    comprueba_resolucion
    whiptail --ok-button "$BTN_ACEPTAR" --cancel-button "$BTN_CANCELAR" "$@"
}

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

function comprueba_resolucion() {
    local mensaje
    declare -a resolucion=($(fullscreen))  
    while [[ ${resolucion[0]} -lt $MIN_ALTURA || ${resolucion[1]} -lt $MIN_ANCHO ]]; do
        mensaje="$(cat << EOF
Resolución actual: $(echo ${resolucion[*]} | tr ' ' 'x') (mínima ${MIN_ALTURA}x${MIN_ANCHO})
El terminal tiene muy poco tamaño o la fuente es demasiado grande. Maximiza la ventana o reduce el tamaño de la fuente y pulsa ${BTN_ACEPTAR}
EOF
)
"
        if ! whiptail --title "Error" --yesno "$mensaje" --yes-button "${BTN_ACEPTAR}" --no-button "${BTN_CANCELAR}" "${resolucion[@]}"; then
            salir 1
        fi
        resolucion=($(fullscreen)) 
    done
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

    dialogo_base --title "$titulo" \
             --yesno "$mensaje" \
             --yes-button "$aceptar" \
             --no-button "${BTN_CANCELAR}" 12 ${ANCHO_VENTANA}
    return $?
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
    dialogo_base --title "$(describe_accion "${FUNCNAME[1]}")" --menu "$mensaje" $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones \
        "${opciones[@]}"  3>&2 2>&1 1>&3
    return $?
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
        return_code=1
    fi
    return $return_code
}

function es_anidamiento_de_acciones() {
    [[ ${FUNCNAME[*]} == *"accion_"*"accion_"* ]]
}

function dialogo_password_oculto() {
    dialogo_base --title "$(describe_accion "${FUNCNAME[1]}")" --passwordbox "Introduce contraseña (texto oculto)" 8 ${ANCHO_VENTANA} --title "Contraseña común para conexiones remotas" 3>&1 1>&2 2>&3
    return $?
}

function solicitar_password() {
    if ! es_anidamiento_de_acciones || [ -z "$PASS_USUARIO_REMOTO" ] ; then
        PASS_USUARIO_REMOTO=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Nueva contraseña (texto visible): " "$PASS_USUARIO_REMOTO")
    fi
    [ -n "$PASS_USUARIO_REMOTO" ]
}

function solicitar_usuario_remoto() {
    if ! es_anidamiento_de_acciones || [ -z "$USUARIO_REMOTO" ]; then
        USUARIO_REMOTO=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Usuario remoto: " "$USUARIO_REMOTO")
        echo "Usuario remoto: $USUARIO_REMOTO"
    fi
    [ -n "$USUARIO_REMOTO" ]
}

# function solicitar_ruta_local() {
#     RUTA_LOCAL=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Ruta local: " "$RUTA_LOCAL")
#     echo "Ruta local: $RUTA_LOCAL"
#     [ -n "$RUTA_LOCAL" ]
# }

function solicitar_ruta_remota() {
    if ! es_anidamiento_de_acciones || [ -z "$RUTA_REMOTA" ]; then
        RUTA_REMOTA=$(solicitar_cadena "$(describe_accion "${FUNCNAME[1]}")" "Ruta remota: " "$RUTA_REMOTA")
        echo "Ruta remota: $RUTA_REMOTA"
    fi
    [ -n "$RUTA_REMOTA" ]
}

function solicitar_cadena() {
    local mensaje
    local valor_defecto
    local cadena
    titulo="$1"
    mensaje="$2"
    valor_defecto="$3"

    cadena=$(dialogo_base --inputbox "$mensaje" 8 ${ANCHO_VENTANA} "$valor_defecto" --title "$titulo" 3>&1 1>&2 2>&3)
    # Quitamos las secuencias de escape con '\'
    # porque la cadena se utilizará siempre entre comillas dobles, que también 
    # evitan problemas al interpretar los espacios en blanco.
    cadena=${cadena//\\/}

    # Si se prefiere escapar caracteres especiales, podemos usar la siguiente
    # instrucción
    #cadena=$(printf %q "$cadena")

    echo "$cadena"
    [ -n "$RUTA_REMOTA" ]
}

function leer_fichero_hosts() {
    grep -v '^\s*#' "$1"
}

function solicitar_hosts() {
    if ! es_anidamiento_de_acciones || [ -z "$HOSTS" ]; then
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
        local nOpciones
        nOpciones=$(altura_opciones_menu "${opciones[@]}")
        if hosts=$(dialogo_base --title "$(describe_accion "${FUNCNAME[1]}")" --checklist "Elige hosts" --noitem $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones "${opciones[@]}" 3>&1 1>&2 2>&3)
        then
            hosts="$(tr '\n' ' ' <<< "$hosts")"
            hosts="$(tr '"' ' ' <<< "$hosts")"
            hosts=${hosts:-Todos}
            echo "Hosts: $hosts"
            if [[ "$hosts" == ' ' || "$hosts" =~ "Todos" ]]; then
                HOSTS=("-h" "$HOSTS_FILE")
            else
                HOSTS=("-H" "$hosts")
            fi
        else
            return 1
        fi
    fi
}


# ----------------------------------------------------------------------
#  File selection dialog
#
#  Arguments
#     1  Dialog title
#     2  Source path to list files and directories
#     3  File mask (by default *)
#     4  "yes" to allow go back in the file system.
#
#  Returns
#     0  if a file was selected and loads the FILE_SELECTED variable 
#        with the selected file.
#     1  if the user cancels.
#  @see https://stackoverflow.com/a/56587674
# ----------------------------------------------------------------------
function dr_file_select
{
    local TITLE=${1:-$MSG_INFO_TITLE}
    local LOCAL_PATH="${2:-$(pwd)}/"
    LOCAL_PATH=$(echo "$LOCAL_PATH" | tr -s /)
    local FILE_MASK=${3:-"*"}
    local ALLOW_BACK=${4:-no}
    local FILES=()
    FILES+=("." "actual")
    [ "$ALLOW_BACK" != "no" ] && FILES+=(".." "atrás")

    # First add folders
    for DIR in $(find $LOCAL_PATH -maxdepth 1 -mindepth 1 -type d -printf "%f " 2> /dev/null | sort )
    do
        FILES+=("${DIR}/" "dir")
    done

    # Then add the files
    for FILE in $(find $LOCAL_PATH -maxdepth 1 -type f -name "$FILE_MASK" -printf "%f %s " 2> /dev/null | sort)
    do
        FILES+=("$FILE")
    done

    while true
    do
        local nOpciones
        nOpciones=$(altura_opciones_menu "${FILES[@]}")
        FILE_SELECTED=$(
            dialogo_base --clear \
                    --backtitle "$BACK_TITLE" \
                    --title "$TITLE" \
                    --menu "Explorando $LOCAL_PATH" \
                    $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones ${FILES[@]} \
                    3>&1 1>&2 2>&3 \
                )

        if [ -z "$FILE_SELECTED" ]; then
            return 1
        else
            if  [ "$FILE_SELECTED" = "." ]; then
                FILE_SELECTED="$LOCAL_PATH"
                return 0
            elif [ "$FILE_SELECTED" = ".." ] && [ "$ALLOW_BACK" != "no" ]; then
                return 0

            elif [ -d "$LOCAL_PATH/$FILE_SELECTED" ] ; then
                if dr_file_select "$TITLE" "$LOCAL_PATH/$FILE_SELECTED" "$FILE_MASK" "yes" ; then
                    if [ "$FILE_SELECTED" != ".." ]; then
                        return 0
                    fi
                else
                    return 1
                fi

            elif [ -f "$LOCAL_PATH/$FILE_SELECTED" ] ; then
                FILE_SELECTED="$LOCAL_PATH/$FILE_SELECTED"
                return 0
            fi
        fi
    done
}

function solicitar_ruta_local() {
    if ! es_anidamiento_de_acciones || [ -z "$RUTA_LOCAL" ]; then
        if dr_file_select "$(describe_accion "${FUNCNAME[1]}")" "/" '*' "yes" ; then
                RUTA_LOCAL="$FILE_SELECTED"
                echo "Ruta local: $RUTA_LOCAL"
        fi
    fi
    [ -n "$RUTA_LOCAL" ]
}

function ejecutar() {
    local funcion
    funcion="$1"
    if "$funcion"; then
        echo "Acción '$(describe_accion "$funcion")' completada con éxito"
        confirmar_continuacion_asistente
    elif [[ -d "$TMP_STDERR_DIR" ]]; then
        echo "Acción '$(describe_accion "$funcion")' completada. Todas las conexiones cerradas, hubo uno o varios errores"
        which "$SHOW_ERRORS" > /dev/null || confirmar_continuacion_asistente
        # Esta ruta existe si ha habido errores y el comando se lanzó con opción -e <dir>
        # para redirigir errores a un fichero por cada conexión
        params=("$(describe_accion "$funcion")" "Hubo uno o varios errores, pueden verse en la traza del terminal\n¿Mostrar?" "Mostrar") 
        if "$SHOW_ERRORS" "${params[@]}"; then 
            echo "Detalle de errores:"
            # Mostramos errores, para ello usamos grep que, cuando recibe
            # varios ficheros, identifica en cada línea el nombre del fichero
            # que la contiene
            # A continuación dejamos únicamente el nombre del fichero (sin el
            # directorio padre), dicho nombre identifica la conexión
            # que produjo fallos
            grep ".*" "$TMP_STDERR_DIR"/* 2> /dev/null | sed 's/.*stderr\/*//g'
            confirmar_continuacion_asistente
        fi
    else
        echo "Acción '$(describe_accion "$funcion")' cancelada por el usuario o completada con posibles errores, revisar la traza anterior"
        confirmar_continuacion_asistente
    fi
    # Limpiar ficheros temporales
    rm -rf --preserve-root "$TMP_STDOUT_DIR" "$TMP_STDERR_DIR"
    echo
}