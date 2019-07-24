local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sloop",
        namespace: "sam-system",
        labels: {
            app: "sloop",
        } + configs.ownerLabel.sam,
        annotations: {
            "slb.sfdc.net/name": "sloop",
            "slb.sfdc.net/portconfigurations": std.toString(
                [
                    {
                        port: 80,
                        targetport: 8080,
                        nodeport: 0,
                        lbtype: "",
                        reencrypt: false,
                        sticky: 0,
                    },
                    {
                        port: 9090,
                        targetport: 9090,
                        nodeport: 0,
                        lbtype: "",
                        reencrypt: false,
                        sticky: 0,
                    },
                ]
            ),
        },
    },
    spec: {
        ports: [
            {
                name: "sloop-port",
                port: 80,
                protocol: "TCP",
                targetPort: 8080,
            },
            {
                name: "prom-port",
                port: 9090,
                protocol: "TCP",
                targetPort: 9090,
            },
        ],
        selector: {
            name: "sloop",
        },
    },
} else "SKIP"
