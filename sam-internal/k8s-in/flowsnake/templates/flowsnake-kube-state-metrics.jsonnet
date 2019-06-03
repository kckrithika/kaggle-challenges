local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        {
            apiVersion: "rbac.authorization.k8s.io/v1",
            # kubernetes versions before 1.8.0 should use rbac.authorization.k8s.io/v1beta1
            kind: "ClusterRoleBinding",
            metadata: {
                name: "kube-state-metrics-clusterrolebinding",
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                apiGroup: "rbac.authorization.k8s.io",
                kind: "ClusterRole",
                name: "kube-state-metrics-clusterrole",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "kube-state-metrics-serviceaccount",
                    namespace: "kube-system",
                },
            ],
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1",
            # kubernetes versions before 1.8.0 should use rbac.authorization.k8s.io/v1beta1
            kind: "ClusterRole",
            metadata: {
                name: "kube-state-metrics-clusterrole",
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: [
                        "",
                    ],
                    resources: [
                        "configmaps",
                        "secrets",
                        "nodes",
                        "pods",
                        "services",
                        "resourcequotas",
                        "replicationcontrollers",
                        "limitranges",
                        "persistentvolumeclaims",
                        "persistentvolumes",
                        "namespaces",
                        "endpoints",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
                {
                    apiGroups: [
                        "extensions",
                    ],
                    resources: [
                        "daemonsets",
                        "deployments",
                        "replicasets",
                        "ingresses",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
                {
                    apiGroups: [
                        "apps",
                    ],
                    resources: [
                        "daemonsets",
                        "deployments",
                        "replicasets",
                        "statefulsets",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
                {
                    apiGroups: [
                        "batch",
                    ],
                    resources: [
                        "cronjobs",
                        "jobs",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
                {
                    apiGroups: [
                        "autoscaling",
                    ],
                    resources: [
                        "horizontalpodautoscalers",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
                {
                    apiGroups: [
                        "policy",
                    ],
                    resources: [
                        "poddisruptionbudgets",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
                {
                    apiGroups: [
                        "certificates.k8s.io",
                    ],
                    resources: [
                        "certificatesigningrequests",
                    ],
                    verbs: [
                        "list",
                        "watch",
                    ],
                },
            ],
        },
        {
            apiVersion: "apps/v1",
            kind: "Deployment",
            metadata: {
                name: "kube-state-metrics",
                namespace: "kube-system",
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            spec: {
                selector: {
                    matchLabels: {
                        "k8s-app": "kube-state-metrics",
                    },
                },
                replicas: 1,
                template: {
                    metadata: {
                        labels: {
                            "k8s-app": "kube-state-metrics",
                        } + (
if std.objectHas(flowsnake_images.feature_flags, "watchdog_kuberesources") then
                        {
                            name: "kube-state-metrics",
                        } else {}
                        ),
                    },
                    spec: {
                        serviceAccountName: "kube-state-metrics-serviceaccount",
                        containers: [
                            {
                                name: "kube-state-metrics",
                                image: flowsnake_images.kube_state_metrics,
                                ports: [
                                    {
                                        name: "http-metrics",
                                        containerPort: 8080,
                                    },
                                    {
                                        name: "telemetry",
                                        containerPort: 8081,
                                    },
                                ],
                                readinessProbe: {
                                    httpGet: {
                                        path: "/healthz",
                                        port: 8080,
                                    },
                                    initialDelaySeconds: 5,
                                    timeoutSeconds: 5,
                                },
                                resources: {
                                    limits: {
                                        memory: "2000Mi",
                                    },
                                    requests: {
                                        cpu: "0.5",
                                        memory: "2000Mi",
                                    },
                                },
                            },
                        ],
                    },
                },
            },
        },
        {
            apiVersion: "v1",
            kind: "ServiceAccount",
            metadata: {
                name: "kube-state-metrics-serviceaccount",
                namespace: "kube-system",
            },
        },
        {
            apiVersion: "v1",
            kind: "Service",
            metadata: {
                name: "kube-state-metrics-service",
                namespace: "kube-system",
                labels: {
                    "k8s-app": "kube-state-metrics",
                },
                annotations: {
                    "prometheus.io/scrape": "true",
                },
            },
            spec: {
                ports: [
                    {
                        name: "http-metrics",
                        port: 8080,
                        targetPort: "http-metrics",
                        protocol: "TCP",
                    },
                    {
                        name: "telemetry",
                        port: 8081,
                        targetPort: "telemetry",
                        protocol: "TCP",
                    },
                ],
                selector: {
                    "k8s-app": "kube-state-metrics",
                },
            },
        },
    ],
}
