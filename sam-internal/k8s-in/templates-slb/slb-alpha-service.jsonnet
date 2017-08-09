local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "slb-alpha-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "slb-alpha-svc",
                "slb_vip": "slb-alpha-svc"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "slb-alpha-port",
                "port": 9090,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": 32137
            }
            ],
                "selector": {
                    "name": "slb-alpha",
                },
                "type": "NodePort",
        },
} else "SKIP"

