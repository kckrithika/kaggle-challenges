{
local estate = std.extVar("estate"),

    perCluster: {
        k8s_subnet: {
            "prd-sam_storage": "10.251.0.0./16",
        },
        fds_per_pod_capacity: {
            "prd-sam_storage": "5720584Mi",
        },
        fds_profiling: {
            "prd-sam_storage": "true",
        },
    },

k8s_subnet: self.perCluster.k8s_subnet[estate],
fds_per_pod_capacity: self.perCluster.fds_per_pod_capacity[estate],
fds_profiling: self.perCluster.fds_profiling[estate],
}
