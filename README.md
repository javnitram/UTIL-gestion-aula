# UTIL-gestion-aula
Script(s) de gestión de aula

## Dependencias
Requiere que los siguientes paquetes estén instalados:
* whiptail.
* pssh.

## Configuración
### Fichero de hosts
Fichero de texto con la relación de máquinas a gestionar. Una máquina por línea con sintaxis [user@]host[:port]

Por ejemplo:
* pc01:22001
* 192.168.1.11
* pacopena@pc01

Este fichero permite comentarios si la línea empieza por #. No se permiten comentarios al final de una línea.

### Fichero .config
Establece algunas constantes:
* *HOSTS_FILE*: Ruta al fichero anterior.
* *TIMEOUT*: Expirar tiempo de espera pasados este número de segundos. 0 para esperar indefinidamente.
* *COMMON_OPTS*: Array de cadenas con opciones para pasar a cualquiera de los comandos del paquete pssh que este script usa internamente.

## Mejoras futuras
* Actualmente no se permite incluir este script en el PATH.
* Verificar parallel-rsync.
* Verificar acción de actualización del script.
* ¿Habilitar una opción para generar fichero de hosts usando nmap o exportarlo de TCOS?
* ¿Resetear usuario examen? userdel -r y volver a crearlo con mismo home, UID, GID y grupos secundarios que tuvo originalmente.

## Contribuir
* Asegúrate de tener instaladas las dependencias, así como Vagrant y el entorno de pruebas del repositorio [javnitram/SIST-multi-vm](https://github.com/javnitram/SIST-multi-vm).
* Haz un fork de este proyecto.
* Haz una rama de desarrollo de tu funcionalidad (git checkout -b mi-nueva-funcionalidad).
* Tu funcionalidad puede utilizar cualquier variable global o función de los ficheros common.sh, .config o cualquier fichero accion_\*.sh. Familiarízate con algunas de las acciones ya implementadas.
* Implementa tu funcionalidad en un nuevo script con prefijo "accion_N_" y extensión ".sh". Dicho fichero deberá contener únicamente una función con prefijo "accion_N_" que siga el mismo patrón que las ya existentes, donde N es un número de uno o dos dígitos que establece el orden de opción en el menú. Si se cumple la nomenclatura, el script gestion-aula.sh mostrará correctamente esta nueva opción en el menú.
* Los ficheros accion_\*.sh no tienen por qué tener permisos de ejecución, no deben ser invocados de forma aislada.
* Haz pruebas usando el fichero "hosts-test.txt" con las máquinas virtuales configuradas en javnitram/SIST-multi-vm/Vagrantfile.
* Haz commit de tus cambios (git commit -am 'Funcionalidad implementada').
* Haz push a la rama (git push origin mi-nueva-funcionalidad).
* Haz un nuevo Pull Request.
