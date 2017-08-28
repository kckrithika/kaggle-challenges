local configs = import "config.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "idc-svc",
            "namespace": "sam-system",
            "labels": {
                "app": "idc-samhello",
                "slb.sfdc.net/name": "idc"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "idc-samhello-port",
                "port": 9078,
                "protocol": "TCP",
                "targetPort": 9078,
                "nodePort": 33333
            }
            ],
                "selector": {
                    "name": "idc-samhello",
                },
                "type": "NodePort",
        },
} else "SKIP"

