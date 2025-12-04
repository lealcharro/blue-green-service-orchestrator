# Etapa de construcción 
FROM python:3.12-slim AS builder

# Evitar archivos .pyc y forzar salida no bufferizada
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /build

# Copiar dependencias y resolverlas en el usuario actual
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Etapa de producción 
FROM python:3.12-slim AS production

# Usuario y grupo de la aplicación
ARG APP_USER=appuser
RUN groupadd -r ${APP_USER} \
    && useradd -m -r -g ${APP_USER} ${APP_USER}

# Variables de entorno para el usuario no root
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/${APP_USER}/.local/bin:${PATH}"

WORKDIR /app

# Instalar curl para HEALTHCHECK
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Copiar binarios y dependencias instaladas
COPY --from=builder /root/.local /home/${APP_USER}/.local

# Copiar el código fuente de la aplicación
COPY src/ /app/

# Asegurar que el usuario de la aplicación sea el propietario de /app
RUN chown -R ${APP_USER}:${APP_USER} /app

# Ejecutar como usuario no root
USER ${APP_USER}

# Healthcheck para verificar que la aplicación esté funcionando
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD curl --fail http://localhost:80/health || exit 1

EXPOSE 80

# Comando por defecto
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]