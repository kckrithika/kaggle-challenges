local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

# Only private PROD info is provided by estate service currently
if samfeatureflags.estatessvc then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "estate-service",
        namespace: "sam-system",
        labels: {
            app: "estate-server",
        } + if configs.estate == "prd-samdev" then {
            owner: "sam",
        } else {},
    },
    spec: {
        ports: [
            {
                name: "estate-port",
                port: 8080,
                protocol: "TCP",
                targetPort: 9090,
                nodePort: 32999,
            },
        ],
        selector: {
            name: "estate-server",
        },
        type: "NodePort",
    },
} else "SKIP"
