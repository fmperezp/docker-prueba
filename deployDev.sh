#!/bin/sh

echo "Iniciando ambiente de desarrollo..."

docker compose -f docker-compose.development.yaml down

docker compose -f docker-compose.development.yaml up -d --build
