local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local elk = import "elastic_search_logstash_kibana.jsonnet";
if !elk.elastic_search_enabled then
"SKIP"
else
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "kibana",
        namespace: "flowsnake",
        labels: {
            name: "kibana",
            component: "kibana",
        },
    },
    spec: {
        replicas: 3,
        template: {
            metadata: {
                namespace: "flowsnake",
                labels: {
                    name: "kibana",
                    component: "kibana",
                },
            },
            spec: {
                containers: [
                    {
                        name: "kibana",
                        image: flowsnakeimage.kibana,
                        imagePullPolicy: if flowsnakeconfig.is_minikube then "Never" else "Always",
                        ports: [
                            {
                                containerPort: 5601,
                                name: "http",
                                protocol: "TCP",
                            },
                        ],
                        readinessProbe: {
                            httpGet: {
                                path: "/",
                                port: 5601,
                                scheme: "HTTP",
                            },
                        },
                        livenessProbe: {
                            httpGet: {
                                path: "/",
                                port: 5601,
                                scheme: "HTTP",
                            },
                            initialDelaySeconds: 180,
                        },
                    },
                ],
            },
        },
    },
}
