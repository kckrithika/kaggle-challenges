local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";
if flowsnake_config.is_v1_enabled then {
    elastic_search_enabled: false,
    elastic_search_replicas: if flowsnake_config.is_minikube_small then 1 else 3,
    zk_replicas: if flowsnake_config.is_minikube_small then 1 else 3,
    kafka_replicas: if flowsnake_config.is_minikube_small then 1 else 3,
    kafka_partitions: if flowsnake_config.is_minikube_small then 1 else 3,
    // NodePort allowed range is different in Minikube; compensate accordingly.
    kibana_nodeport: if flowsnake_config.is_minikube then 30003 else 32003,
} else "SKIP"
