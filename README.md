# Proyecto 7: Blue-Green Service Orchestrator

## Integrantes

 - Chacón Roque, Leonardo
 - Delgado Velarde, Diego
 - Flores Alberca, Aarón

## Descripción

Un equipo de plataforma quiere estandarizar la forma de hacer blue/green deploys para un microservicio Python con tres requerimientos: Versión "blue" ejecutándose, versión "green" desplegada en paralelo y switch de tráfico sin downtime, con rollback rápido si algo sale mal.

## Sprint 1

- Microservicio FastAPI con 3 endpoints: `/health`, `/orders`, `/version`
- Dockerfile multi-stage con usuario no-root
- Tests con pytest y cobertura de código
- Pre-commit hooks (Black, Flake8, Gitleaks)
- Pipeline CI con lint, format y test
- Pipeline de seguridad con Trivy y SBOM
- Makefile para automatización

## Uso Rápido

```bash
# Instalar hooks
make hooks

# Ejecutar tests
make test

# Build y run
make build
make run

# Probar endpoints
curl http://localhost:8080/health
curl http://localhost:8080/orders
curl http://localhost:8080/version

# Limpiar
make stop
make clean
```

## Pipelines CI/CD

### ci.yml
Ejecuta en push a `main`, `develop`, `feature/**`:

1. **lint** - Para verificar calidad del código con `ruff check`
2. **format** - Para validar formato con `ruff format --check`
3. **test** - Para ejecutar tests y subir cobertura a Codecov

### build_scan_sbom.yml
Ejecuta en push a `main`/`develop` o manualmente:

1. **build_scan_sbom** - Para construir imagen, escanear con Trivy y generar SBOM

**Nota**: Este pipeline usa `runs-on: ubuntu-latest` pero interactúa con Docker.

## Pre-commit Hooks

- **check-added-large-files** - Para prevenir archivos >5MB
- **requirements-txt-fixer** - Para ordenar requirements.txt
- **black** - Para formatear código automáticamente
- **flake8** - Para análisis estático (max 88 chars, ignora E203/W503)
- **gitleaks** - Para detectar secretos (no-bloqueante)

## Makefile

- `make help` - Muestra comandos disponibles
- `make build` - Construye imagen Docker
- `make run` - Ejecuta contenedor en puerto 8080
- `make stop` - Detiene contenedor
- `make test` - Ejecuta tests con cobertura
- `make clean` - Elimina archivos temporales
- `make hooks` - Instala pre-commit hooks

## Estructura

```
.
├── .github/workflows/
│   ├── ci.yml                 # CI pipeline
│   └── build_scan_sbom.yml    # Security pipeline
├── hooks/
│   └── .pre-commit-config.yaml
├── src/
│   ├── main.py                # FastAPI app
│   ├── config.py
│   └── data/orders.json
├── test/
│   ├── conftest.py
│   └── test_endpoints.py
├── Dockerfile                 # Multi-stage build
├── Makefile
└── requirements.txt
```

## Componentes Principales

### Dockerfile
Multi-stage build con seguridad:
- **Etapa builder**: Instala dependencias en usuario temporal
- **Etapa production**: Imagen final slim con usuario no-root (appuser)
- **Healthcheck**: Verifica endpoint `/health` cada 30s
- Expone puerto 80, ejecuta con uvicorn

### src/
Código fuente del microservicio:
- **main.py**: Aplicación FastAPI con 3 endpoints REST
- **config.py**: Configuración y variables (VERSION)
- **data/orders.json**: Datos de ejemplo para endpoint `/orders`

### test/
Suite de pruebas con pytest:
- **conftest.py**: Fixtures de pytest (cliente de test)
- **test_endpoints.py**: Tests para `/health`, `/orders`, `/version`
- Ejecuta con cobertura usando `pytest --cov`

## Evidencias DevSecOps

Todas las evidencias de ejecución de herramientas DevSecOps se almacenan en `.evidence/`:

**GitHub Actions**:
- `sbom.json` - Software Bill of Materials

**Security Tab** (GitHub):
- Resultados en: `Security > Code scanning`

## Videos

- **Sprint 1**: https://drive.google.com/file/d/1eFvE2q8g4w0fNAz9NkAlTg9-r5a8vSkM/view?usp=sharing