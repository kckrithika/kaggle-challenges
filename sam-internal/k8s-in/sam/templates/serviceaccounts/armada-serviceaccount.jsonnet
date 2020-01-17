local configs = import "config.jsonnet";

local utils = import "util_functions.jsonnet";

if configs.estate == "prd-sam" then {
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
                name: "armada-sa",
            },
        },
        {
            kind: "ClusterRoleBinding",
            apiVersion: "rbac.authorization.k8s.io/v1",
            metadata: {
                name: "armada-rolebind",
                annotations: {
                     "manifestctl.sam.data.sfdc.net/swagger": "disable",
                },
            },
            roleRef: {
                kind: "ClusterRole",
                name: "armada-sa",
                apiGroup: "rbac.authorization.k8s.io",
            },
            subjects: [
                {
                    kind: "ServiceAccount",
                    namespace: "sam-system",
                    name: "armada-sa",
                },
            ],
        },
        {
            apiVersion: "rbac.authorization.k8s.io/v1beta1",
            kind: "ClusterRole",
            metadata: {
                name: "armada-sa",
            },
            rules: [
            {
                apiGroups: ["*"],
                resources: ["*"],
                verbs: ["*"],
            },
        ],
        },
    ]
} else "SKIP"