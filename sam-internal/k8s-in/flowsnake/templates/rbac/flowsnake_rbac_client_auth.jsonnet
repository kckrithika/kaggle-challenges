local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_clients = import "flowsnake_direct_clients.jsonnet";

if flowsnake_config.kubernetes_create_user_auth && std.length(flowsnake_clients.clients) > 0 then (
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items:
        # ClusterRole used by all clients for certain cluster-wide actions
        [
            {
                kind: "ClusterRole",
                apiVersion: "rbac.authorization.k8s.io/v1",
                metadata: {
                    name: "client-cluster-role",
                    annotations: {
                        "manifestctl.sam.data.sfdc.net/swagger": "disable",
                    },
                },
                # This grants access to view *all* CRDs, which might be broader than required. For now,
                # sparkapplications.sparkoperator.k8s.io is the only CRD, so moot.
                rules: [
                    {
                        apiGroups: ["apiextensions.k8s.io"],
                        verbs: ["get", "list"],
                        resources: ["customresourcedefinitions"]
                    }
                ]

            }
        ] +
        std.flattenArrays([
        # Helper to work-around auto-deployer limitation of names having to be unique across kinds and namespaces
        local makeName(name, kind) = name + "-" + client.namespace + "-" + kind;
        [
        # Per-client: bind their user principal to the all-clients Cluster Role
        {
            local kind = "ClusterRoleBinding",
            kind: kind,
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: makeName("flowsnake-client", kind),
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "client-cluster-role",
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
        # Per-client: Role for their namespace
        {
            local kind = "Role",
            kind: kind,
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: makeName("flowsnake-client", kind),
                namespace: client.namespace,
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            rules: [
                {
                    apiGroups: ["*"],
                    verbs: ["*"],
                    resources: [
                        "pods",
                        "replicationcontrollers",
                        "deployments",
                        "jobs",
                        "replicasets",
                        "secrets",
                        "configmaps",
                        "statefulsets",
                        "services",
                        "ingresses",
                        "persistentvolumes",
                        "sparkapplications",
                        ]
                },
                {
                    apiGroups: ["*"],
                    verbs: ["get", "list"],
                    resources: ["*"]
                },
            ],
        },
        # Per-client: bind their user principal to their role in their namespace
        {
            local kind = "RoleBinding",
            kind: kind,
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: makeName("flowsnake-client", kind),
                namespace: client.namespace,
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                local kind = "Role",
                kind: kind,
                name: makeName("flowsnake-client", kind),
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
        # Per-client: Service accounts for Spark
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            metadata: {
                # Omit "-ServiceAccount" from name because user-facing and want to be easy to comprehend
                name: "spark-driver-" + client.namespace,
                namespace: client.namespace,
            },
            automountServiceAccountToken: true,
        },
        {
            kind: "ServiceAccount",
            apiVersion: "v1",
            metadata: {
                # Omit "-ServiceAccount" from name because user-facing and want to be easy to comprehend
                name: "spark-executor-" + client.namespace,
                namespace: client.namespace,
            },
            automountServiceAccountToken: true,
        },
        # Per-client: Grant their spark-driver same permissions as client
        {
            local kind = "RoleBinding",
            kind: kind,
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: makeName("spark-driver", kind),
                namespace: client.namespace,
                annotations: {
                    "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                local kind = "Role",
                kind: kind,
                name: makeName("flowsnake-client", kind),
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    name: "spark-driver-" + client.namespace,
                    namespace: client.namespace,
                }
            ]
        }
        # No binding for executor = no permissions

    ] for client in flowsnake_clients.clients ] )

}
) else "SKIP"
