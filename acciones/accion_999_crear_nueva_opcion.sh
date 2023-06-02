#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Sólo se define la función si se es root (no funciona con sudo)
[[ "$(id -u)" -eq 0 && -z "$SUDO_USER" ]] && function accion_999_crear_nueva_opción() {
    params=("Crear nueva opción" "Cúrratelo un poquito tú también, ¿no?" "Ver cómo") \
    && if dialogo "${params[@]}"; then
        firefox "https://github.com/javnitram/UTIL-gestion-aula#contribuir" &
        disown
    else
        yes "También puedes invitarme a un café o a una cerveza" | head -n 100
        return 255
    fi
}