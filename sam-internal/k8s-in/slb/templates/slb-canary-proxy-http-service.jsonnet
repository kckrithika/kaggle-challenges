local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
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
            annotations: {
                "slb.sfdc.net/name": "slb-canary-proxy-http",
                "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"targetport\":" + portconfigs.slb.canaryServiceProxyHttpPort + ",\"lbtype\":\"http\"},{\"port\":443,\"targetport\":443,\"lbtype\":\"http\"}]",
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
                port: portconfigs.slb.canaryServiceProxyHttpsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceProxyHttpsPort,
                nodePort: portconfigs.slb.canaryServiceProxyHttpsNodePort,
            },
            ],
            selector: {
                name: "slb-canary-proxy-http",
            },
            type: "NodePort",
        },
} else "SKIP"
