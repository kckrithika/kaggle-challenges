local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    "kind": "Service",
        "apiVersion": "v1",
        "metadata": {
            "name": "sdn-control-svc",
            "namespace": "sdn-control",
        },
        "spec": {
            "ports": [
            {
                "name": "sdn-control-port",
                "port": portconfigs.sdn.sdn_control_service,
                "protocol": "TCP",
                "targetPort": portconfigs.sdn.sdn_control_service,
            }
            ],
                "selector": {
                    "name": "sdn-control",
                },
        },
} else "SKIP"
