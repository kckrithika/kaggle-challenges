local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-canary-passthrough-tls-service",
            namespace: "sam-system",
            labels: {
                app: "slb-canary-passthrough-tls-service",
                "slb.sfdc.net/name": "slb-canary-pt-tls",
                "slb.sfdc.net/type": "passthrough",
            },
        },
        spec: {
            ports: [
            {
                name: "slb-canary-passthrough-tls-port",
                port: portconfigs.slb.canaryServicePassthroughTlsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServicePassthroughTlsPort,
            },
            ],
            selector: {
                name: "slb-canary-passthrough-tls",
            },
            type: "NodePort",
        },
} else "SKIP"
