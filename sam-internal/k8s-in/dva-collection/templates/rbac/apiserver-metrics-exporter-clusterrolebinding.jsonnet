local collectionUtils = import "collection-agent-utils.jsonnet";

if collectionUtils.apiserver.featureFlag then {
    apiVersion: "rbac.authorization.k8s.io/v1beta1",
    kind: "ClusterRoleBinding",
    metadata: {
        name: collectionUtils.apiserver.name,
        namespace: collectionUtils.apiserver.namespace,
    },
    roleRef: {
        apiGroup: "rbac.authorization.k8s.io",
        kind: "ClusterRole",
        name: collectionUtils.apiserver.name,
    },
    subjects: [
        {
            kind: "ServiceAccount",
            name: collectionUtils.apiserver.name,
            namespace: collectionUtils.apiserver.namespace,
        },
    ],
} else "SKIP"
