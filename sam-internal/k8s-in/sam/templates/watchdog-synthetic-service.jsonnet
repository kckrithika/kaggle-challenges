local configs = import "config.jsonnet";
{
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "watchdog-synthetic-service",
            namespace: "sam-system",
            labels: {
                app: "watchdog-synthetic-service",
            },
        },
        spec: {
            ports: [
            {
                name: "watchdog-synthetic-service-port",
                port: 9090,
                protocol: "TCP",
                targetPort: (if configs.estate == "prd-sam" then 8063 else 8083),
                nodePort: 32001,
            },
            ],
                selector: {
                    name: "watchdog-synthetic",
                },
                type: "NodePort",
        },
}
