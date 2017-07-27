local configs = import "config.jsonnet";
if configs.kingdom == "prd" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "portal-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "sam-deployment-portal",
                "slb_vip": "sdp"
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

