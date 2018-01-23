{
    local estate = std.extVar("estate"),

    // Map of Ceph control estate -> cluster estate.
    cephEstates: {
        "prd-skipper": ["prd-skipper"],
        "prd-sam": ["prd-sam_ceph"],
        "prd-sam_storage": ["prd-sam_cephdev", "prd-sam_storage"],
        "phx-sam": ["phx-sam_ceph"], # Do Not uncomment until you deploy Ceph Cluster to Prod
    },

    // Map of SFStore control estate -> cluster estate.
    sfstoreEstates: {
        "prd-skipper": ["prd-skipper"],
        "prd-sam": ["prd-sam_sfstore"],
        "prd-sam_storage": ["prd-sam_sfstoredev"],
        "phx-sam": [],
    },

    // Aggregate all the storage related minion estates in the control plane.
    storageEstates: [ minion for minion in self.cephEstates[estate] + self.sfstoreEstates[estate]],
    perEstate: {
        ceph: {
            // host subnets from git.soma.salesforce.com/estates/estates/tree/master/kingdoms/prd
            k8s_subnet: {
                "prd-skipper": {
                    "prd-skipper": "10.248.0.0/13",
                },
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
                "prd-skipper": {
                    "prd-skipper": "5Gi",
                },
                "prd-sam_storage": {
                    "prd-sam_storage": "1Ti",
                    "prd-sam_cephdev": "1Ti",
                },
                "prd-sam": {
                    "prd-sam_ceph": "180Ti",
                },
                "phx-sam": {
                    "phx-sam_ceph": "273Ti",
                },
            },
        },
        sfstore: {
            zkServer: {
                "prd-skipper" : "zk-external.zookeeper.svc.cluster.local:2181",
                "prd-sam" : "sfstorezk0-dnds1-1-prd.eng.sfdc.net:2181,sfstorezk0-dnds1-2-prd.eng.sfdc.net:2181,sfstorezk0-dnds2-1-prd.eng.sfdc.net:2181",
                "prd-sam_storage" : "sfstorezk0-dnds1-1-prd.eng.sfdc.net:2181,sfstorezk0-dnds1-2-prd.eng.sfdc.net:2181,sfstorezk0-dnds2-1-prd.eng.sfdc.net:2181",
            },
            aggregateStorage: {
                "prd-skipper": "5Gi",
                "prd-sam_sfstoredev": "500Gi",
            },
            boundary: {
                "prd-skipper": "kubernetes.io/hostname",
                "prd-sam_sfstoredev": "kubernetes.io/hostname",
            },
            version: {
                "prd-skipper": "1.10",
                "prd-sam_sfstoredev": "1.10",
            },
        },
    },

    perCluster: {
        fds_profiling: {
            "prd-skipper": "true",
            "prd-sam_storage": "true",
            "prd-sam": "true",
            "phx-sam": "false",
        },
    },


    fds_profiling: self.perCluster.fds_profiling[estate],
    cephMetricsNamespace: (if estate == "prd-sam_storage" then "ceph-test" else "legostore"),
    cephMetricsPool: (if estate == "prd-sam_storage" then self.cephEstates[estate][1] else self.cephEstates[estate][0]),

}
