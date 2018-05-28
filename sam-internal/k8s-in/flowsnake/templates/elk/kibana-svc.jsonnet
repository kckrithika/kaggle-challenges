local elk = import "elastic_search_logstash_kibana.jsonnet";
if !elk.elastic_search_enabled then
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
                nodePort: elk.kibana_nodeport,
            },
        ],
    },
}
