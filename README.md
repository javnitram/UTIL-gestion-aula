# UTIL-gestion-aula
Script(s) de gestión de aula

## Dependencias
Requiere instalar:
* smenu (probado con 0.9.15-1 amd64 en Ubuntu 20.04 con WSL).
* pssh (probado con 2.3.1-2 all en Ubuntu 20.04 con WSL).

## Configuración
### Fichero de hosts
Fichero de texto con la relación de máquinas a gestionar. Una máquina por línea con sintaxis [user@]host[:port]
Por ejemplo:
* pc01:22001
* 192.168.1.11
* pacopena@pc01

### Fichero .config
Establece algunas constantes:
* *HOSTS_FILE*: Ruta al fichero anterior.
* *TIMEOUT*: Expirar tiempo de espera pasados este número de segundos. 0 para esperar indefinidamente.
* *COMMON_OPTS*: Array de cadenas con opciones para pasar a cualquiera de los comandos del paquete pssh que este script usa internamente.

## Mejoras futuras
* Actualmente no se permite incluir este script en el PATH.
* Verificar parallel-rsync.
* ¿Habilitar una opción para generar fichero de hosts usando nmap?

## Contribuir
* Asegúrate de tener instaladas las dependencias, así como Vagrant y el entorno de pruebas del repositorio [javnitram/SIST-multi-vm](https://github.com/javnitram/SIST-multi-vm).
* Haz un fork de este proyecto.
* Haz una rama de desarrollo de tu funcionalidad (git checkout -b mi-nueva-funcionalidad).
* Implementa tu funcionalidad en el script como una nueva función con prefijo "accion_N_" que siga el mismo patrón que las ya existentes, donde N es un número de uno o dos dígitos que establece el orden de opción en el menú.
* Haz pruebas usando el fichero "hosts-test.txt" con las máquinas virtuales configuradas en javnitram/SIST-multi-vm/Vagrantfile.
* Haz commit de tus cambios (git commit -am 'Funcionalidad implementada').
* Haz push a la rama (git push origin mi-nueva-funcionalidad).
* Haz un nuevo Pull Request.
