local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sloopds",
        namespace: "sam-system",
        labels: {
            app: "sloopds",
        } + configs.ownerLabel.sam,
        annotations: {
            "slb.sfdc.net/name": "sloopds",
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
            name: "sloopds",
        },
    },
} else "SKIP"
