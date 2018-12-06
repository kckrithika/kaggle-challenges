local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";

if flowsnake_config.kubernetes_create_user_auth && std.length(flowsnake_clients.clients) > 0 then (
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: std.flattenArrays([[
        {
            kind: "Role",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "flowsnake-client",
                namespace: client.namespace,
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: ["*"],
                    verbs: ["*"],
                    resources: ["pods", "replicationcontrollers", "deployments", "jobs", "replicasets", "secrets", "configmaps", "statefulsets", "services", "ingresses", "persistentvolumes"]
                },
                {
                    apiGroups: ["*"],
                    verbs: ["get", "list"],
                    resources: ["*"]
                },
            ],
        },
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "flowsnake-client",
                namespace: client.namespace,
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "Role",
                name: "flowsnake-client",
                namespace: client.namespace,
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "User",
                    name: user,
                }
                for user in client.users
            ]
        },
        # Service accounts for Spark
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            metadata: {
                name: "spark-driver",
                namespace: client.namespace,
            },
            automountServiceAccountToken: true,
        },
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            metadata: {
                name: "spark-executor",
                namespace: client.namespace,
            },
            automountServiceAccountToken: false
        },
        # Grant spark-driver same permissions as client
        {
            kind: "RoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "spark-driver",
                namespace: client.namespace,
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "Role",
                name: "flowsnake-client",
                namespace: client.namespace,
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "spark-driver",
                    namespace: client.namespace,
                }
            ]
        }
        # No binding for executor = no permissions

    ] for client in flowsnake_clients.clients ] )

}
) else "SKIP"