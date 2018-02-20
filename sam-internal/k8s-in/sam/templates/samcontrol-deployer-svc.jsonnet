local configs = import "config.jsonnet";
if configs.kingdom == "prd" && configs.estate == "prd-samtest" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "samcontrol-deployer",
            namespace: "sam-system",
            labels: {
                app: "samcontrol-deployer",
                "slb.sfdc.net/name": "samcontrol-deployer",
            },
            annotations: {
                "slb.sfdc.net/name": "samcontrol-deployer",
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
