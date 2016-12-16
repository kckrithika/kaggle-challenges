local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "k8sproxy-service",
            "namespace": "sam-system",
            "labels": {
                "app": "k8sproxy"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "k8sproxy-port",
                "port": 9098,
                "protocol": "TCP",
                "targetPort": 8080,
                "nodePort": 40000
            }
            ],
                "selector": {
                    "name": "k8sproxy",
                },
                "type": "NodePort",
        },
} else "SKIP"

