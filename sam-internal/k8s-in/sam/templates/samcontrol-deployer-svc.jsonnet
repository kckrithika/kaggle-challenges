local configs = import "config.jsonnet";
if configs.kingdom == "prd" && configs.estate == "prd-samtest" then {
    kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "samcontrol-deployer",
            namespace: "sam-system",
            labels: {
                app: "samcontrol-deployer",
            },
            annotations: {
                "slb.sfdc.net/name": "samcontrol-deployer",
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
            },
        },
        spec: {
            ports: [
            {
                name: "deployer-portal-port",
                port: 80,
                protocol: "TCP",
                targetPort: 9099,
            },
            ],
                selector: {
                    name: "samcontrol-deployer",
                },
        },
} else "SKIP"
