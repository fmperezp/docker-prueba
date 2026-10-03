# -----------------------------
# Etapa de desarrollo
# -----------------------------
FROM node:20-alpine AS development

WORKDIR /backend

# Puerto utilizado por Fastify
EXPOSE 3000

# En desarrollo el código será montado mediante bind mount.
# El comando real se define desde docker compose.
CMD ["npm", "run", "dev"]


# -----------------------------
# Etapa de producción
# -----------------------------
FROM node:20-alpine AS production

WORKDIR /backend

# Copiamos primero package.json para aprovechar la cache de Docker
COPY package*.json ./

# Instalamos solamente dependencias necesarias
RUN npm install --omit=dev

# Copiamos el código de la aplicación
COPY . .

EXPOSE 3000

CMD ["npm", "start"]
