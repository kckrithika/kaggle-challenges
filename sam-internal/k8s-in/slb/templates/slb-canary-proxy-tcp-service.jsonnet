local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-canary-proxy-tcp-service",
            namespace: "sam-system",
            labels: {
                app: "slb-canary-proxy-tcp-service",
                "slb.sfdc.net/name": "slb-canary-proxy-tcp",
                "slb.sfdc.net/type": "tcp",
            },
            annotations: {
                "slb.sfdc.net/name": "slb-canary-proxy-tcp",
                "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.canaryServiceProxyTcpPort + ",\"targetport\":" + portconfigs.slb.canaryServiceProxyTcpPort + ",\"lbtype\":\"tcp\"}]",
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
