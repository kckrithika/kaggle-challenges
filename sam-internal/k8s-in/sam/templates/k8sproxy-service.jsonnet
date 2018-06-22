local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.k8sproxy then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "k8sproxy",
        namespace: "sam-system",
        labels: {
            app: "k8sproxy",
        } + configs.ownerLabel.sam,
        annotations: {
            "slb.sfdc.net/name": "k8sproxy",
        },
    },
    spec: {
        ports: [
            {
                name: "k8sproxy-port",
                port: 5000,
                protocol: "TCP",
                targetPort: 5000,
                nodePort: 40000,
            },
        ],
        selector: {
            name: "k8sproxy",
        },
        type: "NodePort",
    },
} else "SKIP"
