local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "illumio-proxy-svc",
        namespace: "sam-system",
        labels: {
            app: "illumio-proxy-svc",
            "slb.sfdc.net/name": "illumio-proxy-svc",
        } + configs.ownerLabel.slb,
        annotations: {
            "slb.sfdc.net/name": "illumio-proxy-svc",
            "slb.sfdc.net/portconfigurations": "[{\"port\":8443,\"targetport\":8443,\"lbtype\":\"tcp\"}]",
        },
    },
    spec: {
        ports: [
            {
                name: "slb-illumio-proxy-port",
                port: 8443,
                protocol: "TCP",
                targetPort: 8443,
            },
        ],
        selector: {
            name: "illumio-proxy",
        },
        type: "NodePort",
    },
} else "SKIP"
