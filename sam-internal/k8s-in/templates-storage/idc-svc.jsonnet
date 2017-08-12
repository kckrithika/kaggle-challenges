local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "idc-svc",
            "namespace": "idc",
            "labels": {
                "app": "idc-samhello-deployment",
                "slb_vip": "sdp"
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

