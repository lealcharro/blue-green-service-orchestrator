.PHONY: help build run test clean hooks

help:
	@echo "Comandos disponibles:"
	@echo "  make build       - Instalar dependencias"
	@echo "  make run         - Ejecutar aplicación"
	@echo "  make test        - Ejecutar tests"
	@echo "  make clean       - Limpiar cache y archivos temporales"
	@echo "  make hooks       - Instalar git hooks"

build:
	pip install -r requirements.txt

run: # TODO

test: # TODO

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage htmlcov dist build *.egg-info
	find . -type d -name .ruff_cache -exec rm -rf {} + 2>/dev/null || true

hooks:
	pre-commit install -c hooks/.pre-commit-config.yaml