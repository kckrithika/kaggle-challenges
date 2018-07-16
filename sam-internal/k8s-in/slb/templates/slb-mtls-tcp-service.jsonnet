local configs = import "config.jsonnet";
local portconfigs = import "slbports.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "slb-mtls-tcp-service",
        namespace: "sam-system",
        annotations: {
            "slb.sfdc.net/name": "slb-mtls-tcp",
            "slb.sfdc.net/portconfigurations": "[{\"port\":12345,\"targetport\":12345,\"lbtype\":\"tcp\"}]",
        },
        labels: {} + slbconfigs.ownerLabel,
    },
    spec: {
        ports: [
            {
                name: "slb-mtls-dsr-port",
                port: portconfigs.slb.mtlsDsrPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.mtlsDsrPort,
                nodePort: portconfigs.slb.mtlsDsrNodePort,
            },
        ],
        selector: {
            name: "slb-mtls-dsr",
        },
        type: "NodePort",
    },
} else "SKIP"
