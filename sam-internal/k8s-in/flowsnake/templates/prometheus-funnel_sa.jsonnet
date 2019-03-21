local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.is_minikube then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            automountServiceAccountToken: true,
            metadata: {
                namespace: "flowsnake",
                name: "prometheus-scraper",
            },
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "prometheus-scraper-binding",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "prometheus-scraper-role",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "prometheus-scraper",
                    namespace: "flowsnake",
                },
            ],
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1",
            kind: "ClusterRole",
            metadata: {
                name: "prometheus-scraper-role",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: [""],
                    resources: ["pods", "nodes", "nodes/proxy", "customresourcedefinitions"],
                    verbs: ["get", "list", "watch"],
                },
                {
                    apiGroups: ["apiextensions.k8s.io"],
                    resources: ["customresourcedefinitions"],
                    verbs: ["get", "list", "watch"],
                },
                {
                    apiGroups: ["sparkoperator.k8s.io"],
                    resources: ["sparkapplications", "scheduledsparkapplications"],
                    verbs: ["get", "list", "watch"],
                },
                {
                    nonResourceURLs: ["/metrics", "/metrics/cadvisor"],
                    verbs: ["get"],
                },
            ],
        },
    ],
}
