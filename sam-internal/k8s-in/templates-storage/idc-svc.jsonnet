local configs = import "config.jsonnet";

# Disabled due to error with port already allocated
#if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
if "0" == "1" then {
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
                "port": 9090,
                "protocol": "TCP",
                "targetPort": 9090,
                "nodePort": 33333
            }
            ],
                "selector": {
                    "name": "idc-samhello",
                },
                "type": "NodePort",
        },
} else "SKIP"

