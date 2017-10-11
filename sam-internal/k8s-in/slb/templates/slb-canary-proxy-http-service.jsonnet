local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" then {
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
            ],
            selector: {
                name: "slb-canary-proxy-http",
            },
            type: "NodePort",
        },
} else "SKIP"
