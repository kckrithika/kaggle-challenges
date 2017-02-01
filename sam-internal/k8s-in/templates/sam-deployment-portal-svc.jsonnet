local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "portal-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "sam-deployment-portal"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "portal-port",
                "port": 64123,
                "protocol": "TCP",
                "targetPort": 64123,
                "nodePort": 39999
            }
            ],
                "selector": {
                    "name": "sam-deployment-portal",
                },
                "type": "NodePort",
        },
} else "SKIP"

