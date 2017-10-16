local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "slb-canary-service",
            namespace: "sam-system",
            labels: {
                app: "slb-canary-service",
                "slb.sfdc.net/name": "slb-canary-service",
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
            ]
            + (
              if configs.estate == "prd-sdc" then [
              {
                name: "slb-canary-tls",
                port: portconfigs.slb.canaryServiceTlsPort,
                protocol: "TCP",
                targetPort: portconfigs.slb.canaryServiceTlsPort,
                nodePort: portconfigs.slb.canaryServiceTlsNodePort,
              },
              ] else []
            ),
                selector: {
                    name: "slb-canary",
                },
                type: "NodePort",
        },
} else "SKIP"
