local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "sfn-state-metrics-svc",
            namespace: "sam-system",
            labels: {
                team: "storage-foundation",
                cloud: "storage",
            },
            annotations: {
                "slb.sfdc.net/name": "sfn-metrics",
                "slb.sfdc.net/portconfigurations": '[{"port":8080,"targetport":8080,"lbtype":"tcp"}]',
            },
        },
        spec: {
            ports: [
                {
                name: "sfn-metrics",
                port: 8080,
                protocol: "TCP",
                targetPort: 8080,
                nodePort: 38001,
                },
            ],
            selector: {
                name: "sfn-state-metrics",
            },
            type: "NodePort",
        },
} else "SKIP"
