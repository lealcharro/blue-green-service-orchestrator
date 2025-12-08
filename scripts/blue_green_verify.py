import os
import sys
import requests
from dotenv import load_dotenv

load_dotenv()


def get_app_version(url: str) -> str:
    """Accede al endpoint /version y retorna la version de la app."""
    try:
        response = requests.get(f"{url}/version")
        response.raise_for_status()
        return response.json()["version"]
    except requests.exceptions.RequestException as e:
        print(f"Error al intentar obtener la versión de la app: {e}")
        sys.exit(1)


def main():
    """Implementación principal del script de smoke test."""
    try:
        url = os.environ["URL"]
        expected_version = os.environ["VERSION"]
    except KeyError:
        print("Las variables de entorno URL y VERSION son requeridas")
        sys.exit(1)

    app_version = get_app_version(url)

    if app_version == expected_version:
        print(
            f"""
            Smoke test exitoso.
            - Versión esperada: '{expected_version}'
            - versión obtenida: '{app_version}'
            """
        )
        sys.exit(0)
    else:
        print(
            f"""
            Smoke test fallido.
            - Versión esperada: '{expected_version}'
            - versión obtenida: '{app_version}'
            """
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
