local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-echo-svc",
            namespace: "sam-system",
            labels: {
                app: "slb-echo-svc",
                "slb.sfdc.net/name": "slb-echo-svc",
            },
        },
        spec: {
            ports: [
            {
                name: "slb-echo-port",
                port: portconfigs.slb.slbEchoServicePort,
                protocol: "TCP",
                targetPort: portconfigs.slb.slbEchoServicePort,
                nodePort: portconfigs.slb.slbEchoServiceNodePort,
            },
            ],
                selector: {
                    name: "slb-echo-server",
                },
                type: "NodePort",
        },
} else "SKIP"
