local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "fds-svc",
            namespace: "sam-system",
            labels: {
                app: "fds-controller",
                "slb.sfdc.net/name": "fds",
            },
        },
        spec: {
            ports: [
                {
                name: "fds-controller-port",
                port: 8080,
                protocol: "TCP",
                targetPort: 8080,
                nodePort: 32100,
                },
            ],
            selector: {
                name: "fds-controller",
            },
            type: "NodePort",
        },
} else "SKIP"
