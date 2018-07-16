local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "sdn-control-svc",
            namespace: "sam-system",
            labels: {} + configs.ownerLabel.sdn,
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
