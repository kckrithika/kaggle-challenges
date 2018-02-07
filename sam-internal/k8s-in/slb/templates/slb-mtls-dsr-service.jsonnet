local configs = import "config.jsonnet";
local portconfigs = import "slbports.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-mtls-dsr-service",
            namespace: "sam-system",
            labels: {
                app: "slb-mtls-dsr-service",
                "slb.sfdc.net/name": "slb-mtls-dsr",
                "slb.sfdc.net/type": "none",
            },
            annotations: {
                "slb.sfdc.net/name": "slb-mtls-dsr",
            },
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
