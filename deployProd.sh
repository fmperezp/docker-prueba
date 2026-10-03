#!/bin/sh

echo "Deteniendo ambiente anterior..."
docker compose -f docker-compose.production.yaml down --remove-orphans

echo "Buscando versiones nuevas de las imagenes..."
docker compose -f docker-compose.production.yaml pull

echo "Iniciando ambiente de produccion..."
docker compose -f docker-compose.production.yaml up -d
