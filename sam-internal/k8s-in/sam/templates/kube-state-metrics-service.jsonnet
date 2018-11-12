local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "kube-state-metrics",
        namespace: "kube-system",
        annotations: {
            "prometheus.io/scrape": "true",
        },
        labels: {
            app: "kube-state-metrics",
        } + configs.ownerLabel.sam,
    },
    spec: {
        ports: [
            {
                name: "http-metrics",
                port: 8080,
                protocol: "TCP",
                targetPort: "http-metrics",
            },
            {
                name: "telemetry",
                port: 8081,
                protocol: "TCP",
                targetPort: "telemetry",
            },
        ],
        selector: {
            name: "kube-state-metrics",
        },
    },
} else "SKIP"
