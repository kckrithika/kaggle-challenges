local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local portalPortConfig = [
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.slbPortalServicePort, lbType="http"),
];

if slbconfigs.isSlbEstate && configs.estate != "prd-samtest" then {
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
           "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(portalPortConfig),
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
