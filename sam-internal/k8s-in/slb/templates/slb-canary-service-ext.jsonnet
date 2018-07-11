local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "xrd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-canary-service-ext",
        namespace: "sam-system",
        labels: {
            app: "slb-canary-service",
            "slb.sfdc.net/name": "slb-canary-service-ext",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "slb-canary-service-ext",
        },
    },
    spec: {
        ports: [
            {
                name: "slb-canary-port",
                port: portconfigs.slb.canaryServicePort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServicePort,
            },
            {
                name: "slb-canary-tls",
                port: portconfigs.slb.canaryServiceTlsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceTlsPort,
            },
        ],
        selector: {
            name: "slb-canary",
        },
        type: "NodePort",
    },
} else "SKIP"
