local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || slbconfigs.slbInProdKingdom then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-canary-service",
        namespace: "sam-system",
        labels: {
            app: "slb-canary-service",
            "slb.sfdc.net/name": "slb-canary-service",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "slb-canary-service",
            "slb.sfdc.net/portconfigurations": "[{\"port\":" + portconfigs.slb.canaryServicePort + ",\"targetport\":" + portconfigs.slb.canaryServicePort + ",\"lbtype\":\"dsr\",\"healthpath\":\"/health\"},{\"port\":" + portconfigs.slb.canaryServiceTlsPort + ",\"targetport\":" + portconfigs.slb.canaryServiceTlsPort + ",\"lbtype\":\"dsr\",\"healthpath\":\"/health\"}]",
        },
    },
    spec: {
        ports: [
            {
                name: "slb-canary-port",
                port: portconfigs.slb.canaryServicePort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServicePort,
                nodePort: portconfigs.slb.canaryServiceNodePort,
            },
            {
                name: "slb-canary-tls",
                port: portconfigs.slb.canaryServiceTlsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceTlsPort,
                nodePort: portconfigs.slb.canaryServiceTlsNodePort,
            },
        ],
        selector: {
            name: "slb-canary",
        },
        type: "NodePort",
    },
} else "SKIP"
