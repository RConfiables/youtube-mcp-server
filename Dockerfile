# Etapa 1: Construcción
FROM node:18-alpine AS builder

# Directorio de trabajo
WORKDIR /app

# Copiar archivos clave
COPY package.json package-lock.json tsconfig.json ./

# Instalar dependencias
RUN npm install

# Copiar el resto del código
COPY . .

# Compilar TypeScript
RUN npm run build

# Etapa 2: Imagen final ligera
FROM node:18-alpine AS release

WORKDIR /app

# Copiar build y archivos de producción
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json /app/package-lock.json ./

# Instalar solo dependencias de producción
RUN npm ci --only=production

# Exponer el puerto requerido por Cloud Run
ENV PORT=8080
EXPOSE 8080

# Comando de arranque
CMD ["node", "dist/index.js"]
