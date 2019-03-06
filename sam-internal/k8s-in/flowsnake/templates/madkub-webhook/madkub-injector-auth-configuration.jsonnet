local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "madkub_injector");

if enabled then
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
                name: "madkub-injector-serviceaccount",
            }
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "madkub-injector-clusterrolebinding",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "view",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    namespace: "flowsnake",
                    name: "madkub-injector-serviceaccount",
                }
            ]
        }
    ]
} else "SKIP"
