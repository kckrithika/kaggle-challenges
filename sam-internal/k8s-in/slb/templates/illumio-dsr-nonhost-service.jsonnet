local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "illumio-dsr-nonhost-svc",
        namespace: "sam-system",
        labels: {
            app: "illumio-dsr-nonhost-svc",
            "slb.sfdc.net/name": "illumio-dsr-nonhost-svc",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "illumio-dsr-nonhost-svc",
            "slb.sfdc.net/portconfigurations": "[{\"port\":8443,\"targetport\":8443,\"lbtype\":\"dsr\"}]",
        },
    },
    spec: {
        ports: [
            {
                name: "slb-illumio-dsr-port",
                port: 8443,
                protocol: "TCP",
                targetPort: 8443,
            },
        ],
        selector: {
            name: "illumio-dsr-nonhost",
        },
        type: "NodePort",
    },
} else "SKIP"
