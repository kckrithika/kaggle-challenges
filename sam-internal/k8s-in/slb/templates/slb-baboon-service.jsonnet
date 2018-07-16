local configs = import "config.jsonnet";
local portconfigs = import "slbports.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-baboon-service",
        namespace: "sam-system",
        labels: {
            app: "slb-baboon-service",
            "slb.sfdc.net/name": "slb-baboon-service",
        } + slbconfigs.ownerLabel,
        annotations: {
            "slb.sfdc.net/name": "slb-baboon-service",
        },
    },
    spec: {
        ports: [
            {
                name: "slb-baboon-port",
                port: portconfigs.slb.baboonEndPointPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.baboonEndPointPort,
                nodePort: portconfigs.slb.baboonEndPointPort,
            },
        ],
        selector: {
            name: "slb-baboon",
        },
        type: "NodePort",
    },
} else "SKIP"
