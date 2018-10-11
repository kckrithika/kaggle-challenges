local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.canaryServicePort, lbType="dsr") { healthpath: "/health" },
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.canaryServiceTlsPort, lbType="dsr") { healthpath: "/health" },
];

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-canary-service",
        namespace: "sam-system",
        labels: {
            app: "slb-canary-service",
            "slb.sfdc.net/name": "slb-canary-service",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "slb-canary-service",
            "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(canaryPortConfig),
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
            {
                name: "slb-canary-tls",
                port: portconfigs.slb.canaryServiceTlsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceTlsPort,
                nodePort: portconfigs.slb.canaryServiceTlsNodePort,
            },
        ],
        selector: {
            name: "slb-canary",
        },
        type: "NodePort",
    },
} else "SKIP"
