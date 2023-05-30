#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Variables globales compartidas con accion_51_habilitar_modo_examen
# USUARIO_EXAMEN y USUARIO_ALUMNO

function accion_52_deshabilitar_modo_examen() {
    local f
    local acciones
    declare -a opciones

    solicitar_hosts

    if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Paso 1 - Volver a permitir el uso del usuario alumnotd/alumnotv"
    then 
        opciones=(accion_24_desbloquear_usuario ON)

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

    if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Paso 2 - Se sugiere impedir el uso del usuario de examen"
    then
        opciones=(accion_22_finalizar_procesos_y_sesión_de_usuario ON accion_03_cambiar_contraseña ON accion_23_bloquear_usuario ON)

        local nOpciones
        nOpciones=$(altura_opciones_menu "${opciones[@]}")
        if acciones=$(dialogo_base --title "$(describe_accion "${FUNCNAME[0]}")" --checklist "Elige acciones" --noitem $(altura_menu $nOpciones) ${ANCHO_VENTANA} $nOpciones "${opciones[@]}" 3>&1 1>&2 2>&3)
        then
            if [[ "$acciones" != ' ' ]]; then
                # Sugerir valor por defecto, confirmar con usuario
                USUARIO_REMOTO="$USUARIO_EXAMEN"
                solicitar_usuario_remoto || return 1
                USUARIO_EXAMEN="$USUARIO_REMOTO"
            fi
            for f in $acciones
            do
                f="${f//\"/}"
                if dialogo "$(describe_accion "${FUNCNAME[0]}")" "Siguiente acción '$(describe_accion "$f")', ¿continuar?" "Continuar"; then
                    ejecutar "$f"
                fi
            done
        fi
    fi
}