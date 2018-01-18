local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
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
        replicas: 3,
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
                        image: flowsnakeimage.es,
                        imagePullPolicy: "Always",
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
                            {
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
                        flowsnakeconfigmapmount.kubeconfig_volumeMounts +
                        flowsnakeconfigmapmount.cert_volumeMounts,
                    },
                ],
                volumes: [
                    {
                        name: "storage",
                        emptyDir: {},
                    },
                ] +
                flowsnakeconfigmapmount.kubeconfig_volume +
                flowsnakeconfigmapmount.cert_volume,
            },
        },
    },
}
