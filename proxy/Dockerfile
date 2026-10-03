# Imagen nginx utilizada como proxy reverso
FROM nginx:alpine

# nginx procesa automáticamente las variables de entorno
# presentes en los templates de este directorio.
COPY myconf.template /etc/nginx/templates/default.conf.template

# En producción el frontend nginx escucha en el puerto 80.
# Development sobrescribirá este valor mediante Docker Compose.
ENV PUERTO_FRONTEND=80

EXPOSE 80
