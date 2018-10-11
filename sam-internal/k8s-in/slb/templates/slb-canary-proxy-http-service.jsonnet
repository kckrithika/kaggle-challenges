local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbportconfiguration = import "slbportconfiguration.libsonnet";

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(port=portconfigs.slb.canaryServiceProxyHttpPort, lbType="http"),
    slbportconfiguration.newPortConfiguration(port=443, lbType="http") { reencrypt: true, sticky: 300, healthport: 9116, hEaLtHpath: "/health", tls: true },
];

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
                  name: "slb-canary-proxy-http-service",
                  namespace: "sam-system",
                  labels: {
                      app: "slb-canary-proxy-http-service",
                      "slb.sfdc.net/name": "slb-canary-proxy-http",
                      "slb.sfdc.net/type": "http",
                  } + configs.ownerLabel.slb,
              } + {
                  annotations: {
                      "slb.sfdc.net/name": "slb-canary-proxy-http",
                      "slb.sfdc.net/portconfigurations": slbportconfiguration.portConfigurationToString(canaryPortConfig),
                  },
              },
    spec: {
        ports: [
            {
                name: "slb-canary-proxy-http-port",
                port: portconfigs.slb.canaryServiceProxyHttpPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceProxyHttpPort,
                nodePort: portconfigs.slb.canaryServiceProxyHttpNodePort,
            },
            {
                name: "slb-canary-proxy-https-port",
                port: 443,
                protocol: "TCP",
                targetPort: 443,
            },
        ],
        selector: {
            name: "slb-canary-proxy-http",
        },
        type: "NodePort",
    },
} else "SKIP"
