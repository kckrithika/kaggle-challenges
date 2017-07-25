local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "slb-canary-service",
            "namespace": "sam-system",
            "labels": {
                "app": "slb-canary-service",
                "slb_vip": "slb-canary-service"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "slb-canary-port",
                "port": 9000,
                "protocol": "TCP",
                "targetPort": 9000,
                "nodePort": slbconfigs.canaryServicePort
            }
            ],
                "selector": {
                    "name": "slb-canary",
                },
                "type": "NodePort",
        },
} else "SKIP"

