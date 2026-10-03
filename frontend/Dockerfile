# -----------------------------
# Etapa de desarrollo
# -----------------------------
FROM node:20-alpine AS development

WORKDIR /frontend

RUN npm install -g http-server

EXPOSE 4200

CMD ["http-server", "-p", "4200", "-c-1"]


# -----------------------------
# Etapa de producción
# -----------------------------
FROM nginx:alpine AS production

COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
