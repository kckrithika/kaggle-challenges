local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
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
                "port": portconfigs.sdc.canaryServicePort,
                "protocol": "TCP",
                "targetPort": portconfigs.sdc.canaryServicePort,
                "nodePort": portconfigs.sdc.canaryServiceNodePort
            }
            ],
                "selector": {
                    "name": "slb-canary",
                },
                "type": "NodePort",
        },
} else "SKIP"

