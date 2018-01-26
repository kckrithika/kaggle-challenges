local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "prometheus-svc",
            namespace: "sam-system",
            labels: {
                app: "prometheus",
               "slb.sfdc.net/name": "prometheus",
            },
        },
        spec: {
            ports: [
            {
                name: "prometheus-port",
                port: 9090,
                protocol: "TCP",
                targetPort: 9090,
                nodePort: 38000,
            },
            ],
                selector: {
                    name: "prometheus",
                },
                type: "NodePort",
        },
} else "SKIP"
