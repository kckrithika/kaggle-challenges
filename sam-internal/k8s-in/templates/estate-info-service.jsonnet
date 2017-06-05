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
                "port": 9090,
                "protocol": "TCP",
                "targetPort": 8080,
                "nodePort": 40000
            }
            ],
                "selector": {
                    "name": "estate-info",
                },
                "type": "NodePort",
        },
} else "SKIP"

