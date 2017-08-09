local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "estate-service",
            "namespace": "sam-system",
            "labels": {
                "app": "estate-server"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "estate-port",
                "port": 8080,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": 32999
            }
            ],
                "selector": {
                    "name": "estate-server",
                },
                "type": "NodePort",
        },
} else "SKIP"

