from httpx import AsyncClient, ASGITransport
from main import app
import pytest_asyncio
import pytest


@pytest_asyncio.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


@pytest.mark.asyncio
async def test_health(client):
    response = await client.get("/health")
    assert response.status_code == 200

    data = response.json()
    assert data["status"] == "OK"
    assert data["message"] == "Todos los recursos y servicios corriendo correctamente"


@pytest.mark.asyncio
async def test_orders(client):
    response = await client.get("/orders")
    assert response.status_code == 200

    orders = response.json()
    assert orders[0]["nombre"] == "Marco Serna"
    assert orders[0]["genero"] == "Masculino"
    assert orders[0]["edad"] == 45
    assert orders[0]["especialidad"] == "Ingeniero de sistemas"


@pytest.mark.asyncio
async def test_version(client):
    response = await client.get("/version")
    assert response.status_code == 200

    data = response.json()
    assert data["version"] == "1.0.0"
    assert data["message"] == "Servicios corriendo satisfactoriamente"
