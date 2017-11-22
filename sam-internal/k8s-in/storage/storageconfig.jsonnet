{
    local estate = std.extVar("estate"),

    cephEstates: {
        "prd-sam": ["prd-sam_ceph"],
        "prd-sam_storage": ["prd-sam_cephdev", "prd-sam_storage"],
        // "phx-sam": ["phx-sam_ceph"], # Do Not uncomment until you deploy Ceph Cluster to Prod
    },

    perEstate: {
        ceph: {
            // host subnets from git.soma.salesforce.com/estates/estates/tree/master/kingdoms/prd
            k8s_subnet: {
                "prd-sam_storage": {
                    "prd-sam_storage": "10.231.165.0/24",
                    "prd-sam_cephdev": "10.231.172.0/24",
                },
                "prd-sam": {
                    "prd-sam_ceph": "10.231.171.0/24",
                },
                "phx-sam": {
                    "phx-sam_ceph": "10.220.25.128/25",
                },
            },
            aggregateStorage: {
                "prd-sam_storage": {
                    "prd-sam_storage": "1Ti",
                    "prd-sam_cephdev": "1Ti",
                },
                "prd-sam": {
                    "prd-sam_ceph": "180Ti",
                },
                "phx-sam": {
                    "phx-sam_ceph": "180Ti",
                },
            },
        },
    },

    perCluster: {
        fds_per_pod_capacity: {
            "prd-sam_storage": "3813545Mi",
            "prd-sam": "3813545Mi",
        },
        fds_profiling: {
            "prd-sam_storage": "true",
            "prd-sam": "true",
        },
    },


    fds_per_pod_capacity: self.perCluster.fds_per_pod_capacity[estate],
    fds_profiling: self.perCluster.fds_profiling[estate],
}