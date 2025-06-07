---
title: "Creación de CRUD básico con Spring Boot"
date: 2025-06-07
categories: [Tutorial, CRUD, Java, springboot, development, desarrollo, backend]
tags: [Java, spring, springboot, development, desarrollo, backend]
image:
   path: /assets/img/posts/api-springboot/spring-boot-logo.png
   lqip: data:image/webp;base64,UklGRpoAAABXRUJQVlA4WAoAAAAQAAAADwAABwAAQUxQSDIAAAARL0AmbZurmr57yyIiqE8oiG0bejIYEQTgqiDA9vqnsUSI6H+oAERp2HZ65qP/VIAWAFZQOCBCAAAA8AEAnQEqEAAIAAVAfCWkAALp8sF8rgRgAP7o9FDvMCkMde9PK7euH5M1m6VWoDXf2FkP3BqV0ZYbO6NA/VFIAAAA
   alt: Banner SpringBoot
---

# Creación de CRUD básico con Java Spring Boot

La idea es crear una API REST con Java y Spring Boot, siguiendo una estructura de proyecto Maven, que permita añadir, eliminar y actualizar usuarios.

Comenzamos usando la herramienta [spring initializr](https://start.spring.io/)

Esta herramienta oficial de Spring nos facilita la creación de proyectos Spring Boot.

Voy a usar esta configuración para empezar con el proyecto.

![](/assets/img/posts/api-springboot/config-initializr.png)

Además, incluimos la dependencia Web, que agrega todas las librerías necesarias para construir aplicaciones web con Spring Boot, especialmente APIs REST.

![](/assets/img/posts/api-springboot/add-dep.png)

![](/assets/img/posts/api-springboot/add-web.png)

Con esta configuración generamos el zip del proyecto.

![](/assets/img/posts/api-springboot/generate.png)

>Para poder ejecutar el proyecto con Java 17, es necesario tener instalado el JDK 17 o superior
{: .prompt-warning }

Se nos descarga un archivo comprimido con todo el proyecto, lo descomprimimos en una carpeta específica para el proyecto.

>Usaré IntelliJ IDEA como entorno de desarrollo, pero puedes seguir los mismos pasos con cualquier otro IDE compatible con Java, como Eclipse o VS Code.
{: .prompt-info }

Dentro del IDE abrimos el proyecto de Spring boot.

![](/assets/img/posts/api-springboot/open-intelli.png)

![](/assets/img/posts/api-springboot/proyecto-abierto.png)

Ya tenemos el proyecto listo para modificarlo con las dependencias y la estructura Maven.

Crearemos el paquete _models_ dentro del paquete principal com.tuusuario.CRUDBasico para añadir nuestra clase Usuario.

![](/assets/img/posts/api-springboot/new-pack.png)

Ahora sí, creamos la clase Usuario dentro del paquete _models_

![](/assets/img/posts/api-springboot/user-class.png)

Definimos los atributos del Usuario, creamos los getters y setters, y el constructor de Usuario.

```java
    package com.jorgegarv.CRUDBasico.models;

public class Usuario {
    private Long id;
    private String nombre;
    private String rango;

    public Usuario() {}

    public Usuario(Long id, String nombre, String rango) {
        this.id = id;
        this.nombre = nombre;
        this.rango = rango;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getRango() {
        return rango;
    }

    public void setRango(String rango) {
        this.rango = rango;
    }
}
```
>Para el ejemplo simulamos el Usuario de un blog con id,nombre y rango
{: .prompt-info }

Con la clase Usuario creada dentro de nuestro paquete _models_ crearemos un nuevo paquete en el raíz llamado _controllers_

![](/assets/img/posts/api-springboot/new-controller.png)

Dentro de controllers crearemos la clase UsuarioController, está clase será la encargada de gestionar las solicitudes HTTP que lleguen a la API.

![](/assets/img/posts/api-springboot/controller-crea.png)

Con la clase de UsuarioController lo primero que haremos será anotarla como @RestController, para que la clase funcione como controlador REST. 

```java
package com.jorgegarv.CRUDBasico.controllers;

import org.springframework.web.bind.annotation.RestController;

@RestController
public class UsuarioController {

}
```
>Según la [documentación de SpringBoot](https://spring.io/guides/gs/rest-service) para que una clase funcione como controlador REST es necesario anotarla con @RestController. Esta anotación indica que la clase maneja solicitudes HTTP y que sus métodos devuelven datos en formato JSON automáticamente.
{: .prompt-info }

Ahora que la clase ya se ha identificado como controlador REST, vamos a simular una base de datos, creando un ArrayList y añadiendo 3 usuarios de ejemplo.

```java
package com.jorgegarv.CRUDBasico.controllers;

import com.jorgegarv.CRUDBasico.models.Usuario;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;

@RestController
public class UsuarioController {

    ArrayList<Usuario> users = new ArrayList<>();

    {
        users.add(new Usuario(1L,"Arthur Morgan","Moderador"));
        users.add(new Usuario(2L,"Dutch","New Full User"));
        users.add(new Usuario(3L,"John Marston","User"));
    }

}
```
Con este código simularemos una base de datos con 3 usuarios.

# Métodos

## Método GET

Comenzamos con un método tipo GET para listar los usuarios, usaremos la anotación @GetMapping en el método y definiremos la ruta a la que se debe llamar.

>Se usa @GetMapping como forma simplificada de @RequestMapping(method = RequestMethod.GET) para crear un endpoint que responda solicitudes GET
{: .prompt-info }

```java
@GetMapping("/usuarios")
    public ArrayList<Usuario> getUsers(){
        return users;
    }
```
>En este ejemplo, al llamar a http://url/usuarios nos listará el arrayList de users
{: .prompt-info }

## Método POST

Ahora vamos a crear un método tipo POST para la creación de nuevos usuarios, usaremos la anotación @PostMapping en el método y definiremos la ruta igual que en el ejemplo de GET.

```java
@PostMapping("/usuarios")
    public Usuario addUser(@RequestBody Usuario newUser){
        newUser.setId(users.size()+1L);
        users.add(newUser);
        return newUser;
    }
```

>Usamos la anotación @RequestBody que indica que el método espera un JSON con la información del usuario en el cuerpo de la petición POST, según la [documentación oficial de Spring boot](https://docs.spring.io/spring-framework/reference/web/webflux/controller/ann-methods/requestbody.html)
{: .prompt-info }

Al realizar una petición POST con un JSON con la información del nuevo usuario, este se creará y añadirá al ArrayList que simula nuestra base de datos.

## Método DELETE

Continuamos con un método para eliminar usuarios con una petición DELETE, usaremos la anotación @DeleteMapping en el método, definiendo la ruta /usuarios/{id} donde id será el identificador del usuario a eliminar

```java
@DeleteMapping("usuarios/{id}")
    public String delUser(@PathVariable Long id){
        boolean remove = users.removeIf(user -> user.getId().equals(id));
        if(remove){
            return "Usuario con id "+id+" eliminado";
        }else{
            return "Usuario con id "+id+" no encontrado";
        }
    }
```

>Usamos la anotación @PathVariable que indica que el parámetro id se extrae directamente de la URL (al llamar a http://url/usuarios/2 el parámetro considerará 2 como valor de id) según la [documentación de Spring boot](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/bind/annotation/PathVariable.html)
{: .prompt-info }

## Método PUT

En la petición PUT haremos modificaciones sobre los campos del usuario (nombre y rango), usaremos la anotación @PutMapping y la ruta de la llamada, al igual que en los otros métodos

```java
    @PutMapping("/usuarios/{id}")
    public Usuario updateUser(@PathVariable Long id, @RequestBody Usuario usuarioActualizado){
        for(Usuario u : users){
            if(u.getId().equals(id)){
                u.setNombre(usuarioActualizado.getNombre());
                u.setRango(usuarioActualizado.getRango());
                return u;
            }
        }
        return null; // En caso de no encontrar el usuario
    }
```

>Usamos anotación @PathVariable para indicar el id a través de la URL y @RequestBody para enviar la información a modificar a través de JSON
{: .prompt-info }

### El código completo de la clase UsuarioController queda así:

```java
package com.jorgegarv.CRUDBasico.controllers;

import com.jorgegarv.CRUDBasico.models.Usuario;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
public class UsuarioController {

    ArrayList<Usuario> users = new ArrayList<>();

    {
        users.add(new Usuario(1L,"Arthur Morgan","Moderador"));
        users.add(new Usuario(2L,"Dutch","New Full User"));
        users.add(new Usuario(3L,"John Marston","User"));
    }

    @GetMapping("/usuarios")
    public ArrayList<Usuario> getUsers(){
        return users;
    }

    @PostMapping("/usuarios")
    public Usuario addUser(@RequestBody Usuario newUser){
        newUser.setId(users.size() + 1L);
        users.add(newUser);
        return newUser;
    }

    @DeleteMapping("/usuarios/{id}")
    public String delUser(@PathVariable Long id){
        boolean remove = users.removeIf(user -> user.getId().equals(id));
        if(remove){
            return "Usuario con id "+id+" eliminado";
        }else{
            return "Usuario con id "+id+" no encontrado";
        }
    }

    @PutMapping("/usuarios/{id}")
    public Usuario updateUser(@PathVariable Long id, @RequestBody Usuario usuarioActualizado){
        for(Usuario u : users){
            if(u.getId().equals(id)){
                u.setNombre(usuarioActualizado.getNombre());
                u.setRango(usuarioActualizado.getRango());
                return u;
            }
        }
        return null; // En caso de no encontrar el usuario
    }
}
```

# Peticiones

Para probar la API y lanzar las peticiones primero hay que inicializar la aplicación desde la clase principal.

![](/assets/img/posts/api-springboot/lanzar-app.png)

Al inicializarla se levantará un servidor que por defecto se alojará en el puerto 8080.

## Petición GET

Para probar nuestro método GET desde cualquier navegador haremos una llamada a http://localhost:8080/usuarios

Recordemos que este método nos devuelve los usuarios guardados en el ArrayList.

![](/assets/img/posts/api-springboot/test-get.png)

>Aquí podemos ver como al llamar por GET a /usuarios nos da la lista de los mismos
{: .prompt-info }

## Petición POST

Para probar la petición al método POST podemos usar herramientas como Postman, curl desde la terminal, o cualquier cliente HTTP que nos permita enviar solicitudes con un cuerpo JSON. 

Recordemos que este método crea un nuevo usuario y lo añade al ArrayList.

### Ejemplo con cURL en cmd

```powershell
curl -X POST http://localhost:8080/usuarios -H "Content-Type: application/json" -d "{\"nombre\":\"Sadie Adler\",\"rango\":\"Full User\"}"
```

### Ejemplo con cURL en bash

```bash
curl -X POST http://localhost:8080/usuarios -H 'Content-Type: application/json' -d '{"nombre":"Sadie Adler","rango":"Full User"}'
```

### Ejemplo en PostMan

{% youtube r1XM8qD5WMs %}

El JSON que he usado para añadir este usuario en Postman ha sido:

```JSON
    {
    "nombre": "Micah Bell",
    "rango": "New Full User"
    }
```

Comprobamos haciendo una llamada al método GET que se han creado tanto el usuario por cURL como el usuario por Postman

![](/assets/img/posts/api-springboot/new-users.png)

## Petición PUT

Para probar la petición PUT vamos a utilizar las mismas herramientas que para la petición POST, enviando un JSON con los valores modificados.

Recordemos que el método PUT modifica un usuario existente en nuestro ArrayList, identificándolo por su id en la URL y actualizando los campos que enviemos en el cuerpo de la petición.

### Ejemplo con curl en cmd

```powershell
curl -X PUT http://localhost:8080/usuarios/3 -H "Content-Type: application/json" -d "{\"id\":3,\"nombre\":\"John Marston Sheriff\",\"rango\":\"Admin\"}"
```

### Ejemplo con curl en bash

```bash
curl -X PUT http://localhost:8080/usuarios/3 -H "Content-Type: application/json" -d '{"id":3,"nombre":"John Marston Actualizado","rango":"Admin"}'
```

Comprobamos haciendo una llamada al método GET que se ha modificado correctamente el usuario con el id 3

![](/assets/img/posts/api-springboot/modifi-put.png)

## Petición DELETE

Para probar la petición DELETE vamos a usar curl y postman, eliminando los usuarios creados a través de POST.

Recordemos que el método DELETE elimina un usuario existente en nuestro ArrayList, identificándolo por su id en la URL.

### Ejemplo con curl en cmd
```powershell
    curl -X DELETE http://localhost:8080/usuarios/4
```

### Ejemplo con curl en bash
```bash
    curl -X DELETE http://localhost:8080/usuarios/5
```

>Esto hará que los usuario con id 4 (Sadie Adler) e id 5 (Micah Bell) sean eliminados
{: .prompt-info }
