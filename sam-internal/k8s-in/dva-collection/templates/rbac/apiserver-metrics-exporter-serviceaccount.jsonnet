local collectionUtils = import "collection-agent-utils.jsonnet";

if collectionUtils.apiserver.featureFlag then {
    apiVersion: "v1",
    kind: "ServiceAccount",
    metadata: {
        name: collectionUtils.apiserver.name,
        namespace: collectionUtils.apiserver.namespace,
    },
    automountServiceAccountToken: true,
} else "SKIP"
