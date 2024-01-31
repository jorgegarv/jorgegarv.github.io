---
title: "Tratamiento de la TTY"
date: 2023-12-15
categories: [Linux, TTY]
tags: [Linux, Tratamiento. TTY]
image:
   path: /assets/img/posts/tratamientoTTY/bash.jpg
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: banner bash
---

Cuando ganamos acceso a una máquina nos encontramos con una TTY no interactiva, en la que no podemos movernos de una forma cómoda.

Para poder trabajar comodamente como lo harías en tu consola el tratamiento a seguir es el siguiente:

```bash
script /dev/null -c bash
```

Acto seguido presionamos `Crtl + z` y seguimos con el tratamiento:

```bash
stty raw -echo; fg
```

Despúes de esto haremos un `reset`  continuamos el tratamiento con:

```bash
export TERM=xterm
export SHELL=bash
```

Ya tenemos una terminal totalmente interactiva dentro de la revshell.

El resumen de los comandos sería:

```bash
script /dev/null -c bash

stty raw -echo; fg

reset

export TERM=xterm

export SHELL=bash
```
