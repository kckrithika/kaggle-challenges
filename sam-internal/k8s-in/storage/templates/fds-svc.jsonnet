local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" || configs.estate == "phx-sam" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "fds-svc",
            namespace: "sam-system",
            labels: {
                app: "fds-controller",
                team: "storage-foundation",
                cloud: "storage",
            },
            annotations: {
                "slb.sfdc.net/name": storageconfigs.serviceDefn.fds_svc.name,
                "slb.sfdc.net/portconfigurations": "[{%(port1)s}]" % {
                    port1: storageconfigs.serviceDefn.fds_svc.health["port-config"],
                },
            },
        },
        spec: {
            ports: [
                {
                name: storageconfigs.serviceDefn.fds_svc.health["port-name"],
                port: storageconfigs.serviceDefn.fds_svc.health.port,
                protocol: "TCP",
                targetPort: storageconfigs.serviceDefn.fds_svc.health.port,
                } +
                if configs.estate != "prd-sam_storage" then {
                    nodePort: 32100,
                } else {},
            ],
            selector: {
                name: "fds-controller",
            },
            type: "NodePort",
        },
} else "SKIP"
