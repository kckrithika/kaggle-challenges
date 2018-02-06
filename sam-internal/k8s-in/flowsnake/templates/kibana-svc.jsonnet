local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube_small then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "kibana",
        namespace: "flowsnake",
        labels: {
            component: "kibana",
        },
    },
    spec: {
        type: "NodePort",
        selector: {
            component: "kibana",
        },
        ports: [
            {
                name: "http",
                port: 5601,
                protocol: "TCP",
                # NodePort allowed range is different in Minikube; compensate accordingly.
                nodePort: if flowsnakeconfig.is_minikube then 30003 else 32003,
            },
        ],
    },
}
