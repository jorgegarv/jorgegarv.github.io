---
title: "Configurar contraseña en GRUB"
date: 2024-06-11
categories: [Tutorial, GRUB, linux]
tags: [Linux, Easy, GRUB,conf]
image:
   path: /assets/img/posts/grub/linux-logo.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner GRUB
---

# ¿Qué es el GRUB?

El Gestor de Arranque GRUB (GRand Unified Bootloader) es una parte esencial del proceso de inicio en los sistemas operativos basados en Linux. Su función principal es cargar el sistema operativo en la memoria del ordenador para que pueda arrancar correctamente. Dada su importancia crítica, asegurar GRUB es fundamental para proteger la integridad y la seguridad del sistema.

Uno de los principales riesgos de seguridad asociados con GRUB es la posibilidad de que un atacante modifique las opciones de inicio o acceda al modo de edición desde el menú de GRUB durante el proceso de arranque. Esto podría permitir que el atacante realice cambios maliciosos en la configuración del sistema antes de que el sistema operativo se haya cargado por completo, lo que podría comprometer la seguridad del sistema.

En resumen, asegurar GRUB es esencial para garantizar la seguridad del sistema durante el proceso de arranque y protegerlo contra posibles amenazas de seguridad.

>Previo a la configuración es muy recomendable realizar una backup o un spanshot.
{: .prompt-warning }

## Configurar contraseña de GRUB:

Para configurar una contraseña en GRUB y evitar que personas no autorizadas realicen cambios en las opciones de arranque o accedan a los modos de edición desde el menú de GRUB, sigue estos pasos:

Abre el archivo de configuración de GRUB. Típicamente, este archivo se encuentra en la ubicación `/etc/grub.d/00_header`.

![](/assets/img/posts/grub/etcgrub.png)

Agrega la siguiente línea al archivo:

```zsh
cat << EOF  
set superusers="root"  
password_pbkdf2 root `Aquí va la contraseña cifrada`  
EOF
```
![](/assets/img/posts/grub/passetc.png)

Reemplaza `Aquí va la contraseña cifrada` con la contraseña encriptada que deseas utilizar. Puedes generar una contraseña encriptada utilizando el comando `grub-mkpasswd-pbkdf2`.

![](/assets/img/posts/grub/encrypted.png)

Guarda los cambios y cierra el archivo.
Actualiza la configuración de GRUB ejecutando el siguiente comando:

```zsh        
sudo update-grub
```

Con estos pasos, habrás configurado una contraseña en GRUB para proteger tu sistema contra cambios no autorizados en las opciones de arranque y el acceso no autorizado al modo de edición de GRUB desde el menú de arranque.
