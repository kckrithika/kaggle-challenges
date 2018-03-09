local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "samsqlreporter",
        namespace: "sam-system",
        labels: {
            app: "samsqlreporter",
        },
        annotations: if configs.estate == "prd-sam" then {
            "slb.sfdc.net/name": "samsqlreporter",
            "slb.sfdc.net/portconfigurations": std.toString(
                [
                    {
                        port: 80,
                        targetport: $.spec.ports[0].targetPort,
                        nodeport: 0,
                        lbtype: "",
                        reencrypt: false,
                        sticky: 0,
                    },
                ]
            ),
        } else {},
    },
    spec: {
        ports: [
            {
                name: "ssr-port",
                port: 80,
                protocol: "TCP",
                targetPort: 64212,
            },
        ],
        selector: {
            name: "samsqlreporter",
        },
    },
} else "SKIP"
