local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
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
            "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.canaryServiceProxyTcpPort + ",\"targetport\":" + portconfigs.slb.canaryServiceProxyTcpPort + ",\"lbtype\":\"tcp\""
                                                 + (if slbimages.slbnginx_build >= 31 then ",\"healthPath\":\"/\"" else "")
                                                 + "}]",
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
