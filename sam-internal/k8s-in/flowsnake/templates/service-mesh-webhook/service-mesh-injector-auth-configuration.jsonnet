local flowsnake_images = import "flowsnake_images.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.madkub_enabled then
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
                name: "service-mesh-injector-serviceaccount",
            }
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "service-mesh-injector-clusterrolebinding",
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
                    name: "service-mesh-injector-serviceaccount",
                }
            ]
        }
    ]
} else "SKIP"
