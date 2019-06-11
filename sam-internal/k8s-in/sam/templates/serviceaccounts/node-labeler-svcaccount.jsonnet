local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
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
                name: "node-labeler-sa",
            },
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "node-labeler-rolebind",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "update-node-label",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    namespace: "sam-system",
                    name: "node-labeler-sa",
                },
            ],
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1beta1",
            kind: "ClusterRole",
            metadata: {
                name: "update-node-label",
            },
            rules: [
            {
                apiGroups: ["*"],
                resources: ["nodes"],
                verbs: ["*"],
            },
        ],
        },
    ]
} else "SKIP"