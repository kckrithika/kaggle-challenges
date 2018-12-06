local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.kubernetes_create_user_auth then (
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
                name: "flowsnake-impersonation-proxy",
            }
        },
        {
            kind: "ClusterRole",
            apiVersion: "rbac.authorization.k8s.io/v1",   
            metadata: {
                name: "impersonate-any-user",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: [""],
                    resources: ["users", "groups"],
                    verbs: ["impersonate"]
                }
            ]
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "impersonator-proxy-impersonates",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "impersonate-any-user",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "flowsnake-impersonation-proxy",
                    namespace: "flowsnake",
                }
            ]
        },
    ]
}
) else "SKIP"








