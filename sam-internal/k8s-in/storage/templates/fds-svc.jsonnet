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
                "slb.sfdc.net/name": storageconfigs.serviceNames["fds-svc"],
                "slb.sfdc.net/portconfigurations": '[{"port":8080,"targetport":8080,"lbtype":"tcp"}]',
            },
        },
        spec: {
            ports: [
                {
                name: "fds-controller-port",
                port: 8080,
                protocol: "TCP",
                targetPort: 8080,
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
