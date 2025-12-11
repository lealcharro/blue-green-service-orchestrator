.PHONY: help build run stop test clean hooks setup verify port-forward

IMAGE_NAME := orders-microservice
IMAGE_TAG ?= v2

help:
	@echo "Comandos disponibles:"
	@echo "  make setup       - Iniciar Minikube"
	@echo "  make build       - Construir imagen Docker del microservicio"
	@echo "  make run         - Desplegar la aplicación en Kubernetes"
	@echo "  make stop        - Eliminar recursos de Kubernetes y detener Minikube"
	@echo "  make test        - Ejecutar tests"
	@echo "  make clean       - Limpiar cache y archivos temporales"
	@echo "  make hooks       - Instalar git hooks"
	@echo "  make verify      - Ejecutar script de smoke test (requiere VERSION=v1|v2)"
	@echo "  make port-forward - Iniciar port-forwarding para orders-service"

setup:
	@echo "Iniciando Minikube..."
	minikube start

build:
	@echo "Construyendo imagen Docker $(IMAGE_NAME):$(IMAGE_TAG)..."
ifeq ($(CI),true)
	@echo "Entorno CI detectado. Usando Docker y Kind."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "Cargando imagen en el clúster de Kind..."
	kind load docker-image $(IMAGE_NAME):$(IMAGE_TAG)
else
	@echo "Entorno local detectado. Usando Minikube."
	eval $$(minikube -p minikube docker-env) && docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
endif

run:
	@echo "Desplegando la aplicación en Kubernetes..."
	kubectl apply -f k8s/

stop:
	@echo "Eliminando recursos de Kubernetes y deteniendo Minikube..."
	-kubectl delete -f k8s/
	minikube stop

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

port-forward:
	@echo "Iniciando port-forwarding para orders-service en localhost:8080. Presiona Ctrl+C para detener."
	kubectl port-forward svc/orders-service 8080:80
