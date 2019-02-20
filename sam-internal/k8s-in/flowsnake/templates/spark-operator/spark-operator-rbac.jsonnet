local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "spark_operator");

if enabled then
{
    apiVersion: "v1",
    kind: "List",
    items: [
        {
            apiVersion: "v1",
            kind: "ServiceAccount",
            metadata: {
                name: "spark-operator",
                namespace: "flowsnake",
            },
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1beta1",
            kind: "ClusterRole",
            metadata: {
                name: "spark-operator",
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
                    resources: ["mutatingwebhookconfigurations"],
                    verbs: ["create", "get", "update", "delete"],
                },
                {
                    apiGroups: ["sparkoperator.k8s.io"],
                    resources: ["sparkapplications", "scheduledsparkapplications"],
                    verbs: ["*"],
                },
            ],
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1beta1",
            kind: "ClusterRoleBinding",
            metadata: {
                name: "spark-operator",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "spark-operator",
                    namespace: "flowsnake",
                },
            ],
            roleRef: {
              kind: "ClusterRole",
              name: "spark-operator",
              apiGroup: "rbac.authorization.k8s.io",
            },
        }
    ]
} else "SKIP"
