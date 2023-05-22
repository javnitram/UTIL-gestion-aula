#!/bin/bash
function accion_99_actualizar_script() {
    local script_dir
    script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    pushd "$script_dir" || exit 1
    if git diff --exit-code main origin/main > /dev/null; then
        popd || exit 1
    else
        git pull
        exit 0
    fi
    
}