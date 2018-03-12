local configs = import "config.jsonnet";
if configs.kingdom == "prd" && configs.estate != "prd-sam_storage" && configs.estate != "prd-samtest" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sdp",
        namespace: "sam-system",
        labels: {
            app: "sam-deployment-portal",
        },
        annotations: if configs.estate == "prd-sam" then {
            "slb.sfdc.net/name": "sdp",
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
                    {
                        port: 64121,
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
                name: "portal-port",
                port: 64121,
                protocol: "TCP",
                targetPort: 64121,
            },
        ],
        selector: {
            name: "sam-deployment-portal",
        },
    } + if configs.estate != "prd-sam" then {
        ports: [super.ports[0] { nodePort: 39999 }],
        type: "NodePort",
    } else {},
} else "SKIP"
