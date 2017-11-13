{
local estate = std.extVar("estate"),

    perCluster: {
        k8s_subnet: {
            "prd-sam_storage": "10.251.0.0./16",
            "prd-sam": "10.251.0.0./16",
        },
        fds_per_pod_capacity: {
            "prd-sam_storage": "3813545Mi",
            "prd-sam": "3813545Mi",
        },
        fds_profiling: {
            "prd-sam_storage": "true",
            "prd-sam": "true",
        },
    },

k8s_subnet: self.perCluster.k8s_subnet[estate],
fds_per_pod_capacity: self.perCluster.fds_per_pod_capacity[estate],
fds_profiling: self.perCluster.fds_profiling[estate],
}
