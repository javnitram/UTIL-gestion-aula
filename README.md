# gestion-aula.sh

Herramienta de gestión de aula

## Documentación

[Presentación en HTML](https://javnitram.github.io/UTIL-gestion-aula/)
[Manual en Markdown](https://github.com/javnitram/UTIL-gestion-aula/blob/gh-pages/README.md)

## Mejoras futuras

* Actualmente no se permite incluir este script en el PATH.
* Verificar parallel-rsync (acción 19)
* Verificar acción de actualización del script.
* ¿Habilitar una opción para generar fichero de hosts automáticamente?
* ¿Resetear usuario examen? userdel -r y volver a crearlo con mismo home, UID, GID y grupos secundarios que tuvo originalmente.

## Contribuir

* Asegúrate de tener instaladas las dependencias indicadas en el tutorial.
* Haz un fork de este proyecto.
* Haz una rama de desarrollo de tu funcionalidad (git checkout -b feature/nombre-funcionalidad).
* Tu funcionalidad puede utilizar cualquier variable global o función de los ficheros common.sh, .config o cualquier fichero accion_\*.sh. Familiarízate con algunas de las acciones ya implementadas.
* Implementa tu funcionalidad en un nuevo script con prefijo "accion_N_" y extensión ".sh". Dicho fichero deberá contener únicamente una función con prefijo "accion_N_" que siga el mismo patrón que las ya existentes, donde N es un número de uno o dos dígitos que establece el orden de opción en el menú. Si se cumple la nomenclatura, el script gestion-aula.sh mostrará correctamente esta nueva opción en el menú.
* Los ficheros accion_\*.sh no tienen por qué tener permisos de ejecución, no deben ser invocados de forma aislada.
* Haz pruebas usando el fichero "hosts-test.txt" con las máquinas virtuales configuradas en javnitram/SIST-multi-vm/Vagrantfile.
* Haz commit de tus cambios (git commit -am 'Funcionalidad implementada').
* Haz push a la rama (git push origin feature/nombre-funcionalidad).
* Haz un nuevo Pull Request.
* Para ayudar a documentar la herramienta, puedes pedir acceso como contribuidor al repositorio privado con el código fuente del tutorial. Está basado en [esta plantilla](https://github.com/javnitram/UTIL-marp-template), se mantiene en formato Markdown y se publica automáticamente con Marp y GitHub Actions.
  