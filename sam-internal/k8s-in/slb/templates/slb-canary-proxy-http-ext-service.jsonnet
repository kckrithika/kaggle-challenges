local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
# if configs.estate == "xrd-sam" || configs.estate == "prd-samtwo" || slbconfigs.slbInProdKingdom then {
if configs.estate == "iad-sam" then {
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
