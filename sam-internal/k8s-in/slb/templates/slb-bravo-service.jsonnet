local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-bravo-svc",
            namespace: "sam-system",
            labels: {
                app: "slb-bravo-svc",
                "slb.sfdc.net/name": "slb-bravo-svc",
            },
        },
        spec: {
            ports: [
                {
                    name: "slb-bravo-port",
                    port: 9090,
                    protocol: "TCP",
                    targetPort: 9090,
                    nodePort: portconfigs.slb.bravoServiceNodePort,
                },
                {
                    name: "slb-bravo-port-1",
                    port: 9091,
                    protocol: "TCP",
                    targetPort: 9091,
                    nodePort: portconfigs.slb.bravoServiceNodePort1,
                },
                {
                    name: "slb-bravo-port-2",
                    port: 9092,
                    protocol: "TCP",
                    targetPort: 9092,
                    nodePort: portconfigs.slb.bravoServiceNodePort2,
                },
            ],
            selector: {
                    name: "slb-bravo",
            },
            type: "NodePort",
        },
} else "SKIP"
