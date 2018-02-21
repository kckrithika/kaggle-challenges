local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" || configs.kingdom == "frf" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-portal-service",
            namespace: "sam-system",
            labels: {
                app: "slb-portal-service",
                "slb.sfdc.net/name": "slb-portal-service",
            },
            annotations: {
                "slb.sfdc.net/name": "slb-portal-service",
            },
        },
        spec: {
            ports: [
            {
                name: "slb-portal-port",
                port: portconfigs.slb.slbPortalServicePort,
                protocol: "TCP",
                targetPort: portconfigs.slb.slbPortalServicePort,
                nodePort: portconfigs.slb.slbPortalServiceNodePort,
            },
            ],
                selector: {
                    name: "slb-portal",
                },
                type: "NodePort",
        },
} else "SKIP"
