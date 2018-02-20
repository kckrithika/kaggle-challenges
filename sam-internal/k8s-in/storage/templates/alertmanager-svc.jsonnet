local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "alertmanager-svc",
        labels: {
            app: "alertmanager-svc",
            namespace: "sam-system",
        },
    },
    spec: {
        type: "NodePort",
        selector: {
            app: "alertmanager",
        },
        ports: [
            {
                name: "alert-hook",
                protocol: "TCP",
                port: 15212,
                nodePort: 35001,
                targetPort: 15212,
            },
            {
                name: "alert-publisher",
                protocol: "TCP",
                port: 15213,
                nodePort: 35002,
                targetPort: 15213,
            },
        ],
    },
} else "SKIP"
