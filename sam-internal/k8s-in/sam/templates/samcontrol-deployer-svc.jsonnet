local configs = import "config.jsonnet";
if configs.kingdom == "prd" && configs.estate == "prd-samtest" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "scd",
            namespace: "sam-system",
            labels: {
                app: "samcontrol-deployer",
                "slb.sfdc.net/name": "scd",
            },
            annotations: {
                "slb.sfdc.net/name": "scd",
            },
        },
        spec: {
            ports: [
            {
                name: "deployer-portal-port",
                port: 9099,
                protocol: "TCP",
                targetPort: 9099,
                nodePort: 32864,
            },
            ],
                selector: {
                    name: "samcontrol-deployer",
                },
                type: "NodePort",
        },
} else "SKIP"
