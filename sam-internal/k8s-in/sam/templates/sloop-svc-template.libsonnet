{
    local configs = import "config.jsonnet",
    local portconfigs = import "portconfig.jsonnet",
    local samfeatureflags = import "sam-feature-flags.jsonnet",

    template(estate):: {
        kind: "Service",
        apiVersion: "v1",
        metadata: {
            name: "sloop",
            namespace: "sam-system",
            labels: {
                app: "sloop",
            } + configs.ownerLabel.sam,
            annotations: {
                "slb.sfdc.net/name": "sloop-" + estate,
                "slb.sfdc.net/portconfigurations": std.toString(
                    [
                        {
                            port: 80,
                            targetport: portconfigs.sloop.sloop,
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
                    targetPort: portconfigs.sloop.sloop,
                },
            ],
            selector: {
                app: "sloopds-" + estate,
            },
        },
    },
}
