local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "illumio-dsr-host-svc",
        namespace: "sam-system",
        labels: {
            app: "illumio-dsr-host-svc",
            "slb.sfdc.net/name": "illumio-dsr-host-svc",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "illumio-dsr-host-svc",
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
            name: "illumio-dsr-host",
        },
        type: "NodePort",
    },
} else "SKIP"
