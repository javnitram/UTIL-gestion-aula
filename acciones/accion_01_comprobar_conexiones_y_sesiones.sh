#!/bin/bash
###############################################################################
# Script(s) de gestión de aula
# @author https://github.com/javnitram/
# GNU GENERAL PUBLIC LICENSE Version 3
# Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
###############################################################################

function accion_01_comprobar_conexiones_y_sesiones() {
    solicitar_hosts \
    && comando_remoto='echo "$(whoami)@$(hostname): 
    Tiempo encendido: $(uptime -p)
    Sesiones abiertas: $(users)
    Usuarios bloqueados: $(re=$(grep -v "nologin$" /etc/passwd | grep -v "false$" | awk -F: '\''{ if ($1 != "sync") { print $1 } }'\'' | tr "\n" "|") && re=${re%|} && passwd -aS | awk -v re="$re" '\''{ if (($1 ~ "^"re"$") && ($2=="L")) { print $1 } }'\'' | tr "\n" " ")"' \
    && comando=("parallel-ssh" -i "${SHORT_OPTS[@]}" "${HOSTS[@]}" "$comando_remoto") \
    && confirmar_comando "${comando[@]}"
}
