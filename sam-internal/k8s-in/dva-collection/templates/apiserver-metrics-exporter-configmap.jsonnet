local collectionUtils = import "collection-agent-utils.jsonnet";

local configTemplate = importstr "configs/ocagent/opencensus.apiserver-metrics-exporter.yaml.erb";

if collectionUtils.apiserver.featureFlag then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: collectionUtils.apiserver.configMapName,
        namespace: collectionUtils.apiserver.namespace,
    },
    data: {
        "opencensus.cluster-metrics-exporter.yaml.erb": configTemplate,
    },
} else "SKIP"
