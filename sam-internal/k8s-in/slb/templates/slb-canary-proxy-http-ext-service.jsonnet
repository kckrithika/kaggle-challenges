local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(port=80, targetPort=portconfigs.slb.canaryServiceProxyHttpPort, lbType="http") { healthpath: "/health" },
];

if slbconfigs.isProdEstate && configs.estate != "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
                  name: "slb-canary-proxy-http-ext-service",
                  namespace: "sam-system",
                  labels: {
                      app: "slb-canary-proxy-http-ext-service",
                      "slb.sfdc.net/name": "slb-canary-proxy-http-ext",
                      "slb.sfdc.net/type": "http",
                  } + configs.ownerLabel.slb,
                  annotations: {
                      "slb.sfdc.net/name": "slb-canary-proxy-http-ext",
                      "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(canaryPortConfig),
                  },
    },
    spec: {
        ports: [
            {
                name: "slb-canary-proxy-http-port",
                port: 80,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceProxyHttpPort,
            },
        ],
        selector: {
            name: "slb-canary-proxy-http",
        },
        type: "NodePort",
    },
} else "SKIP"
