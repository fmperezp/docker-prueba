#!/bin/sh

# Cargamos las variables definidas en .env
set -a
. ./.env
set +a

echo "Generando imágenes de producción..."

docker build --target production -t ${REPOSITORIO}/backend:latest ./backend
docker build --target production -t ${REPOSITORIO}/frontend:latest ./frontend
docker build -t ${REPOSITORIO}/database:latest ./database
docker build -t ${REPOSITORIO}/proxy:latest ./proxy

echo "Subiendo imágenes al repositorio remoto..."

docker push ${REPOSITORIO}/backend:latest
docker push ${REPOSITORIO}/frontend:latest
docker push ${REPOSITORIO}/database:latest
docker push ${REPOSITORIO}/proxy:latest
