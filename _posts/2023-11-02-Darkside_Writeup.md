---
title: "Darkside Writeup - HackMyVM"
date: 2023-11-02
categories: [Writeups, HackMyVM, Easy]
tags: [Linux, Easy, Darkside, HackmyVM, privesc, burpsuite]
---

| Información |
|------------|------------|------------|
| Máquina: Darkside |
| SO: Linux |
| Dificultad: Easy |

- Comenzamos escaneando nuestra propia red para ver que IP le ha asignado el DHCP a la máquina darkside.

- Primero es necesario ver en que red estamos.
![](/assets/img/posts/darkside/ifconf.png)

- Como se puede ver nos encontramos en la red 0, con máscara de subred /24.

- Hacemos un nmap con esta información

```bash
nmap -sP 192.168.0.0/24 | grep "scan"
```
![](/assets/img/posts/darkside/nmap.png)

- Ya tenemos la IP de darkside: 192.168.0.101

- Realizamos un nmap para ver que servicios están corriendo en la máquina.

``` bash
nmap -sVC -p- 192.168.0.101 --min-rate 5000
```
![](/assets/img/posts/darkside/nmap2.png)

> El parámetro -sVC es el conjunto de -sV (Service Version, te muestra las versiones de los servicios) y -sC (Script Scan, nos ayuda a encontrar vulnerabilidades conocidas).
{: .prompt-tip }
> El parámetro -p- indica que el escaneo se hará sobre los 65536 puertos.
{: .prompt-tip }
> El parámetro --min-rate 5000, estamos configurando una velocidad mínima de escaneo de 5000 paquetes por segundo, se puede configurar también un delay entre cada paquete y bajar el min rate para no hacer tanto ruido en la máquina victima.
{: .prompt-tip }

- Vemos dos servicios, SSH en el puerto 22 y HTTP en el 80, visitamos la página web.

- Nos encontramos un login

![](/assets/img/posts/darkside/login.png)

- Vemos el código fuente a ver si nos da alguna pista sin éxito, probamos un `dirb` a la web, con esto hacemos un escaneo en busca de directorios y archivos.

```bash
dirb http://192.168.0.101/ /usr/share/wordlists/dirb/common.txt
```
![](/assets/img/posts/darkside/dirb.png)

- Encontramos una URL interesante /backup, la buscamos en el navegador.

>El resultado (CODE:) hace referencia al tipo de respuesta en el servidor, es decir la página /index.php lanza un código 200 (lo que en HTTP indica respuesta existosa) y la URL /server-status lanza un código 403 (lo que indica un acceso denegado), en cambio vemos que /backup es un directorio
{: .prompt-tip }

![](/assets/img/posts/darkside/backup.png)

- Nos encontramos un archivo .txt, lo abrimos.

![](/assets/img/posts/darkside/vote.png)

- Dentro encontramos varios nombres, pero el que más llama la atención es el de kevin, intentamos sacar credenciales para el login con el nombre kevin, para ello preparamos un payload en burpsuite.

- Para ello primero lanzamos una petición de login y la interceptamos.

![](/assets/img/posts/darkside/intercept.png)

- Mandamos la petición al intruder

![](/assets/img/posts/darkside/ENVIARINTRUDER.png)

- En el campo pass= saldrá la contraseña que hemos puesto, la seleccionamos y le añadimos § 

![](/assets/img/posts/darkside/addpass.png)

- Preparamos el ataque en la ventana payloads, buscamos un diccionario de contraseñas en formato raw, yo voy a usar [este](https://github.com/danielmiessler/SecLists/blob/master/Passwords/Leaked-Databases/rockyou-20.txt) y lo pegamos en Payload setting y empezamos el ataque desde Start attack.

![](/assets/img/posts/darkside/startattack.png)

- Se nos abre una ventana con el payload y rápidamente 
- encontramos la contraseña `iloveyou`para el usuario `kevin`

![](/assets/img/posts/darkside/ILOVEYOU.png)

>El código 302 nos indica una redirección, es decir sabemos que es la correcta porque ha entrado en el login y lo ha enviado a una nueva página.
{: .prompt-tip }

- Probamos la credenciales y tenemos éxito, en la página web vemos una serie de letras y números pero no parecen ser un hash.

- Probamos las credenciales `kevin@iloveyou` en SSH sin éxito.

![](/assets/img/posts/darkside/hellokev.png)

- Visitamos cyberchef para ver si somos capaces de descifrarlo, cuando no sabemos como se ha encriptado podemos hacer uso de la herramienta Magic dentro de cyberchef.

![](/assets/img/posts/darkside/magic.png)

- Vemos que se ha codificado en Base58 y Base64 y nos da lo que aparentemente parece una URL.

![](/assets/img/posts/darkside/onion.png)

- La buscamos en le navegador y nos encontramos una web con la frase "Which Side Are You On?", vemos el código fuente para ver si hay alguna pista y nos encontramos con un script

```javascript
var sideCookie = document.cookie.match(/(^| )side=([^;]+)/);
if (sideCookie && sideCookie[2] === 'darkside') {
	window.location.href = 'hwvhysntovtanj.password'
}
```

- El código busca la cookie "side" y si el valor de la cookie corresponde con darkside nos reenvía a hwvhysntovtanj.password,
- para modificar la cookie usaremos las herramientas de desarrollador, en firefox damos click derecho en la web, damos a Inspeccionar y nos dirigemos a Almacenamiento > Cookies 

![](/assets/img/posts/darkside/inspec.png)

- Cambiamos el valor de la cookie de whiteside a darkside.

![](/assets/img/posts/darkside/darkcookie.png)

Recargamos la página y efectivamente nos reenvía a hwvhysntovtanj.password, y nos dan las credenciales de `kevin@ILoveCalisthenics`, la probamos en ssh y entramos sin problema.

```bash
ssh kevin@192.168.0.101
```

![](/assets/img/posts/darkside/dentrossh.png)

- En este punto, comenzamos la escala de privilegios, empezamos con un
```bash
find / -perm /4000 2>/dev/null
```

>El comando find / -perm /4000 2>/dev/null busca archivos con permiso setuid o setgid y muestra su ubicación
{: .prompt-tip }

- No encontramos nada de interés, hacemos un 
```bash
ls -la
```

- y nos encontramos con un archivo .history hacemos un 

```bash
cat .history
```
![](/assets/img/posts/darkside/rijaba.png)

- Encontramos otras posibles credenciales `rijaba@ILoveJabita`, entramos a su SSH, aún no somos root, el

```bash 
find / -perm /4000 2>/dev/null
```

- nos da los mismos resultados, probamos con 

```bash
sudo -l
```
![](/assets/img/posts/darkside/sudol.png)

- Nos encontramos que tiene acceso al binario de nano, lo buscamos en [GTFOBins](https://gtfobins.github.io/)

![](/assets/img/posts/darkside/nanosudo.png)


- Encontramos una forma de privesc a través de nano

![](/assets/img/posts/darkside/rx.png)

- El orden a realizar es sudo nano en la terminal, se nos abrirá una ventana de nano, pulsaremos la combinación (Crtl+R) y (Crtl+X), nos pedirá un input de texto, ahí hemos de colocar el `reset; sh 1>&0 2>&0`

![](/assets/img/posts/darkside/execreset.png)

- Una vez se ejecute veremos la # y ya seremos root, nos movemos al directorio root y encontramos la flag root.txt

![](/assets/img/posts/darkside/soyroot.png)


