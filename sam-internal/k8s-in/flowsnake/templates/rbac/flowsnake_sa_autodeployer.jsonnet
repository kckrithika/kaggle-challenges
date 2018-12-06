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
                namespace: "sam-system",
                name: "sam-autodeployer",
            }
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "autodeployer-is-admin",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "cluster-admin",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "sam-autodeployer",
                    namespace: "sam-system",
                }
            ]
        }
    ]
}
) else "SKIP"