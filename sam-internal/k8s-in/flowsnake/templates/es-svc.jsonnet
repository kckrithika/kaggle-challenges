local flowsnakeconfig = import "flowsnake_config.jsonnet";
if !flowsnakeconfig.elastic_search_enabled then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "elasticsearch",
        namespace: "flowsnake",
        labels: {
            component: "elasticsearch",
        },
    },
    spec: {
        selector: {
            component: "elasticsearch",
        },
        ports: [
            {
                port: 9200,
                name: "http",
                protocol: "TCP",
            },
            {
                port: 9300,
                name: "transport",
                protocol: "TCP",
            },
        ],
    },
}
