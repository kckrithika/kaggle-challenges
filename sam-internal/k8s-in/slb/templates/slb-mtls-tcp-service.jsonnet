local configs = import "config.jsonnet";
local portconfigs = import "slbports.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-mtls-tcp-service",
            namespace: "sam-system",
            annotations: {
                "slb.sfdc.net/name": "slb-mtls-tcp",
                "slb.sfdc.net/type": "tcp",
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
