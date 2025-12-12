import argparse
from kubernetes import client, config


def actualizar_servicio(namespace, service_name, new_selector):
    try:
        config.load_kube_config()
    except config.ConfigException:
        config.load_incluster_config()

    v1 = client.CoreV1Api()

    patch_body = {"spec": {"selector": new_selector}}

    try:
        response = v1.patch_namespaced_service(
            name=service_name, namespace=namespace, body=patch_body, async_req=False
        )
        print(f"Servicio actualizado '{service_name}' a '{response.spec.selector}'")
    except client.ApiException as e:
        print(f"Error al actualizar servicio: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("color", choices=["blue", "green"])
    args = parser.parse_args()

    actualizar_servicio(
        "default", "orders-service", {"app": "orders", "color": args.color}
    )
