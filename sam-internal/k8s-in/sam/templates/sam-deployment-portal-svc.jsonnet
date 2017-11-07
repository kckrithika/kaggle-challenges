local configs = import "config.jsonnet";
if configs.kingdom == "prd" && configs.estate != "prd-sam_storage" && configs.estate != "prd-samtest" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "sdp",
            namespace: "sam-system",
            labels: {
                app: "sam-deployment-portal",
                "slb.sfdc.net/name": "sdp",
            },
        },
        spec: {
            ports: [
            {
                name: "portal-port",
                port: 64121,
                protocol: "TCP",
                targetPort: 64121,
                nodePort: 39999,
            },
            ],
                selector: {
                    name: "sam-deployment-portal",
                },
                type: "NodePort",
        },
} else "SKIP"
