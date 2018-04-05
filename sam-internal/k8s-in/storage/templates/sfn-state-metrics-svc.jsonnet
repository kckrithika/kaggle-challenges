local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "phx-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
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
                "slb.sfdc.net/name": storageconfigs.serviceDefn.sfn_metrics_svc.name,
                "slb.sfdc.net/portconfigurations": "[{%(port1)s}]" % {
                    port1: storageconfigs.serviceDefn.sfn_metrics_svc.health["port-config"],
                },
            },
        },
        spec: {
            ports: [
                {
                name: "sfn-metrics",
                port: storageconfigs.serviceDefn.sfn_metrics_svc.health.port,
                protocol: "TCP",
                targetPort: storageconfigs.serviceDefn.sfn_metrics_svc.health.port,
                },
            ],
            selector: {
                name: "sfn-state-metrics",
            },
            type: "NodePort",
        },
} else "SKIP"
