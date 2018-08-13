local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sam_storage" || slbconfigs.slbInProdKingdom then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-portal-service",
        namespace: "sam-system",
        labels: {
            app: "slb-portal-service",
            "slb.sfdc.net/name": "slb-portal-service",
        } + configs.ownerLabel.slb,
        annotations: {
           "slb.sfdc.net/name": "slb-portal-service",
           "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.slbPortalServicePort + ",\"targetport\":" + portconfigs.slb.slbPortalServicePort + ",\"lbtype\":\"http\"}]",
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
