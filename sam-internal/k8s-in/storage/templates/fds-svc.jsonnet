local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
]);

if std.setMember(configs.estate, enabledEstates) then {
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
                    port1: storageconfigs.serviceDefn.fds_svc.controller["port-config"],
                },
            },
        },
        spec: {
            ports: [
                {
                name: storageconfigs.serviceDefn.fds_svc.controller["port-name"],
                port: storageconfigs.serviceDefn.fds_svc.controller.port,
                protocol: "TCP",
                targetPort: storageconfigs.serviceDefn.fds_svc.controller.port,
                },
            ],
            selector: {
                name: "fds-controller",
            },
            type: "NodePort",
        },
} else "SKIP"
