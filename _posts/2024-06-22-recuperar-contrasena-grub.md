---
title: "Recuperar contraseña de root"
date: 2024-06-22
categories: [Tutorial, GRUB, linux]
tags: [Linux, Easy, GRUB,conf]
image:
   path: /assets/img/posts/cambiar/Logo-Parrot.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner PARROT
---

# ¿Qué es el GRUB?

El Gestor de Arranque GRUB (GRand Unified Bootloader) es una parte esencial del proceso de inicio en los sistemas operativos basados en Linux. Su función principal es cargar el sistema operativo en la memoria del ordenador para que pueda arrancar correctamente. Dada su importancia crítica, asegurar GRUB es fundamental para proteger la integridad y la seguridad del sistema.

# Cambiar contraseña de root desde el GRUB

En ocasiones, puede ser necesario cambiar la contraseña de root si la has olvidado o si necesitas acceder al sistema con privilegios administrativos y no puedes hacerlo de otra manera. GRUB nos permite acceder a una serie de herramientas que facilitan este proceso.

>Esta práctica tiene el riesgo de que cualquier persona es capaz de hacerlo y acceder a nuestro sistema como root, para evitarlo puedes ver este [tutorial](https://404azz.github.io/posts/asegurar-grub/) de como asegurar el GRUB
{: .prompt-warning }

>Este ejemplo se ha realizado en Parrot (basado en Debian)
{: .prompt-info }

Al iniciar el SO, elegimos las opciones avanzadas de inicio.

![](/assets/img/posts/cambiar/advaced.png)

Dentro, nos posicionamos sobre las opciones de recuperación y sin entrar, presionamos la tecla `e`

![](/assets/img/posts/cambiar/recovery-e.png)

Entraremos al editor de GRUB, debemos observar la siguiente línea

```zsh
	ro single
```
![](/assets/img/posts/cambiar/rosingle.png)

Debemos borrar esa línea y cambiarla por 

```zsh
	rw init=/bin/bash
```

![](/assets/img/posts/cambiar/rwinit.png)

>Es probable que al introducir la línea rw init=/bin/bash el teclado esté en una configuración inglesa
{: .prompt-info }

Pulsamos `Crtl + X` o `F10`

Accederemos al sistema como root, y con el comando 

```zsh
	passwd
```

será posible configurar una nueva contraseña para nuestro root

![](/assets/img/posts/cambiar/grubroot.png)

Tas este proceso ya tendremos al user root con una contraseña nueva.

Para protegerse contra posibles ataques puedes asegurar el grub con una contraseña siguiendo el siguiente [tutorial](https://404azz.github.io/posts/asegurar-grub/)
