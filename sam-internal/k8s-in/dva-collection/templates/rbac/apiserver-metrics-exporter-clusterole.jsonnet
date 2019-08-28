local collectionUtils = import "collection-agent-utils.jsonnet";

if collectionUtils.apiserver.featureFlag then {
    apiVersion: "rbac.authorization.k8s.io/v1beta1",
    kind: "ClusterRole",
    metadata: {
        name: collectionUtils.apiserver.name,
        namespace: collectionUtils.apiserver.namespace,
    },
    rules: [
        {
            nonResourceURLs: [
                "/metrics",
            ],
            verbs: [
                "get",
            ],
        },
    ],
} else "SKIP"
