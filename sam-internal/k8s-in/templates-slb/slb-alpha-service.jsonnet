local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "slb-alpha-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "slb-alpha-svc",
                "slb_vip": "slb-alpha-svc",
                "slb.sfdc.net/name": "slb-alpha-svc"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "slb-alpha-port",
                "port": 9008,
                "protocol": "TCP",
                "targetPort": 9008,
                "nodePort": portconfigs.slb.alphaServiceNodePort
            }
            ],
                "selector": {
                    "name": "slb-alpha",
                },
                "type": "NodePort",
        },
} else "SKIP"

