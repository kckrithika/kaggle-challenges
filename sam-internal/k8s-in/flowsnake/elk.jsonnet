local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";
{
    elastic_search_enabled: (
        estate == "prd-data-flowsnake" ||
        estate == "prd-data-flowsnake_test" ||
        estate == "prd-dev-flowsnake_iot_test" ||
        (flowsnake_config.is_minikube && !flowsnake_config.is_minikube_small)
    ),
    zk_replicas: if flowsnake_config.is_minikube_small then 1 else 3,
    kafka_replicas: if flowsnake_config.is_minikube_small then 1 else 3,
    kafka_partitions: if flowsnake_config.is_minikube_small then 1 else 3,
    // NodePort allowed range is different in Minikube; compensate accordingly.
    kibana_nodeport: if flowsnake_config.is_minikube then 30003 else 32003,
}
