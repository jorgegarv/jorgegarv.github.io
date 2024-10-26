---
title: "Crear servidor web con Debian"
date: 2024-10-26
categories: [Tutorial, GRUB, linux, server, debian, web, apache, phpmyadmin, sql, mariaDB]
tags: [Linux, Easy, GRUB,conf]
image:
   path: /assets/img/posts/server/debian-logo.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner ServerWeb
---

# Creación de servidor web con Debian(Apache, MariaDB, PHPMyAdmin) y manejando transferencia de archivos por SFTP.

La idea es crear nuestro propio servidor para realizar pruebas en local, tal como haría el programa XAMPP y tener una mayor flexibilidad.

Lo primero será desargar la ISO de debian, desde su [web oficial](https://www.debian.org/index.es.html)

![](/assets/img/posts/server/Captura%20de%20pantalla%202024-10-21%20222310.png)

La descarga comenzará automáticamente, el enlace directo es de la versión netinst, es decir que para instalar la ISO necesitamos conexión a internet, ya que este es un instalador ligero (alrededor de 600 MB) que solo contiene el instalador básico. El resto del sistema se descarga durante la instalación a través de internet. Si quieres una versión completa y portable puedes descargar la versión Debian DVD/BD.

En este ejemplo vamos a usar de entorno de virtualización VMWare. Se puede descargar también en su [repositorio oficial](https://softwareupdate.vmware.com/cds/vmw-desktop/player/), en él están todos sus binarios. 

Lo primero será importar la ISO dentro de VMWare:

![](/assets/img/posts/server/nueva.png)

En esta ventana seleccionaremos la ISO en Installer disc image file: 

![](/assets/img/posts/server/nombre.png)

Después se tendrá que seleccionar el SO manualmente, en este caso es Linux version Debian 11.x 64-bit

![](/assets/img/posts/server/linux64.png)

En la siguiente ventana se deberá dar un nombre a la máquina virtual y una ruta donde guardará toda la información.

![](/assets/img/posts/server/name.png)

Asignamos el espacio en disco(esto se puede aumentar más adelante) y en la última ventana se verá un resumen de todos los datos de nuestra nueva máquina. 

Ya debe aparecer nuestro SO debian en el menú de la izquierda, para iniciar la nueva máquina virtual se debe dar doble click sobre la misma. El primer menú será una decisión sobre como se quiere instalar el SO, de manera gráfica o por línea de comandos, esto no tendrá ningún efecto en su posterior implementación, pues usaremos el servidor solo en modo consola para economizar recursos.

![](/assets/img/posts/server/graficos.png)

Tras hacer las primeras configuraciones básicas como el idioma, nos encontramos con la configuración del nombre de host.

![](/assets/img/posts/server/hostname.png)

Este nombre es el que se le da a la máquina como host, es decir para identificarla dentro de una red, en nuestro caso queremos usar la máquina para pruebas en local, con lo cual es indiferente su nombre.

Después se pedirá un nombre de dominio, en esta instalación no nos afecta por el mismo motivo, el laboratorio a crear es local.

En la siguiente ventana se nos pide la clave de superusuario o usuario root (usuario con todos los permisos dentro de nuestro SO).

![](/assets/img/posts/server/claveRoot.png)

Seguidamente crearemos un usuario con nombre y contraseña aparte de root para hacer configuraciones en las que no sea necesario ser superusuario.

![](/assets/img/posts/server/nameServidor.png)


A la hora de la partición, usaremos todo el disco con una configuración LVM, esto nos dará mayor flexibilidad para crear particiones.

![](/assets/img/posts/server/LVM.png)

Continuamos con las configuraciones básicas de discos, y elegimos el mirror del gestor de paquetes(esto es una redundancia de los servidores de apt).

![](/assets/img/posts/server/apt.png)

Cuando se llegue a la ventana de configuración de escritorios se desmarcarán todas las opciones menos la opción "Utilidades estándar del sistema", podemos seleccionar Web Server y así el propio instalador nos descargará y configurará varios aspectos de Apache, pero la idea es hacerlo nosotros.

![](/assets/img/posts/server/escritorio.png)

Importante instalar GRUB en /dev/sda, es un gestor de arranque, GRUB permitirá que el sistema se inicie correctamente.

![](/assets/img/posts/server/grub.png)

Ya tendremos el SO debian instalado.

![](/assets/img/posts/server/instaladoServer.png)

Habrá que loguearse como root para instalar el servidor web Apache y MariaDB para tener un servidor web básico en local con el objetivo de hacer laboratorios y prescindir de XAMPP.

Lo primero es actualizar apt, con el comando 

```zsh
apt update && apt upgrade
```

Usaremos el gestor de paquetes apt para descargar apache:

```zsh
apt install apache2
```

Podemos observar si apache esta corriendo con el comando

```zsh
systemctl status apache2
```

![](/assets/img/posts/server/apacheRun.png)

Ya tenemos apache corriendo en nuestro servidor, para hacer otra comprobación vamos a usar el comando:

 ```zsh
 hostname -I
```

Para saber nuestra IP local y hacer una llamada a través de un navegador al puerto 80.

![](/assets/img/posts/server/hostname.png)

![](/assets/img/posts/server/navegador.png)

El siguiente paso será descargar MariaDB:

```zsh
apt install mariadb-server
```

Comprobamos que tenemos el servidor corriendo con:

```zsh
systemctl status mariadb
```

![](/assets/img/posts/server/mariaDB.png)

Ya tenemos Apache y  MariaDB, vamos a instalar PHPMyAdmin para administrar la base de datos MariaDB.

```zsh
apt install php phpmyadmin php-mbstring php-gd php-zip php-curl php-json
```

![](/assets/img/posts/server/eleccionPHPmyad.png)

Al instalarse se deberá escoger apache2 (instalado previamente) 

![](/assets/img/posts/server/dbconfig.png)

Seleccionamos la opción "Sí" para realizar la configuración con dbconfig-common y posteriormente creamos una constraseña.

>La selección se realiza con ESPACIO, TAB y ENTER.
{: .prompt-tip }

Ya se deberá visualizar la interfaz de phpmyadmin en la ruta http:// `iplocal`/phpmyadmin

![](/assets/img/posts/server/UIphpmyad.png)

Ahora tenemos que crear un usuario dentro de MariaDB para acceder a phpmyadmin.

Lo primero es entrar:

```zsh
mysql -u root -p
```

![](/assets/img/posts/server/mysql.png)

Crearemos una BD para el servidor.

```sql
CREATE DATABASE server;
```

Ahora utilizaremos USE para entrar en la base de datos y GRANT para dar privilegios al usuario phpmyadmin.

```sql
USE server;
```

```sql
GRANT ALL PRIVILEGES ON server.* TO 'phpmyadmin'@'localhost';
```

![](/assets/img/posts/server/baseSERVER.png)

Ya tenemos la base de datos creada, podemos añadir tantas tablas y filas como datos queramos guardar.

Para poder subir archivos y comunicarnos con el server de una forma más cómoda podemos hacerlo a través de un túnel ssh-ftp con vscode y la extensión SFTP.

Lo primero será instalar el servidor ssh en nuestro debian:

```zsh
apt install openssh-server
```

![](/assets/img/posts/server/sftp.png)

Para configurarla abriremos la paleta de comandos con la combinación `Crtl+Shift+P` y se abrirá el menú de paleta de comandos, buscamos el SFTP: Config.

Debemos rellenar el archivo .json con los datos de nuestro server local.

![](/assets/img/posts/server/datosSFTP.png)

Una vez tengamos el .json completo, con la ruta de nuestro fichero html, podremos trabajar en local con vscode y sincronizar los datos con el servidor, subiéndose automáticamente.

![](/assets/img/posts/server/sync.png)

Nos pedirá la contraseña de root para acceder y subir los archivos, como el index.html

Una vez sincronizado, ya tenemos nuestra página!

![](/assets/img/posts/server/indexhtml.png)

![](/assets/img/posts/server/página.png)

