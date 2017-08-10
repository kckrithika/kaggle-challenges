local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
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
                "nodePort": portconfigs.slb.alphaServiceNodePort
            }
            ],
                "selector": {
                    "name": "slb-alpha",
                },
                "type": "NodePort",
        },
} else "SKIP"

