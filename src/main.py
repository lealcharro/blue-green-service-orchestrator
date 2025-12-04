from fastapi import FastAPI, status
from config import VERSION
import uvicorn
import json
import os

app = FastAPI()


@app.get("/health", status_code=status.HTTP_200_OK)
async def health_check():
    return {
        "status": "OK",
        "message": "Todos los recursos y servicios corriendo correctamente",
    }


@app.get("/orders", status_code=status.HTTP_200_OK)
def orders():
    with open(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "data", "orders.json"),
        "r",
    ) as file:
        orders = json.load(file)
    return orders


@app.get("/version")
async def get_versions():
    return {"version": VERSION, "message": "Servicios corriendo satisfactoriamente"}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
