.PHONY: help build run stop test clean hooks

IMAGE_NAME := orders-microservice
IMAGE_TAG ?= 0.1.0

help:
	@echo "Comandos disponibles:"
	@echo "  make build       - Construir imagen Docker del microservicio"
	@echo "  make run         - Ejecutar contenedor Docker del microservicio"
	@echo "  make stop        - Detener y eliminar el contenedor"
	@echo "  make test        - Ejecutar tests"
	@echo "  make clean       - Limpiar cache y archivos temporales"
	@echo "  make hooks       - Instalar git hooks"

build:
	@echo "Construyendo imagen Docker $(IMAGE_NAME):$(IMAGE_TAG)..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .

run:
	@echo "Ejecutando contenedor Docker $(IMAGE_NAME)..."
	docker run -d \
		-p 80:80 \
		--name $(IMAGE_NAME) \
		$(IMAGE_NAME):$(IMAGE_TAG)

stop:
	@echo "Deteniendo y eliminando contenedor $(IMAGE_NAME)..."
	docker stop $(IMAGE_NAME) && docker rm $(IMAGE_NAME)

test:
	@echo "Ejecutando suite de pruebas..."
	pytest --cov=src test/

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage htmlcov dist build *.egg-info
	find . -type d -name .ruff_cache -exec rm -rf {} + 2>/dev/null || true

hooks:
	pre-commit install -c hooks/.pre-commit-config.yaml
