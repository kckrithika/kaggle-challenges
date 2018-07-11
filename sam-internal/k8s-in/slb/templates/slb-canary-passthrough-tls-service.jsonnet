local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-canary-passthrough-tls-service",
        namespace: "sam-system",
        labels: {
            app: "slb-canary-passthrough-tls-service",
            "slb.sfdc.net/name": "slb-canary-pt-tls",
            "slb.sfdc.net/type": "none",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "slb-canary-pt-tls",
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
