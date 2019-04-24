local flowsnake_images = import "flowsnake_images.jsonnet";
local quota_enforcement = std.objectHas(flowsnake_images.feature_flags, "spark_application_quota_enforcement");

{
    apiVersion: "v1",
    kind: "List",
    items: [
        {
            apiVersion: "v1",
            kind: "ServiceAccount",
            metadata: {
                name: "spark-operator-serviceaccount",
                namespace: "flowsnake",
            },
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1beta1",
            kind: "ClusterRole",
            metadata: {
                name: "spark-operator-clusterrole",
            },
            rules: [
                {
                    apiGroups: [""],
                    resources: ["pods"],
                    verbs: ["*"],
                },
                {
                    apiGroups: [""],
                    resources: ["services", "configmaps", "secrets"],
                    verbs: ["create", "get", "delete"],
                },
                {
                    apiGroups: [""],
                    resources: ["nodes"],
                    verbs: ["get"],
                },
                {
                    apiGroups: [""],
                    resources: ["events"],
                    verbs: ["create", "update", "patch"],
                },
                {
                    apiGroups: ["apiextensions.k8s.io"],
                    resources: ["customresourcedefinitions"],
                    verbs: ["create", "get", "update", "delete"],
                },
                {
                    apiGroups: ["extensions"],
                    resources: ["ingresses"],
                    verbs: ["create", "get", "update", "delete"],
                },
                {
                    apiGroups: ["admissionregistration.k8s.io"],
                    resources: ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"],
                    verbs: ["create", "get", "update", "delete"],
                },
                {
                    apiGroups: ["sparkoperator.k8s.io"],
                    resources: ["sparkapplications", "scheduledsparkapplications"],
                    verbs: ["*"],
                },
            ] + (if quota_enforcement then [
                {
                    apiGroups: [""],
                    resources: ["resourcequotas"],
                    verbs: ["get", "watch", "list"],
                },
            ] else []),
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1beta1",
            kind: "ClusterRoleBinding",
            metadata: {
                name: "spark-operator-clusterrolebinding",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "spark-operator-serviceaccount",
                    namespace: "flowsnake",
                },
            ],
            roleRef: {
              kind: "ClusterRole",
              name: "spark-operator-clusterrole",
              apiGroup: "rbac.authorization.k8s.io",
            },
        }
    ]
}
