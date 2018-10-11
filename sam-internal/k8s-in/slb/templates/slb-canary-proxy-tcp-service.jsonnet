local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.canaryServiceProxyTcpPort, lbType="tcp") { healthPath: "/" },
];

if configs.estate == "prd-sdc" || slbconfigs.slbInProdKingdom then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-canary-proxy-tcp-service",
        namespace: "sam-system",
        labels: {
            app: "slb-canary-proxy-tcp-service",
            "slb.sfdc.net/name": "slb-canary-proxy-tcp",
            "slb.sfdc.net/type": "tcp",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "slb-canary-proxy-tcp",
            "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(canaryPortConfig),
        },
    },
    spec: {
        ports: [
            {
                name: "slb-canary-proxy-tcp-port",
                port: portconfigs.slb.canaryServiceProxyTcpPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceProxyTcpPort,
                nodePort: portconfigs.slb.canaryServiceProxyTcpNodePort,
            },
        ],
        selector: {
            name: "slb-canary-proxy-tcp",
        },
        type: "NodePort",
    },
} else "SKIP"
