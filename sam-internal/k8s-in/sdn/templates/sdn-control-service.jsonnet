local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "sdn-control-svc",
            namespace: "sam-system",
        },
        spec: {
            clusterIP: "10.254.219.222",
            ports: [
                {
                    name: "sdn-control-port",
                    port: portconfigs.sdn.sdn_control_service,
                    protocol: "TCP",
                    targetPort: portconfigs.sdn.sdn_control_service,
                },
            ],
            selector: {
                name: "sdn-control",
            },
        },
} else "SKIP"
