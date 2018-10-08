local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
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
                      "slb.sfdc.net/portconfigurations": "[{\"port\":80,\"targetport\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"lbtype\":\"http\",\"healthpath\":\"/health\"}]",
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
