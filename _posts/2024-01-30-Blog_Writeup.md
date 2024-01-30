---
title: "Blog Writeup - Vulnyx"
date: 2024-01-30
categories: [Writeups, Vulnyx, Easy]
tags: [Linux, Easy, Blog, Vulnyx, privesc, fuzz, git, port, mcedit, hydra, CVE]
image:
   path: /assets/img/posts/blog/blogbanner.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner Blog
---

| Información |
|------------|------------|------------|
| Máquina: Blog |
| Creador: RiJaba1 |
| SO: Linux |
| Dificultad: Easy |

En el caso de esta máquina el propio creador RiJaba1 nos da la IP de la misma en el login de la máquina.

En mi caso va a ser la

```zsh
192.168.0.30
```

![](/assets/img/posts/blog/IPDescubrir.png)

Realizo un ping a la máquina para confirmar que hay visibilidad entre máquinas

![](/assets/img/posts/blog/ping.png)

Realizamos un nmap para ver que servicios están corriendo en la máquina.

``` bash
nmap -sVC 192.168.0.30
```

> El parámetro -sVC es el conjunto de -sV (Service Version, te muestra las versiones de los servicios) y -sC (Script Scan, nos ayuda a encontrar vulnerabilidades conocidas o servicios en el objetivo).
> {: .prompt-tip }

![](/assets/img/posts/blog/nmap.png)

Disponemos de un servicio HTTP en el puerto 80 y un servicio SSH en el puerto 22, visitamos la web.

El index es un ping que nos da la pista de que se trata de un blog

![](/assets/img/posts/blog/esunBlog.png)

Puesto que no encontramos nada procedemos a realizar un escaneo de directorios con dirbuster

```zsh
gobuster dir -u "http://192.168.0.30" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
```

![](/assets/img/posts/blog/dirbuster.png)

Encontramos un directorio llamado /my_weblog, nos dirigimos a él.

![](/assets/img/posts/blog/weblog.png)

Encontramos un blog, mirando el código fuente de la página nos damos cuenta que es un Nibbleblog

![](/assets/img/posts/blog/Nibbleblog.png)

Buscando en la [documentación de nibbleblog](https://docs.bludit.com/en/security/disable-admin-user) (ahora bludit) he encontrado que por defecto el usuario con privilegios es "admin"

Intentamos entrar al panel de login con la URL 
```URL
http://192.168.0.30/my_weblog/admin/
```

pero sin éxito, intentamos un FUZZING para encontrar el panel de login

```zsh
gobuster fuzz -w /usr/share/wordlists/wfuzz/general/admin-panels.txt -t 200 -u "http://blog.nyx/my_weblog/FUZZ" --exclude-length 270
```

![](/assets/img/posts/blog/adminphp.png)

Encontramos lo que parece ser el panel de control

![](/assets/img/posts/blog/panelcontrol.png)

Intentamos una fuerza bruta sabiendo que el usuario por defecto es `admin`

```zsh
hydra -l admin -P /usr/share/wordlists/rockyou.txt 192.168.0.30 http-post-form "/my_weblog/admin.php:username=^USER^&password=^PASS^:Incorrect"
```

Obtenemos la password para acceder al panel de control

![](/assets/img/posts/blog/hydra.png)

Una vez dentro vamos a intentar explotar la vulnerabilidad [CVE-2015-6967](https://www.exploit-db.com/exploits/38489) que permite ejecución remota de código a través del plugin My Image

![](/assets/img/posts/blog/plugins.png)

Creamos y subimos la [revshell](https://www.revshells.com/) a través del plugin My Image

![](/assets/img/posts/blog/revshell.png)

Ponemos el puerto que hemmos elegido a la escucha

```zsh
nc -nlvp 4444
```

Ejecutamos la revshell desde la URL 
```URL
http://192.168.0.30/my_weblog/content/private/plugins/my_image/image.php
```

Conseguimos la shell como el usuario www-data

![](/assets/img/posts/blog/shellwww.png)

Encuentro la posible explotación del binario git

![](/assets/img/posts/blog/git.png)

Hago una búsqueda en [GTFObins](https://gtfobins.github.io/)

Antes de explotar el binario es necesario hacer un [tratamiento de la TTY](https://404azz.github.io/posts/Tratamiento_TTY/)

Lo exploto ejecutándolo como el user admin con
```zsh
sudo -u admin /usr/bin/git -p help config
```

Nos dejará meter un texto, invocamos la shell con !/bin/bash y nos convertimos en admin

![](/assets/img/posts/blog/binbash.png)

Encontramos la flag de user dentro de su home

![](/assets/img/posts/blog/user.png)

Hacemos el mismo procedimiento para escalar privilegios, observamos si como admin podemos ejecutar algún binario explotable como root

![](/assets/img/posts/blog/mcedit.png)

Encontramos el mcedit, haciendo una búsqueda en [GTFObins](https://gtfobins.github.io/) no encontramos nada.

Ejecutamos el binario como root 

```zsh
sudo /usr/bin/mcedit
```

![](/assets/img/posts/blog/mceditscreen.png)

Encuentro una forma de invocar una shell desde el programa

![](/assets/img/posts/blog/mceditmenu.png)

![](/assets/img/posts/blog/mceditusermenu.png)

![](/assets/img/posts/blog/mceditshell.png)

Nos convertimos en root a través de la shell de mcedit

![](/assets/img/posts/blog/root.png)

Y por último obtenemos la flag de root!
