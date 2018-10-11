local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local bravoPortConfig = [
    slbportconfiguration.newPortConfiguration(port=9090, lbType="tcp"),
    slbportconfiguration.newPortConfiguration(port=9091, lbType="http"),
    slbportconfiguration.newPortConfiguration(port=9092, lbType="dsr"),
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.canaryServiceTlsPort, lbType="dsr"),
];

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-bravo-svc",
        namespace: "sam-system",
        labels: {
            app: "slb-bravo-svc",
            "slb.sfdc.net/name": "slb-bravo-svc",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "slb-bravo-svc",
            "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(bravoPortConfig),
        },
    },
    spec: {
        ports: [
            {
                name: "slb-bravo-port",
                port: 9090,
                protocol: "TCP",
                targetPort: 9090,
                nodePort: portconfigs.slb.bravoServiceNodePort,
            },
            {
                name: "slb-bravo-port-1",
                port: 9091,
                protocol: "TCP",
                targetPort: 9091,
                nodePort: portconfigs.slb.bravoServiceNodePort1,
            },
            {
                name: "slb-bravo-port-2",
                port: 9092,
                protocol: "TCP",
                targetPort: 9092,
                nodePort: portconfigs.slb.bravoServiceNodePort2,
            },
            {
                name: "slb-bravo-port-3",
                port: portconfigs.slb.canaryServiceTlsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceTlsPort,
                nodePort: portconfigs.slb.bravoServiceNodePort3,
            },
        ],
        selector: {
            name: "slb-bravo",
        },
        type: "NodePort",
    },
} else "SKIP"
