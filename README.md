[Ver como presentación](https://javnitram.github.io/UTIL-gestion-aula/)

# gestion-aula.sh
## Herramienta de gestión del aula

Javier Martín

IES El Cañaveral

# Índice de Contenidos

- [Dependencias](#dependencias)
- [Clonar repositorio](#clonar-repositorio)
- [Pruebas](#pruebas)
  - [Recomendaciones](#recomendaciones)
  - [Desplegar entorno de test](#desplegar-entorno-de-test)
  - [Máquinas virtuales del entorno de test](#máquinas-virtuales-del-entorno-de-test)
  - [Usando el script en el entorno virtualizado de test](#usando-el-script-en-el-entorno-virtualizado-de-test)
  - [Destruir el entorno de test](#destruir-el-entorno-de-test)


- [Configuración inicial](#configuración-inicial)
  - [Fichero de hosts](#fichero-de-hosts)
  - [Fichero _.config_](#fichero-config)
    - [Fichero _.config_ (entorno de test)](#fichero-config-entorno-de-test)
    - [Fichero _.config_ (entorno de producción)](#fichero-config-entorno-de-producción)
  - [Configuración SSH](#configuración-ssh)


- [Conociendo la interfaz de usuario](#conociendo-la-interfaz-de-usuario)
  - [Comprobación de resolución](#comprobación-de-resolución)
  - [Uso de menús](#uso-de-menús)
  - [Selección de hosts](#selección-de-hosts)
  - [ Solicitud de usuario remoto](#solicitud-de-usuario-remoto)
  - [ Explorador de ficheros locales](#explorador-de-ficheros-locales)
  - [ Solicitud de ruta remota](#solicitud-de-ruta-remota)
  - [ Solicitud de contraseña visible](#solicitud-de-contraseña-visible)
  - [ Solicitud de contraseña oculta](#solicitud-de-contraseña-oculta)
  - [ Confirmar ejecución de comando](#confirmar-ejecución-de-comando)
  - [Revisar traza de ejecución y seguir](#revisar-traza-de-ejecución-y-seguir-o-salir)


- [Acciones exclusivas del modo root](#acciones-exclusivas-del-modo-root)
  - [Escanear hosts SSH](#escanear-hosts-ssh)
  - [Generar clave y copiar](#generar-clave-y-copiar)
  - [Actualizar script](#actualizar-script)

- [Acciones disponibles en modo _sudo_](#acciones-disponibles-en-modo-sudo)
  - [Comprobar conexiones y sesiones](#comprobar-conexiones-y-sesiones)
  - [Salir](#salir)
  - [Cambiar contraseña](#cambiar-contraseña)
  - [Ver espacio disco](#ver-espacio-disco)
  - [Ver espacio ocupado por usuarios](#ver-espacio-ocupado-por-usuarios)
  - [Opciones apagado](#opciones-apagado)
  - [Copiar](#copiar)
  - [Dar permisos](#dar-permisos)
  - [Quitar permisos](#quitar-permisos)
  - [Finalizar procesos y sesión de usuario](#finalizar-procesos-y-sesión-de-usuario)
  - [Bloquear usuario](#bloquear-usuario)
  - [Desbloquear usuario](#desbloquear-usuario)
  - [Ejecutar como usuario](#ejecutar-como-usuario)


- [Acciones para gestionar exámenes](#acciones-para-gestionar-exámenes)
  - [Habilitar modo examen](#habilitar-modo-examen)
  - [Deshabilitar modo examen](#deshabilitar-modo-examen)


# Dependencias


- Entorno real de aula:
  - [Linux Max](https://www.educa2.madrid.org/web/max)
  - [Paquete pssh (parallel-ssh y similares)](https://www.server-world.info/en/note?os=Ubuntu_20.04&p=ssh&f=10)
  - [Paquete whiptail](https://howtoinstall.co/en/whiptail)
  - [Git](https://www.digitalocean.com/community/tutorials/how-to-install-git-on-ubuntu-22-04)

- Entorno de desarrollo o pruebas:
  - Todos los anteriores, excepto Linux.
  - Se virtualizarían varios puestos como si fuera la red de un aula, usaríamos:
    - [VirtualBox](https://www.virtualbox.org/)
    - [Vagrant](https://www.vagrantup.com/)

En las aulas Linux del centro ya está todo instalado.



# Clonar repositorio


La última versión de este proyecto está publicada como repositorio Git.

Debe clonarse con la opción _--recurse-submodules_ si se quieren realizar tests.

```bash
git clone https://www.github.com/javnitram/UTIL-gestion-aula.git --recurse-submodules
```

En el directorio de trabajo, se creará el directorio `UTIL-gestion-aula` con los scripts, entre otras cosas.



# Pruebas


## Recomendaciones

El proyecto clonado sería plenamente funcional una vez configurado en un aula, pero se recomienda a los nuevos usuarios que se familiaricen con la herramienta en un entorno de pruebas completamente virtualizado y ya preparado en el mismo proyecto.


## Desplegar entorno de test

La primera vez instalaremos un plugin de `Vagrant`:

```bash
vagrant plugin install vagrant-useradd
```

A continuación, instanciar las máquinas virtuales del entorno. Para ello:

```bash
cd UTIL-gestion-aula
cd SIST-multi-vm
vagrant up
```

En la primera ejecución se descargará una vagrant-box de Debian 11 (equivalente a una OVA). Las siguientes veces esta box estará disponible en local.

## Máquinas virtuales del entorno de test

Una vez finalice el comando _vagrant up_ dispondremos de los siguientes recursos virtualizados:

| Host   | Dirección IP   |
| ------ | -------------- |
| profe  | 192.168.56.250 |
| pc01   | 192.168.56.21  |
| pc02   | 192.168.56.22  |
| pc03   | 192.168.56.23  |

Estas máquinas estarían corriendo en segundo plano sin interfaz gráfica, pero serían accesibles desde VirtualBox (no es necesario abrirlas).


Todos los hosts tendrán usuarios root y vagrant creados con contraseña "vagrant". Además, todos pertenecen a la red 192.168.56.0/24.

Por otra parte, los puestos de alumno (aquellos con prefijo pc) tendrán creados los usuarios alumnotd, alumnotv, examen1, examen2, ... Todos inicialmente bloqueados.

La máquina virtual **profe** comparte en la ruta ```/UTIL-gestion-aula``` el proyecto clonado con git anteriormente. Desde ahí podremos probar los scripts de esta herramienta.


Los detalles de implementación de este entorno virtualizado pueden encontrarse en el fichero _Vagrantfile_ del directorio ```SIST-multi-vm```.

## Usando el script en el entorno virtualizado de test

En el directorio ```SIST-multi-vm```, accederemos a la máquina virtual **profe** de este modo:

```bash
vagrant ssh profe
```

En este punto, podemos configurar y probar la herramienta siguiendo otras secciones de esta documentación.


## Destruir el entorno de test

Una vez hayamos concluido nuestras pruebas o siempre que queramos empezar de cero, podremos eliminar las máquinas virtuales de este entorno. En el directorio ```SIST-multi-vm``` ejecutaremos:

```bash
vagrant destroy -f
```

Esta acción apaga y elimina las máquinas virtuales creadas por Vagrant en VirtualBox.



# Configuración inicial


## Fichero de hosts

Esta herramienta necesita un fichero de texto con la relación de máquinas a gestionar. Una máquina por línea con sintaxis ```[user@]host[:port]```.

Por ejemplo:

```text
    pc01:22001
    192.168.1.11
    pacopena@pc01
```

**Tanto en el entorno de pruebas como en el real, pondremos sólo una dirección IP por línea.**

Este fichero permite comentarios si la línea empieza por #. No se permiten comentarios al final de una línea.


En el entorno de test, se proporciona un fichero en ```SIST-multi-vm/hosts-test.txt``` con las direcciones de los puestos de alumno virtualizados. Además, se incluye la dirección 192.168.56.24, no asignada a ningún host, para observar mensajes de error en la herramienta.

En el entorno real de aula, se podrá hacer uso del fichero ```/home/madrid/Escritorio/scripts2022/lista-ips.txt```.

## Fichero _.config_

Establece algunas constantes:

- **HOSTS_FILE**: Ruta al fichero anterior.
- **TIMEOUT**: Expirar tiempo de espera pasados este número de segundos. 0 para esperar indefinidamente.
- **COMMON_OPTS**: Array de cadenas con opciones para pasar a cualquiera de los comandos del paquete pssh que este script usa internamente.
- **SHOW_ERRORS**: Comportamiento por defecto cuando haya errores al ejecutar un comando en un host (_true_ muestra siempre; _false_, solo a veces; _dialogo_, sin tilde, pregunta antes).


### Fichero _.config_ (entorno de test)

El proyecto clonado está configurado para usar las direcciones IP de las máquinas virtuales del entorno de prueba.

```bash
# TEST
readonly HOSTS_FILE="SIST-multi-vm/hosts-test.txt"
readonly TIMEOUT=0
declare -a COMMON_OPTS=()
readonly SHOW_ERRORS=false # true muestra siempre; false, solo a veces; dialogo, pregunta antes. 
```

No es necesario editarlo para hacer pruebas, sólo en el aula real.


### Fichero _.config_ (entorno de producción)

En un entorno de aula real, es necesario editar el fichero _.config_. Se recomienda comentar con el carácter inicial **#** las líneas bajo  **" TEST"** y hacer la configuración oportuna bajo el comentario **"PROD"**.



## Configuración SSH

Es necesario configurar el acceso remoto desde el puesto de profe a los de los alumnos para que no pidan contraseña de root, de modo que la herramienta pueda ejecutar sus comandos de gestión sobre los puestos definidos en el [fichero de hosts](#fichero-de-hosts).


Esta configuración es importante hacerla desde una consola de root. Para ello, podemos lanzar el script de este modo:

```bash
su - root
cd /UTIL-gestion-aula
./gestion-aula.sh
```

En el entorno de pruebas, la contraseña de _root_ es _vagrant_.

Una vez abierta la herramienta, el título del menú principal indicará que estamos viendo opciones especiales como usuario root.

![bg 82%](assets/02_primera_ejecucion_y_modo_root_00.png)


**Importante**: Para hacer esta configuración no se puede utilizar el comando sudo, el menú no mostrará las mismas opciones.


Al montar el entorno la primera vez o cuando se añada una nueva dirección IP al [fichero de hosts](#fichero-de-hosts), deberemos ejecutar las siguientes opciones en este orden:

- [Escanear hosts SSH](#escanear-hosts-ssh)
- [Generar clave y copiar](#generar-clave-y-copiar)

# Conociendo la interfaz de usuario


Sólo se necesita un teclado, haremos uso especialmente de las teclas de cursor (:arrow_up:, :arrow_down:, :arrow_left: y :arrow_right:), **Enter**, **Tabulador** y **Espacio**.
Podemos salir desde cualquier pantalla de la herramienta pulsando la tecla **Escape**.


## Comprobación de resolución

Para el correcto uso de la herramienta, se debe garantizar un tamaño de ventana y fuente adecuados. Esta pantalla avisa de esta circunstancia y permite al usuario ajustar la ventana antes de Aceptar.

![bg 100% right](./assets/00_interfaz_00.png)


## Uso de menús

Las teclas :arrow_up: y :arrow_down: permiten moverse sobre las opciones disponibles, también nos podemos posicicionar pulsando la tecla de la primera letra de la opción.
Opcionalmente, podemos movernos entre botones, usando las teclas :arrow_left: y :arrow_right: o pulsando **Tabulador**. Finalmente, pulsamos **Enter**.

![bg 100% right](./assets/00_interfaz_01.png)


## Selección de hosts

El usuario puede seleccionar sobre qué hosts del [fichero de hosts](#fichero-de-hosts) actuar.
Si se quieren marcar ```Todos```, pulsamos Enter directamente sin marcar nada más. Para casos concretos, nos movemos con las teclas :arrow_up: y :arrow_down: y pulsamos **Espacio** para marcar o desmarcar. Las opciones seleccionadas quedan anotadas con el símbolo ```*```. Cuando hayamos acabado la selección, pulsamos **Enter**.

![bg 100% right](./assets/00_interfaz_02.png)


## Solicitud de usuario remoto

El usuario sobre el que vamos a actuar en los puestos de alumnos seleccionados. Es importante escribirlo en minúsculas y sin espacios. Por ejemplo, _examen1_

![bg 100% right](./assets/00_interfaz_03.png)

## Explorador de ficheros locales

Nos permite navegar por el sistema de ficheros del profesor para seleccionar un **directorio** o un **fichero**.
La navegación empieza en la raíz del sistema de ficheros ```/```.
En cada pantalla del explorador veremos el texto **Explorando** para ayudarnos a ubicar el directorio actual. Las teclas :arrow_up: y :arrow_down: permiten moverse sobre las opciones.

![bg 100% right](./assets/00_interfaz_explorador_00.png)


Si pulsamos **Enter** sobre un directorio entraremos a explorar el mismo.
Si pulsamos **Enter** sobre la opción ```..  atrás```, volveremos al directorio anterior.
Podemos distinguir los ficheros de los directorios porque los ficheros tienen a la derecha su tamaño en Bytes.

![bg 100% right](./assets/00_interfaz_explorador_00.png)
![bg 100% right](./assets/00_interfaz_explorador_01.png)


Si queremos seleccionar un directorio completo, navegaremos hasta él y pulsaremos **Enter** sobre la opción ```.  actual```.

Para seleccionar un fichero, simplemente pulsaremos **Enter** sobre él.
![bg 100% right](./assets/00_interfaz_explorador_02.png)


## Solicitud de ruta remota

Las rutas remotas no se pueden explorar del mismo modo que las rutas del sistema de ficheros del profesor, por lo que hay que introducirlas por teclado. La ruta debe empezar por ```/```, siendo este símbolo el separador de directorios en Linux. Además, también hay que prestar atención al correcto uso de mayúsculas y minúsculas.

![bg 100% right](./assets/00_interfaz_04.png)



Cuando se hace un cambio de contraseña no se pide escribirla dos veces, por lo que se muestra en claro.

![bg 100% right](./assets/00_interfaz_05.png)



En caso de que se deba introducir una contraseña que deba quedar en secreto.

![bg 100% right](./assets/00_interfaz_06.png)



Antes de llevar a cabo la ejecución de la acción seleccionado con los parámetros introducidos por el usuario, se pedirá confirmación mostrando exactamente lo que se va a ejecutar.

Sin ser necesario tener un conocimiento exhaustivo, esto permite al menos observar que se aplican los parámetros introducidos y **se recomienda comprobarlos antes de aceptar**.

![bg 100% right](./assets/00_interfaz_07.png)


## Revisar traza de ejecución y seguir o salir

Tras el paso anterior, se ejecutará el comando. En la traza de consola podrán observarse todos los parámetros y el resultado de la ejecución en cada host:
:green_square: ```SUCCESS```: casos finalizados con éxito y posible texto informativo.
:red_square: ```FAILURE```: casos fallidos y posible detalle del error.
La herramienta queda pausada a la espera de que el usuario lea esta información y pulse **Enter** para seguir o **Escape** para salir.

![](./assets/00_interfaz_08.png)

# Acciones exclusivas del modo root



## Escanear hosts SSH

Esta acción es útil para evitar que la primera conexión SSH que hagamos desde el puesto **profe** con un puesto de alumno pida confirmar la autenticidad del host remoto.

Deberá hacerse una única vez al preparar el entorno o cuando se añadan nuevas direcciones IP al fichero de hosts.

![bg 82%](assets/03_modo_root_escanear_hosts_ssh_00.png)

![bg 82%](assets/03_modo_root_escanear_hosts_ssh_01.png)

![bg 82%](assets/03_modo_root_escanear_hosts_ssh_02.png)

![bg 82%](assets/03_modo_root_escanear_hosts_ssh_03.png)

![bg 82%](assets/03_modo_root_escanear_hosts_ssh_04.png)


## Generar clave y copiar

Esta acción permite que desde el host **profe** conectemos como root en los puestos de alumno sin que se nos pida contraseña.

Deberá hacerse una única vez al preparar el entorno o cuando se añadan nuevos puestos.

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_00.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_01.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_02.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_03.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_04.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_05.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_06.png)

![bg 82%](assets/04_modo_root_generar_clave_y_copiar_07.png)


## Actualizar script

En tanto que hemos descargado esta herramienta clonando el proyecto con Git, podríamos hacer _git pull_ para actualizar los scripts con frecuencia.

No obstante, como hemos editado el fichero _.config_, se recomienda actualizar desde el menú de la herramienta.



# Acciones disponibles en modo _sudo_

El modo _root_ tiene todas las opciones de la herramienta disponibles, pero se recomienda utilizarlo únicamente en los casos anteriormente citados.

Se recomienda usar la herramienta con un usuario con capacidad de ejecutar sudo (p. ej. ```vagrant``` en el entorno de pruebas o ```madrid``` en el entorno real).

```bash
cd /UTIL-gestiona-aula
sudo ./gestion-aula.sh
```


## Comprobar conexiones y sesiones

Permite establecer conexión SSH con los hosts indicados y verificar si hay sesiones abiertas o usuarios bloqueados.

![bg 82%](assets/05_comprobar_conexiones_y_sesiones_00.png)

![bg 82%](assets/05_comprobar_conexiones_y_sesiones_01.png)

![bg 82%](assets/05_comprobar_conexiones_y_sesiones_02.png)

![bg 82%](assets/05_comprobar_conexiones_y_sesiones_03.png)

![bg 82%](assets/05_comprobar_conexiones_y_sesiones_04.png)


## Salir

Esta acción cierra la herramienta.

Si no estamos en el menú principal, podemos salir desde cualquier pantalla de la herramienta pulsando la tecla Escape (al menos un par de veces).

![bg 82%](assets/06_salir_00.png)

![bg 82%](assets/06_salir_01.png)


## Cambiar contraseña

Permite establecer una nueva contraseña para el mismo usuario en un conjunto de ordenadores del aula. Esta opción desbloquea la cuenta de dicho usuario.

![bg 82%](./assets/08_cambiar_contraseña_00.png)

![bg 82%](./assets/08_cambiar_contraseña_01.png)


![bg 82%](./assets/08_cambiar_contraseña_02.png)


![bg 82%](./assets/08_cambiar_contraseña_03.png)


![bg 82%](./assets/08_cambiar_contraseña_04.png)


![bg 82%](./assets/08_cambiar_contraseña_05.png)



## Ver espacio disco

Permite ver el porcentaje de uso de un determinado disco en los puestos de alumno.

![bg 82%](./assets/09_ver_espacio_discos_00.png)

![bg 82%](./assets/09_ver_espacio_discos_01.png)

![bg 82%](./assets/09_ver_espacio_discos_02.png)

![bg 82%](./assets/09_ver_espacio_discos_03.png)

![bg 82%](./assets/09_ver_espacio_discos_04.png)



## Ver espacio ocupado por usuarios

Muestra el total de espacio ocupado por las carpetas de usuario en los puestos de alumno. Permite identificar quién está acaparando el disco.


.



## Opciones apagado

Permite apagar o reiniciar un conjunto de ordenadores del aula.

![bg 82%](./assets/10_opciones_apagado_00.png)

![bg 82%](./assets/10_opciones_apagado_01.png)

![bg 82%](./assets/10_opciones_apagado_02.png)

![bg 82%](./assets/10_opciones_apagado_03.png)

![bg 82%](./assets/10_opciones_apagado_04.png)

## Copiar

Permite copiar un directorio o fichero del ordenador del profesor a los de los alumnos. Tras la copia, el fichero no será accesible para los alumnos. Deberá usarse la opción [Dar permisos](#dar-permisos).


.

## Dar permisos

Permite conceder acceso a los alumnos sobre un directorio o fichero de su ordenador.


.

## Quitar permisos

Permite quitar el acceso a los alumnos sobre un directorio o fichero de su ordenador.


.

## Finalizar procesos y sesión de usuario

Si detectamos una sesión abierta por un usuario indeseado, esta opción nos permite cerrarla.


.

## Bloquear usuario

Deshabilita la cuenta de un usuario en un conjunto de puestos de alumno, pero no finaliza una posibles sesiones abiertas previamente. Típicamente se usa para prevenir que un alumno entre en su cuenta habitual durante un examen. Un usuario bloqueado se desbloquea con la opción [Desbloquear usuario](#desbloquear-usuario) o tras [Cambiar contraseña](#cambiar-contraseña).


.

## Desbloquear usuario

Habilita la cuenta de un usuario para que los alumnos puedan volver a usarla.


.

## Ejecutar como usuario

Ejecuta un comando en los ordenadores de alumno como un usuario específico.


.


# Acciones para gestionar exámenes

Asistentes guiados compuestos de varias de las acciones anteriormente detalladas. Dan la posibilidad de elegir qué acciones se desean aplicar y simplifican la solicitud de parámetros.

## Habilitar modo examen

 El modo examen finaliza tras apagarlo/reiniciarlo o con la opción [Deshabilitar modo examen](#deshabilitar-modo-examen)

.

## Deshabilitar modo examen

Asistente para deshacer los cambios aplicados al habilitar el modo examen.


.
