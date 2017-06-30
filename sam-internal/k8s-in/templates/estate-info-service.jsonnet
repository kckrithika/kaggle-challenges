local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "estate-info-service",
            "namespace": "sam-system",
            "labels": {
                "app": "estate-info"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "estate-info-port",
                "port": 8080,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": 40001
            }
            ],
                "selector": {
                    "name": "estate-info-server",
                },
                "type": "NodePort",
        },
} else "SKIP"

