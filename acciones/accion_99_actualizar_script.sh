#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

# Sólo se define la función si se es root (no funciona con sudo)
[ "$EUID" -eq 0 ] && function accion_99_actualizar_script() {
    local script_dir
    script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd "$script_dir" || exit 1
    git stash
    git pull
    git stash apply
    exit 0   
}