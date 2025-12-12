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

## Sprint 2

- Manifests de Kubernetes para estrategia Blue/Green
- Deployment Blue (v1) y Green (v2) en paralelo
- Service con selector dinámico para switch de tráfico
- Script de verificación (smoke tests) con `blue_green_verify.py`
- Configuración de Minikube/Kind para cluster local
- Port-forwarding para acceso local al servicio
- Comandos Makefile para gestión completa del ciclo Blue/Green

## Sprint 3

- Pipeline automatizado de despliegue Blue/Green (`blue_green_deploy.yml`)
- Script de switch automatizado entre versiones (`blue_green_switch.py`)
- Pipeline de generación de evidencias (`generate_evidence.yml`)
- Historial de despliegues Blue/Green (`blue-green-history.json`)
- Detección automática de entorno CI/local en Makefile
- Rollback automático en pipeline si fallan smoke tests
- Evidencias almacenadas en `.evidence/`

## Uso Rápido

### Despliegue Blue/Green (Kubernetes)
```bash
# 1. Iniciar Minikube
make setup
# 2. Construir imagen v1 (Blue)
make build IMAGE_TAG=v1
# 3. Construir imagen v2 (Green)
make build IMAGE_TAG=v2
# 4. Desplegar ambas versiones en K8s
make run
# 5. Port-forward para acceso local (en otra terminal)
make port-forward
# 6. Verificar versión activa (Blue=v1 inicialmente)
curl http://localhost:8080/version
# 7. Smoke test de versión específica
URL=http://localhost:8080 VERSION=v1 python scripts/blue_green_verify.py
# 8. Switch de Blue a Green (manual)
kubectl patch service orders-service -p '{"spec":{"selector":{"color":"green"}}}'
# 9. Verificar cambio a Green (v2)
curl http://localhost:8080/version
# 10. Rollback a Blue (si es necesario)
kubectl patch service orders-service -p '{"spec":{"selector":{"color":"blue"}}}'
# Limpiar todo
make stop
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
- `make setup` - Inicia Minikube
- `make build` - Construye imagen Docker (uso: `IMAGE_TAG=v1`)
- `make run` - Despliega aplicación en Kubernetes
- `make stop` - Elimina recursos de K8s y detiene Minikube
- `make test` - Ejecuta tests con cobertura
- `make clean` - Elimina archivos temporales
- `make hooks` - Instala pre-commit hooks
- `make port-forward` - Port-forward de orders-service a localhost:8080

## Estructura

```
.
├── .github/workflows/
│   ├── ci.yml                 # CI pipeline
│   └── build_scan_sbom.yml    # Security pipeline
├── hooks/
│   └── .pre-commit-config.yaml
├── k8s/                       # Manifests Kubernetes
│   ├── orders-v1-blue.yaml    # Deployment Blue (v1)
│   ├── orders-v2-green.yaml   # Deployment Green (v2)
│   └── service.yaml           # Service con selector dinámico
├── scripts/
│   └── blue_green_verify.py   # Script de smoke tests
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

### k8s/
Manifests de Kubernetes para estrategia Blue/Green:
- **orders-v1-blue.yaml**: Deployment con 3 réplicas, label `color: blue`, variable `VERSION=v1`
- **orders-v2-green.yaml**: Deployment con 3 réplicas, label `color: green`, variable `VERSION=v2`
- **service.yaml**: Service con selector `color: blue` (por defecto), exponiendo puerto 80

### scripts/
Script de verificación y smoke tests:
- **blue_green_verify.py**: Valida que la versión desplegada sea la esperada
- Requiere variables de entorno: `URL` y `VERSION`
- Hace petición a `/version` y compara con versión esperada
- Retorna código de salida 0 (éxito) o 1 (fallo)
- Uso: `URL=http://localhost:8080 VERSION=v1 python scripts/blue_green_verify.py`

## Estrategia Blue/Green

El proyecto implementa un patrón de despliegue Blue/Green en Kubernetes:

1. **Despliegues Paralelos**: Las versiones Blue (v1) y Green (v2) están desplegadas simultáneamente con 3 réplicas cada una
2. **Switch de Tráfico**: El Service de Kubernetes usa labels (`color: blue` o `color: green`) para enrutar el tráfico
3. **Sin Downtime**: El cambio de versión es instantáneo mediante `kubectl patch`
4. **Rollback Rápido**: Si hay problemas, volver a la versión anterior es inmediato (un simple patch)
5. **Verificación**: Script de smoke tests valida que la versión activa sea la correcta

## Evidencias DevSecOps

Todas las evidencias de ejecución de herramientas DevSecOps se almacenan en `.evidence/`:

**GitHub Actions**:
- `sbom.json` - Software Bill of Materials

**Security Tab** (GitHub):
- Resultados en: `Security > Code scanning`

## Videos

- **Sprint 1**: https://drive.google.com/file/d/1eFvE2q8g4w0fNAz9NkAlTg9-r5a8vSkM/view?usp=sharing
- **Sprint 2**: https://drive.google.com/file/d/1DZHmfj29uhap1lofZWUzk3_UdyOWcXHo/view?usp=sharing
- **Sprint 3**: https://drive.google.com/file/d/1ZlwkM5mmx1xOef71uJuPJPgQqpMbO5Eu/view?usp=sharing
