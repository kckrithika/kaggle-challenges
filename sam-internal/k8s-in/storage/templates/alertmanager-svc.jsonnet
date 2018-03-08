local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    kind: "Service",
    apiVersion: "v1",
    metadata: {
        name: "alertmanager-svc",
        labels: {
            app: "alertmanager-svc",
            namespace: "sam-system",
        },
        annotations: {
            "slb.sfdc.net/name": "alertmanager",
            "slb.sfdc.net/portconfigurations": '[{"port":15212,"targetport":15212,"lbtype":"tcp"}, {"port":15213,"targetport":15213,"lbtype":"tcp"}]',
        },
    },
    spec: {
        type: "NodePort",
        selector: {
            app: "alertmanager",
        },
        ports: [
            {
                name: "alert-hook",
                protocol: "TCP",
                port: 15212,
                nodePort: 35001,
                targetPort: 15212,
            },
            {
                name: "alert-publisher",
                protocol: "TCP",
                port: 15213,
                nodePort: 35002,
                targetPort: 15213,
            },
        ],
    },
} else "SKIP"
