#!/bin/bash
# Importar configuración
source .config

# Importar funciones que implementación acciones
for f in accion_*.sh; do
    source "$f"
done

# Provoca que el script termine si se usa una variable no declarada
set -u

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

function dialogo() {
    local mensaje
    local aceptar
    mensaje="$1"
    aceptar=${2:-Aceptar}

    # Si se quiere marcar por defecto Cancelar, usar -s /Cancelar
    smenu -d -2 "$aceptar" -1 Cancelar -s /"$aceptar" -x q 30 \
        -m "$mensaje"   \
        <<< "$aceptar Cancelar"
}

function dialogo_n_opciones() {
    local mensaje
    mensaje="$1"
    shift
    
    smenu -d -1 Cancelar -s /Cancelar -x q 30 \
        -m "$mensaje"   \
        <<< "$* Cancelar"
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
        # Para ello ponemos temporalmente el modo debug con set -x
        # "$@" se expande a una lista de parámetros entrecomillados,
        # es decir, "$1" "$2" ... cada uno se trata de forma 
        # independiente y se evitan problemas con espacios en blanco 
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
    local cadena
    mensaje="$1"
    valor_defecto="$2"

    # -e Permite autocompletar con tabulador, -i inserta el $valor_defecto recibido
    read -e -r -p "$mensaje" -i "$valor_defecto" cadena
    # Autocompletar puede escapar espacios con '\ ', pero los quitamos
    # porque la cadena se utilizará siempre entre comillas dobles, que también 
    # evitan problemas al interpretar los espacios en blanco.
    cadena=${cadena//\\/}

    # Si se prefiere escapar caracteres especiales, podemos usar la siguiente
    # instrucción
    #cadena=$(printf %q "$cadena")

    echo "$cadena"
}

function mostrar_hosts_fichero() {
    grep -v '^\s*#' "$1"
}

function solicitar_hosts() {
    local start
    local hosts

    # Identifica el número más bajo de la lista de hosts
    # para calcular los números de opción que propondrá smenu
    start=$(mostrar_hosts_fichero "$HOSTS_FILE" | sort | head -n 1 | sed 's/.*[^0-9]\(\d*\)/\1/')
    start=$((start%100))
    hosts=$( (mostrar_hosts_fichero "$HOSTS_FILE" | sort && echo 'Todos') \
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

            # Rellenar 0 por la izquierda, si necesario
            [[ "$accion" == [0-9]_* ]] && accion="0$accion"
            # Identificar función que implementa la acción a ejecutar
            funcion="accion_$accion"

            if "$funcion"; then
                :; # Función ejecutada sin errores o cancelada
            elif [[ -d "$TMP_STDERR_DIR" ]]; then
                # Esta ruta existe si ha habido errores y el comando se lanzó con opción -e <dir>
                # para redirigir errores a un fichero por cada conexión
                confirmacion=$(dialogo "Hubo algunos errores, ¿mostrar en detalle?" "Mostrar")
                if [[ ! "$confirmacion" == "Cancelar" ]]; then 
                    echo "Detalle de errores:"
                    # Mostramos errores, para ello usamos grep que, cuando recibe
                    # varios ficheros, identifica en cada línea el nombre del fichero
                    # que la contiene
                    # A continuación dejamos únicamente el nombre del fichero (sin el
                    # directorio padre), dicho nombre identifica la conexión
                    # que produjo fallos
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