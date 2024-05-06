---
title: "Web scrapping con Python"
date: 2024-05-06
categories: [Tutorial, Python, Scrapping, Web, HTML]
tags: [Python, vscode, Tutorial, Python, HTML]
image:
   path: /assets/img/posts/scrapping/Python-Logo.png
   alt: Python Logo
---

| Información |
|------------|------------|------------|
| Librerias: requests, BeautifulSoup |

# ¿Qué es el web scrapping?

El scrapping web busca simular la navegación humana a través de una página web, realizando esta mediante un script capaz de leer las etiquetas (HTML o XML).<br>

Y a partir de esas etiquetas recabar la información que deseemos. <br>

Estos scripts examinan el código fuente de la página web y extraen la información deseada basándose en las etiquetas específicas que contienen los datos relevantes. Por ejemplo, un script de scraping web puede buscar etiquetas <p> para extraer párrafos de texto, o <div> para obtener bloques de contenido específicos. <br>

El scraping web puede ser útil para una variedad de propósitos, como recopilar datos para análisis, monitorizar cambios en sitios web, recopilar información para investigación, entre otros. Sin embargo, es importante utilizar técnicas de scraping de manera ética y respetando los términos de servicio de los sitios web, evitando sobrecargar los servidores o violar la privacidad de los usuarios. <br>

# Ejemplo de web scrapping con python

```python
	# Importamos las librerías necesarias para hacer el web scraping
import requests  # Para realizar solicitudes HTTP
from bs4 import BeautifulSoup  # Para analizar el contenido HTML

# Definimos la URL de la página que queremos scrapear
url = "http://quotes.toscrape.com/"

# Realizamos una solicitud GET para obtener el contenido de la página
response = requests.get(url)

# Verificamos si la solicitud fue exitosa (código de estado 200)
if response.status_code == 200:
    # Creamos un objeto BeautifulSoup para analizar el contenido HTML de la página
    soup = BeautifulSoup(response.content, "html.parser")
    
    # Buscamos todas las citas presentes en la página
    citas = soup.find_all("span", class_="text")
    
    # Buscamos todos los autores de las citas en la página
    autores = soup.find_all("small", class_="author")

    # Iteramos sobre las citas y los autores, e imprimimos cada cita con su respectivo autor
    for cita, autor in zip(citas, autores):
        print("Cita:", cita.get_text())  # Imprimimos la cita encontrada
        print("Autor:", autor.get_text())  # Imprimimos el autor de la cita
        print()  # Imprimimos una línea en blanco para separar las citas
else:
    # Si la solicitud no fue exitosa, imprimimos un mensaje de error junto con el código de estado
    print("Error al cargar la página:", response.status_code)
```
El primer paso es ver como está estructurada la web a scrapear, en este caso queremos sacar cita y autor de [http://quotes.toscrape.com](http://quotes.toscrape.com/). <br>

Podemos observar las etiquetas viendo su código fuente:

![](/assets/img/posts/scrapping/span.png)

Con las líneas 17 y 20 conseguimos capturar "text" que hace referencia a la cita y "author" que hace referencia al autor de dicha cita. <br>

Ahora solo queda crear un bucle que nos imprima todas las citas con sus respectivos autores, le podemos dar el formato que queramos (línea 23). <br>

El resultado en consola sería:

![](/assets/img/posts/scrapping/python.png)

Podemos guardar el stdout en otro archivo con:
```zsh
	python3 scrap.py > save.txt
```
Puedes visitar mi repositorio en github! [https://github.com/404azz/scrapperPython](https://github.com/404azz/scrapperPython)
