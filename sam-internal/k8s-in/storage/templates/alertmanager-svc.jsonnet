local configs = import "config.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "alertmanager-svc",
        labels: {
            app: "alertmanager-svc",
            namespace: "sam-system",
        },
        annotations: {
            "slb.sfdc.net/name": "alertmanager",
            "slb.sfdc.net/portconfigurations": "[{%(port1)s},{%(port2)s}]" % {
                port1: storageconfigs.serviceDefn.alert_mgr_svc.alert_hook["port-config"],
                port2: storageconfigs.serviceDefn.alert_mgr_svc.alert_publisher["port-config"],
            },
        },
    },
    spec: {
        type: "NodePort",
        selector: {
            app: "alertmanager",
        },
        ports: [
            {
                name: storageconfigs.serviceDefn.alert_mgr_svc.alert_hook["port-name"],
                protocol: "TCP",
                port: storageconfigs.serviceDefn.alert_mgr_svc.alert_hook.port,
                targetPort: storageconfigs.serviceDefn.alert_mgr_svc.alert_hook.port,
            },
            {
                name: storageconfigs.serviceDefn.alert_mgr_svc.alert_publisher["port-name"],
                protocol: "TCP",
                port: storageconfigs.serviceDefn.alert_mgr_svc.alert_publisher.port,
                targetPort: storageconfigs.serviceDefn.alert_mgr_svc.alert_publisher.port,
            },
        ],
    },
} else "SKIP"
