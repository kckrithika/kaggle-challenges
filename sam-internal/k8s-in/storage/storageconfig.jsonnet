{
local estate = std.extVar("estate"),

    perCluster: {
        k8s_subnet: {
            "prd-sam_storage": "10.251.0.0./16",
            "prd-sam_cephdev": "10.251.0.0./16",
            "prd-sam_sfstoredev": "10.251.0.0./16",
            "prd-sam": "10.251.0.0./16",
            "prd-sam_ceph": "10.251.0.0./16",
            "prd-sam_sfstore": "10.251.0.0./16",
        },
        fds_per_pod_capacity: {
            "prd-sam_storage": "5720584Mi",
            "prd-sam_cephdev": "5720584Mi",
            "prd-sam_sfstoredev": "5720584Mi",
            "prd-sam": "5720584Mi",
            "prd-sam_ceph": "5720584Mi",
            "prd-sam_sfstore": "5720584Mi",
        },
        fds_profiling: {
            "prd-sam_storage": "true",
            "prd-sam_cephdev": "true",
            "prd-sam_sfstoredev": "true",
            "prd-sam": "true",
            "prd-sam_ceph": "true",
            "prd-sam_sfstore": "true",
        },
    },

k8s_subnet: self.perCluster.k8s_subnet[estate],
fds_per_pod_capacity: self.perCluster.fds_per_pod_capacity[estate],
fds_profiling: self.perCluster.fds_profiling[estate],
}
