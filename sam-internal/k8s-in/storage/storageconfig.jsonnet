{
    local estate = std.extVar("estate"),

    // Map of Ceph control estate -> cluster estate.
    cephEstates: {
        "prd-sam": ["prd-sam_ceph"],
        "prd-sam_storage": ["prd-sam_cephdev", "prd-sam_storage"],
        // "phx-sam": ["phx-sam_ceph"], # Do Not uncomment until you deploy Ceph Cluster to Prod
    },

    // Map of SFStore control estate -> cluster estate.
    sfstoreEstates: {
        "prd-sam": ["prd-sam_sfstore"],
        "prd-sam_storage": ["prd-sam_sfstoredev"],
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
        sfstore: {
            aggregateStorage: {
                "prd-sam_sfstoredev": "500Gi",
            },
            boundary: {
                "prd-sam_sfstoredev": "kubernetes.io/hostname",
            },
            version: {
                "prd-sam_sfstoredev": "1.10",
            },
        },
    },

    perCluster: {
        // TODO: fds_per_pod_capacity is a hack that will be going away shortly. FDS uses it in some cases to determine the
        //       number of pods to try to allocate in a fault domain.
        fds_per_pod_capacity: {
            "prd-sam_storage": "3813545Mi",
            "prd-sam": "3813545Mi",
            "phx-sam": "5586Gi",
        },
        fds_profiling: {
            "prd-sam_storage": "true",
            "prd-sam": "true",
            "phx-sam": "false",
        },
    },


    fds_per_pod_capacity: self.perCluster.fds_per_pod_capacity[estate],
    fds_profiling: self.perCluster.fds_profiling[estate],
    cephMetricsNamespace: (if estate == "prd-sam_storage" then "ceph-test" else "legostore"),
}