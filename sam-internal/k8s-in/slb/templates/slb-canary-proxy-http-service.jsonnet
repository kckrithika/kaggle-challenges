local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || slbconfigs.slbInProdKingdom then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
                  name: "slb-canary-proxy-http-service",
                  namespace: "sam-system",
                  labels: {
                      app: "slb-canary-proxy-http-service",
                      "slb.sfdc.net/name": "slb-canary-proxy-http",
                      "slb.sfdc.net/type": "http",
                  },
              } +
              if configs.estate == "prd-sdc" then {
                  annotations: {
                      "slb.sfdc.net/name": "slb-canary-proxy-http",
                      "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"targetport\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"lbtype\":\"http\"},{\"port\":443,\"targetport\":443,\"lbtype\":\"http\",\"reencrypt\":true,\"sticky\":300,\"healthport\":9116,\"hEaLtHpath\":\"/health\",\"tls\":true}]",
                  },
              } else {
                  annotations: {
                      "slb.sfdc.net/name": "slb-canary-proxy-http",
                      "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"targetport\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"lbtype\":\"http\"},{\"port\":443,\"targetport\":443,\"lbtype\":\"http\",\"reencrypt\":true,\"sticky\":300,\"healthport\":9116,\"hEaLtHpath\":\"/health\",\"tls\":true}]",
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
