local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-samtest" then {
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
                "port": 64121,
                "protocol": "TCP",
                "targetPort": 64121,
                "nodePort": 39999
            }
            ],
                "selector": {
                    "name": "sam-deployment-portal",
                },
                "type": "NodePort",
        },
} else "SKIP"

