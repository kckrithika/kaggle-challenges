local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "idc-svc",
            "namespace": "idc",
            "labels": {
                "app": "idc-centos-deployment",
                "slb_vip": "sdp"
            },
        },
        "spec": {
            "ports": [
            {
                "name": "portal-port",
                "port": 59999,
                "protocol": "TCP",
                "targetPort": 59999,
                "nodePort": 59999
            }
            ],
                "selector": {
                    "name": "idc-centos-deployment",
                },
                "type": "NodePort",
        },
} else "SKIP"

