local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-canary-service",
            namespace: "sam-system",
            labels: {
                app: "slb-canary-service",
                "slb.sfdc.net/name": "slb-canary-service",
            },
        },
        spec: {
            ports: [
            {
                name: "slb-canary-port",
                port: portconfigs.slb.canaryServicePort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServicePort,
                nodePort: portconfigs.slb.canaryServiceNodePort,
            },
            ],
                selector: {
                    name: "slb-canary",
                },
                type: "NodePort",
        },
} else "SKIP"
