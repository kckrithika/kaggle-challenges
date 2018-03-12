local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.estate == "prd-sdc" || configs.estate == "prd-samtest" || configs.estate == "prd-sam_storage" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "k8sproxy",
        namespace: "sam-system",
        labels: {
            app: "k8sproxy",
        },
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
