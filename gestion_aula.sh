#!/bin/bash
# Importar configuración
source .config

# Importar funciones auxiliares y variables globales
source common.sh

# Importar funciones que implementan opciones de menú
for f in accion_*.sh; do
    source "$f"
done

# Provoca que el script termine si se usa una variable no declarada
set -u

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