# Prueba final Docker

Proyecto realizado como prueba final del curso Docker.

La solución implementa una aplicación web con ambientes de desarrollo y producción utilizando Docker Compose, imágenes Docker propias, redes, volúmenes, bind mounts, variables de entorno y publicación de imágenes en GitHub Container Registry.

## Arquitectura general

La solución está compuesta por cuatro servicios:

- frontend
- backend
- database
- proxy

El navegador accede al servicio proxy, que redirige las solicitudes al frontend o al backend según corresponda.

El backend se comunica con la base de datos PostgreSQL.

## Servicios

### frontend

Aplicación web estática.

En desarrollo se ejecuta utilizando Node y `http-server` en el puerto 4200.

En producción se sirve utilizando nginx en el puerto 80.

El código fuente se monta mediante un bind mount en el ambiente de desarrollo, por lo que los cambios realizados en el archivo `index.html` se reflejan al actualizar la página sin necesidad de reconstruir la imagen.

### backend

API desarrollada en Node.js utilizando Fastify.

Escucha en el puerto 3000 y se conecta al servicio PostgreSQL.

Expone el siguiente endpoint:

- `/api/db`

El endpoint `/api/db` permite comprobar tanto el funcionamiento del backend como la conexión con PostgreSQL.

En desarrollo se utiliza `node --watch`, por lo que los cambios realizados en el código fuente provocan automáticamente el reinicio del backend.

### database

Base de datos PostgreSQL utilizada por el backend.

Los parámetros de conexión se configuran mediante variables de entorno definidas en el archivo `.env`.

### proxy

Proxy reverso implementado con nginx.

Es el único servicio que publica el puerto 80 hacia el host.

Redirige:

- `/` hacia el servicio frontend
- las solicitudes `/api` hacia el servicio backend

Actualmente el endpoint implementado por el backend es:

```text
/api/db
```

El puerto utilizado por el frontend se configura mediante la variable:

```text
PUERTO_FRONTEND
```

En desarrollo el frontend utiliza el puerto 4200 y en producción utiliza el puerto 80.

## Redes

La solución utiliza dos redes Docker:

```text
red_front
red_data
```

Distribución de los servicios:

```text
proxy     -> red_front
frontend  -> red_front
backend   -> red_front y red_data
database  -> red_data
```

El backend pertenece a todas las redes de la solución.

El resto de los servicios pertenece solamente a las redes necesarias para su funcionamiento.

## Variables de entorno

Las variables utilizadas por la solución se encuentran en el archivo:

```text
.env
```

Contenido utilizado:

```env
REPOSITORIO=ghcr.io/fmperezp
PGDATABASE=pruebadocker
PGUSER=postgres
PGPASSWORD=postgres
PGHOST=database
```

La variable `REPOSITORIO` define el repositorio remoto utilizado para almacenar las imágenes Docker.

## Ambiente de desarrollo

El archivo utilizado para desarrollo es:

```text
docker-compose.development.yaml
```

Este archivo utiliza `extends` para reutilizar la configuración definida en:

```text
docker-compose.production.yaml
```

Las imágenes de desarrollo tienen el formato:

```text
ghcr.io/fmperezp/servicio:development
```

Por ejemplo:

```text
ghcr.io/fmperezp/backend:development
ghcr.io/fmperezp/frontend:development
ghcr.io/fmperezp/database:development
ghcr.io/fmperezp/proxy:development
```

Para iniciar el ambiente de desarrollo ejecutar:

```bash
./deployDev.sh
```

El script detiene previamente el ambiente existente y luego ejecuta Docker Compose utilizando la opción `--build`.

Esto provoca que Docker siempre verifique si es necesario reconstruir las imágenes.

El frontend y el backend utilizan bind mounts para montar el código fuente del host dentro de los contenedores.

Gracias a esto, las modificaciones realizadas durante el desarrollo pueden verse sin reconstruir manualmente las imágenes.

## Ambiente de producción

El archivo utilizado para producción es:

```text
docker-compose.production.yaml
```

El compose de producción no contiene instrucciones `build`.

Utiliza exclusivamente imágenes remotas con el tag:

```text
latest
```

Por ejemplo:

```text
ghcr.io/fmperezp/backend:latest
ghcr.io/fmperezp/frontend:latest
ghcr.io/fmperezp/database:latest
ghcr.io/fmperezp/proxy:latest
```

Para desplegar el ambiente de producción ejecutar:

```bash
./deployProd.sh
```

El script realiza los siguientes pasos:

1. Detiene el ambiente anterior.
2. Ejecuta `docker compose pull`.
3. Comprueba si existen versiones nuevas de las imágenes remotas.
4. Inicia el ambiente de producción.

De esta forma, antes de iniciar producción siempre se verifica si existen cambios en las imágenes utilizadas.

Como las imágenes de GitHub Container Registry están configuradas como públicas, no es necesario autenticarse para descargarlas ni para desplegar el ambiente de producción.

## Generación y publicación de imágenes

Las imágenes de producción se generan y publican utilizando el script:

```bash
./push.sh
```

Para subir imágenes a GitHub Container Registry sí es necesario estar autenticado con permisos de escritura.

Ejemplo:

```bash
docker login ghcr.io
```

El script carga las variables definidas en `.env`, genera las imágenes con tag `latest` y las publica en GitHub Container Registry.

Las imágenes generadas son:

```text
ghcr.io/fmperezp/backend:latest
ghcr.io/fmperezp/frontend:latest
ghcr.io/fmperezp/database:latest
ghcr.io/fmperezp/proxy:latest
```

Los paquetes publicados en GitHub Container Registry están configurados como públicos.

Por lo tanto, pueden descargarse sin autenticación. Por ejemplo:

```bash
docker pull ghcr.io/fmperezp/backend:latest
```

## Volúmenes

La solución utiliza un volumen Docker denominado:

```text
datos_compartidos
```

Este volumen es utilizado por los servicios:

```text
backend
database
```

Esto permite demostrar el uso de un mismo volumen por más de un contenedor.

## Bind mounts

En el ambiente de desarrollo se utilizan bind mounts para frontend y backend.

Frontend:

```text
./frontend:/frontend
```

Backend:

```text
./backend:/backend
```

Esto permite modificar el código fuente directamente desde el host y observar los cambios al actualizar la aplicación.

## Dockerfiles

Existen Dockerfiles para:

```text
frontend
backend
database
proxy
```

Los Dockerfiles de frontend y backend utilizan multistage builds.

Esto permite disponer de una etapa específica para desarrollo y otra para producción.

Los Dockerfiles incluyen comentarios explicando las distintas etapas e instrucciones.

## Acceso a la aplicación

Con el ambiente iniciado, la aplicación está disponible en:

```text
http://localhost
```

Para comprobar directamente el backend y la conexión con PostgreSQL se puede utilizar:

```text
http://localhost/api/db
```

## Scripts disponibles

```text
deployDev.sh
deployProd.sh
push.sh
```

### deployDev.sh

Inicia el ambiente de desarrollo y fuerza la comprobación del build de las imágenes.

### deployProd.sh

Descarga las versiones más recientes de las imágenes públicas y despliega el ambiente de producción.

No requiere autenticación para descargar las imágenes, ya que los paquetes son públicos.

### push.sh

Construye las imágenes de producción con tag `latest` y las publica en el repositorio remoto.

Este script sí requiere autenticación en GitHub Container Registry con permisos de escritura.

## Autor

Francisco Perez
