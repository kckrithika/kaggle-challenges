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
        annotations: {
            "slb.sfdc.net/name": "samsqlreporter",
            "slb.sfdc.net/portconfigurations": '[{"port":80,"targetport":64212,"nodeport":0,"lbtype":"","reencrypt":false,"sticky":0}]',
        },
    },
    spec: {
        ports: [
            {
                name: "ssr-port",
                port: 64212,
                protocol: "TCP",
                targetPort: 64212,
            },
        ],
        selector: {
            name: "samsqlreporter",
        },
        type: "ClusterIP",
    },
} else "SKIP"
