.PHONY: help build run test clean hooks lint

help:
	@echo "Comandos disponibles:"
	@echo "  make build       - Instalar dependencias y ejecutar lint"
	@echo "  make run         - Ejecutar aplicación"
	@echo "  make test        - Ejecutar tests"
	@echo "  make lint        - Ejecutar linter (ruff)"
	@echo "  make clean       - Limpiar cache y archivos temporales"
	@echo "  make hooks       - Instalar git hooks"

build:
	pip install -r requirements.txt
	make lint

run: # TODO

test: # TODO

lint:
	ruff check . --config pyproject.toml

clean:
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache .coverage htmlcov dist build *.egg-info
	find . -type d -name .ruff_cache -exec rm -rf {} + 2>/dev/null || true

hooks: # TODO