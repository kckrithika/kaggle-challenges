local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sloop-legacy",
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
            app: "sloopds-prd-sam",
        },
    },
} else "SKIP"
