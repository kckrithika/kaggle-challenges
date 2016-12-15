{
local configs = import "config.jsonnet",

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
                "protocol": "TCP",
                "port": 9098,
                "targetPort": 8080,
                "nodePort": 40000
            }
            ],
                "selector": {
                    "name": "k8sproxy",
                },
                "type": "NodePort",
        },
}

