local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";

if configs.kingdom == "prd-sam" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "sdn-kibana",
        namespace: "sam-system",
        labels: {
            app: "sdn-kibana",
        },
        annotations: {
            "slb.sfdc.net/name": "sdn-kibana",
            "slb.sfdc.net/portconfigurations": std.toString(
                [
                    {
                        port: 5601,
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
                name: "sdn-kibana-port",
                port: portconfigs.sdn.sdn_kibana,
                protocol: "TCP",
                targetPort: portconfigs.sdn.sdn_kibana,
            },
        ],
        selector: {
            name: "sdn-kibana",
        },
    },
} else "SKIP"
