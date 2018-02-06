local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube_small then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        namespace: "flowsnake",
        name: "elasticsearch-discovery",
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
                name: "transport",
                port: 9300,
                protocol: "TCP",
            },
        ],
    },
}
