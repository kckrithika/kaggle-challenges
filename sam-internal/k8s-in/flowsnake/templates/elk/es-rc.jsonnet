local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local elk = import "elastic_search_logstash_kibana.jsonnet";
if !elk.elastic_search_enabled then
"SKIP"
else
{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "elasticsearch",
        namespace: "flowsnake",
        labels: {
            name: "elasticsearch",
            component: "elasticsearch",
        },
    },
    spec: {
        replicas: elk.elastic_search_replicas,
        template: {
            metadata: {
                namespace: "flowsnake",
                labels: {
                    name: "elasticsearch",
                    component: "elasticsearch",
                },
            },
            spec: {
                containers: [
                    {
                        name: "es",
                        securityContext: {
                            capabilities: {
                                add: [
                                    "IPC_LOCK",
                                ],
                            },
                        },
                        image: flowsnake_images.es,
                        imagePullPolicy: if std.objectHas(flowsnake_images.feature_flags, "uniform_pull_policy") then
                            flowsnakeconfig.default_image_pull_policy else
                            (if flowsnakeconfig.is_minikube then "Never" else "Always"),
                        env: [
                            {
                                name: "NAMESPACE",
                                value: "flowsnake",
                            },
                            {
                                name: "CLUSTER_NAME",
                                value: "elasticsearch",
                            },
                            {
                                name: "NUMBER_OF_MASTERS",
                                value: "2",
                            },
                            {
                                name: "DISCOVERY_SERVICE",
                                value: "elasticsearch-discovery",
                            },
                            {
                                name: "NETWORK_HOST",
                                value: "0.0.0.0",
                            },
                            {
                                name: "NODE_MASTER",
                                value: "true",
                            },
                            {
                                name: "NODE_DATA",
                                value: "true",
                            },
                            {
                                name: "HTTP_ENABLE",
                                value: "true",
                            },
                            if flowsnakeconfig.is_minikube then {
                                name: "KUBERNETES_CA_CERTIFICATE_FILE",
                                value: "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
                            } else {
                                name: "KUBECONFIG",
                                valueFrom: {
                                    configMapKeyRef: {
                                        name: "fleet-config",
                                        key: "kubeconfig",
                                    },
                                },
                            },
                        ],
                        ports: [
                            {
                                containerPort: 9200,
                                name: "http",
                                protocol: "TCP",
                            },
                            {
                                containerPort: 9300,
                                name: "transport",
                                protocol: "TCP",
                            },
                        ],
                        readinessProbe: {
                            tcpSocket: {
                                port: 9300,
                            },
                        },
                        livenessProbe: {
                            tcpSocket: {
                                port: 9300,
                            },
                            initialDelaySeconds: 180,
                        },
                        volumeMounts: [
                            {
                                mountPath: "/es-data",
                                name: "storage",
                            },
                        ] +
                        certs_and_kubeconfig.kubeconfig_volumeMounts +
                        certs_and_kubeconfig.platform_cert_volumeMounts,
                    },
                ],
                volumes: [
                    {
                        name: "storage",
                        emptyDir: {},
                    },
                ] +
                certs_and_kubeconfig.kubeconfig_platform_volume +
                certs_and_kubeconfig.platform_cert_volume,
            },
        },
    },
}
