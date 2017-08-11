local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "slb-bravo-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "slb-bravo-svc",
                "slb_vip": "slb-bravo-svc",
                "slb.sfdc.net/name": "slb-bravo-svc"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "slb-bravo-port",
                "port": 9090,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": portconfigs.slb.bravoServiceNodePort
            }
            ],
                "selector": {
                    "name": "slb-bravo",
                },
                "type": "NodePort",
        },
} else "SKIP"

