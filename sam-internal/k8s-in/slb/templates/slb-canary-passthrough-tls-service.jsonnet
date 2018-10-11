local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.canaryServicePassthroughTlsPort, lbType="dsr") { healthpath: "/health" },
];

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
            "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(canaryPortConfig),
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
