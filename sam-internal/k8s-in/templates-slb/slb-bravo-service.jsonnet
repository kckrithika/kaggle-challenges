local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "slb-bravo-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "slb-bravo-svc",
                "slb_vip": "slb-bravo-svc"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "slb-bravo-port",
                "port": 9090,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": 32138
            }
            ],
                "selector": {
                    "name": "slb-bravo",
                },
                "type": "NodePort",
        },
} else "SKIP"

