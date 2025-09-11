# ─────────────────────────────────────────────
# Stage 0: ARGs y base
# ─────────────────────────────────────────────
ARG NODE_VERSION=19
ARG APP_DIR=/app
ARG APP_USER=appuser

# ─────────────────────────────────────────────
# Stage 1: deps-dev → instala deps (incluye dev) usando caché
# ─────────────────────────────────────────────
FROM node:${NODE_VERSION}-slim AS deps-dev
ARG APP_DIR
WORKDIR ${APP_DIR}

# Copiamos solo manifests para aprovechar caché de npm ci
COPY package.json package-lock.json ./
# Instala TODAS las deps (incluyendo dev) para correr tests en el siguiente stage
RUN npm ci


# ─────────────────────────────────────────────
# Stage 2: test-runner → ejecuta tests (no llega a producción)
# ─────────────────────────────────────────────
FROM node:${NODE_VERSION}-slim AS test-runner
ARG APP_DIR
WORKDIR ${APP_DIR}

# Reutiliza node_modules del stage anterior
COPY --from=deps-dev ${APP_DIR}/node_modules ./node_modules
# Copia el código fuente y demás ficheros necesarios para test
COPY . .

ENV NODE_ENV=test
# Si no tienes tests aún, esto no fallará gracias a --if-present
RUN npm test --if-present


# ─────────────────────────────────────────────
# Stage 3: prod-deps → instala SOLO deps de producción
# (más pequeño que copiar node_modules del test)
# ─────────────────────────────────────────────
FROM node:${NODE_VERSION}-slim AS prod-deps
ARG APP_DIR
WORKDIR ${APP_DIR}

COPY package.json package-lock.json ./
# Instala únicamente dependencias de producción
RUN npm ci --omit=dev && npm cache clean --force


# ─────────────────────────────────────────────
# Stage 4: runtime → imagen final mínima, no-root
# ─────────────────────────────────────────────
FROM node:${NODE_VERSION}-slim AS runtime
ARG APP_DIR APP_USER
WORKDIR ${APP_DIR}

# Crea usuario no-root dedicado
RUN useradd -m -d /home/${APP_USER} -s /usr/sbin/nologin ${APP_USER}

# Copia solo lo necesario para ejecutar en prod
COPY --from=prod-deps ${APP_DIR}/node_modules ./node_modules
COPY package.json ./
COPY app.js ./app.js

ENV NODE_ENV=production \
    PORT=8080
EXPOSE 8080

# Opcional: healthcheck básico
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:' + (process.env.PORT||8080) + '/health').then(r=>{if(!r.ok)process.exit(1)}).catch(()=>process.exit(1))"

USER ${APP_USER}
CMD ["node", "app.js"]


# ─────────────────────────────────────────────
# Stage 5: debug (opcional) → herramientas útiles
# ─────────────────────────────────────────────
FROM runtime AS debug
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl iputils-ping dnsutils vim \
  && rm -rf /var/lib/apt/lists/*
USER ${APP_USER}