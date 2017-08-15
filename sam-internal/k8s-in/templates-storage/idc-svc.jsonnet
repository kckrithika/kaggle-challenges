local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "idc-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "idc-samhello-deployment",
                "slb_vip": "idc",
                "slb.sfdc.net/name": "idc"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "idc-samhello-port",
                "port": 9090,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": 33333
            }
            ],
                "selector": {
                    "name": "idc-samhello-deployment",
                },
                "type": "NodePort",
        },
} else "SKIP"

