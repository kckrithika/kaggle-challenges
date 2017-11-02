local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-samtest" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-canary-passthrough-host-network-service",
            namespace: "sam-system",
            labels: {
                app: "slb-canary-passthrough-host-network-service",
                "slb.sfdc.net/name": "slb-canary-pt-host-nw",
                "slb.sfdc.net/type": "none",
            },
        },
        spec: {
            ports: [
            {
                name: "slb-canary-passthrough-host-network-port",
                port: portconfigs.slb.canaryServicePassthroughHostNetworkPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServicePassthroughHostNetworkPort,
                nodePort: portconfigs.slb.canaryServicePassthroughHostNetworkNodePort,
            },
            ],
                selector: {
                    name: "slb-canary-passthrough-host-network",
                },
                type: "NodePort",
        },
} else "SKIP"
