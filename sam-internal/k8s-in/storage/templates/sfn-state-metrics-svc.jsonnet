local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
]);

if std.setMember(configs.estate, enabledEstates) then {
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
