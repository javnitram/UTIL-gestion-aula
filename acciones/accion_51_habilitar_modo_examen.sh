#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Variables globales a compartir con accion_52_deshabilitar_modo_examen
# Valores por defecto, se solicitarán al usuario de forma interactiva
USUARIO_EXAMEN="examen1"
USUARIO_ALUMNO="alumnotd"

function accion_51_habilitar_modo_examen() {
    local f
    local acciones
    declare -a opciones

    solicitar_hosts

    if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Paso 1 - Se sugiere impedir el uso del usuario alumnotd/alumnotv"
    then 
        opciones=(accion_23_bloquear_usuario ON accion_22_finalizar_procesos_y_sesión_de_usuario ON)

        local nOpciones
        nOpciones=$(altura_opciones_menu "${opciones[@]}")
        if acciones=$(dialogo_base --title "$(describe_accion "${FUNCNAME[0]}")" --checklist "Elige acciones" --noitem $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones "${opciones[@]}" 3>&1 1>&2 2>&3)
        then
            if [[ "$acciones" != ' ' ]]; then
                # Sugerir valores por defecto, confirmar con usuario
                USUARIO_REMOTO="$USUARIO_ALUMNO"
                solicitar_usuario_remoto || return 1
                USUARIO_ALUMNO="$USUARIO_REMOTO"
            fi
            for f in $acciones
            do
                f="${f//\"/}"
                # Las acciones anidadas no deberían volver a solicitar valores ya asignados
                if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Siguiente acción '$(describe_accion "$f")', ¿continuar?" "Continuar"; then
                    ejecutar "$f"
                fi
            done
        fi
    fi

    if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Paso 2 - Se sugiere forzar el uso del usuario examen1/examen2 con permisos controlados:"
    then
        opciones=(accion_18_copiar ON accion_03_cambiar_contraseña ON accion_20_dar_permisos ON)

        local nOpciones
        nOpciones=$(altura_opciones_menu "${opciones[@]}")
        if acciones=$(dialogo_base --title "$(describe_accion "${FUNCNAME[0]}")" --checklist "Elige acciones" --noitem $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones "${opciones[@]}" 3>&1 1>&2 2>&3)
        then
            if [[ "$acciones" != ' ' ]]; then
                # Sugerir valor por defecto, confirmar con usuario
                USUARIO_REMOTO="$USUARIO_EXAMEN"
                solicitar_usuario_remoto || return 1
                USUARIO_EXAMEN="$USUARIO_REMOTO"
                PASS_USUARIO_REMOTO=""
            fi
            for f in $acciones
            do
                f="${f//\"/}"
                if [[ "$f" == "accion_18_copiar" ]]; then
                    RUTA_LOCAL=""
                    solicitar_ruta_local || return 1
                    RUTA_REMOTA="/home/${USUARIO_REMOTO}/Escritorio/"
                    solicitar_ruta_remota || return 1
                fi
                if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Siguiente acción '$(describe_accion "$f")', ¿continuar?" "Continuar"; then
                    ejecutar "$f"
                fi
            done
        fi
    fi
    dialogo "$(describe_accion "${FUNCNAME[0]}")" "Al finalizar el examen recuerda:\n (1) desbloquear el usuario '$USUARIO_ALUMNO' y \n (2) cambiar la contraseña del usuario '$USUARIO_EXAMEN'\n\nPara ello, puedes utilizar la acción Deshabilitar modo examen"
}