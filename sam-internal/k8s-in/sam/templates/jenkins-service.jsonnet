local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "jenkins",
            namespace: "sam-system",
            labels: {
                app: "jenkins",
            },
        },
        spec: {
            ports: [
            {
                name: "jenkins-port",
                port: 8080,
                protocol: "TCP",
                targetPort: 8080,
                nodePort: 39104,
            },
            ],
                selector: {
                    name: "jenkins",
                },
                type: "NodePort",
        },
} else "SKIP"
