#!/bin/bash
function accion_99_actualizar_script() {
    local script_dir
    script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd "$script_dir" || exit 1
    git pull
    exit 0   
}