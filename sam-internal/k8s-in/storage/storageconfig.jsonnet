{
    local estate = std.extVar("estate"),
    local kingdom = std.extVar("kingdom"),

    // Map of Ceph control estate -> cluster estate.
    cephEstates: {
        "prd-skipper": ["prd-skipper"],
        "prd-sam": ["prd-sam_ceph"],
        "prd-sam_storage": ["prd-sam_cephdev", "prd-sam_storage"],
    },

    // Map of SFStore control estate -> cluster estate.
    sfstoreEstates: {
        "prd-skipper": ["prd-skipper"],
        "prd-sam": ["prd-sam_sfstore"],
        "prd-sam_storage": ["prd-sam_sfstoredev"],
    },

    // Map of Zookeeper control estate -> cluster estate.
    zookeeperEstates: {
        "prd-skipper": [],
        "prd-sam": [],
        "prd-sam_storage": [],
        "prd-sam_storagedev": ["prd-sam_storagedev"],
    },

    serviceDefn: {
        fds_svc: {
                "name" : 'fds',
                controller: {
                    "port-name" : "fds-controller-port",
                    "port" : 8080,
                    "port-config" : '"port":8080,"targetport":8080,"lbtype":"tcp"',
                }
            },
        ceph_metrics_svc: {
                "name" : 'ceph-metrics',
                health: {
                    "port-name" : "ceph-metrics",
                    "port" : 8001,
                    "port-config" : '"port":8001,"targetport":8001,"lbtype":"tcp"',
                }
            },
        sfn_metrics_svc: {
                "name" : 'sfn-metrics',
                health: {
                    "port-name" : "sfn-metrics",
                    "port" : 8080,
                    "port-config" : '"port":8080,"targetport":8080,"lbtype":"tcp"',
                }
            },
        alert_mgr_svc: {
                "name" : 'alertmanager',
                alert_hook: {
                    "port-name" : "alert-hook",
                    "port" : 15212,
                    "port-config" : '"port":15212,"targetport":15212,"lbtype":"tcp"',
                },
                alert_publisher: {
                    "port-name" : "alert-publisher",
                    "port" : 15213,
                    "port-config" : '"port":15213,"targetport":15213,"lbtype":"tcp"',
                }
            },
    },

    // Aggregate all the storage related minion estates in the control plane.
    storageEstates: [ minion for minion in self.cephEstates[estate] + self.sfstoreEstates[estate] + self.zookeeperEstates[estate]],
    perEstate: {
        ceph: {
            // host subnets from https://git.soma.salesforce.com/estates/estates/tree/master/kingdoms/
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
                    "prd-sam_ceph": "152Ti",
                },
            },
        },
        sfstore: {
            zkVIP: {
                "prd-skipper" : "zk-external.zookeeper.svc.cluster.local:2181",
                "prd-sam" : "sfstore-zk.slb.sfdc.net",
                "prd-sam_storage" : "sfstore-zk.slb.sfdc.net",
            },
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
        zookeeper: {
            replicas: {
                "prd-sam_storagedev": 3,
            },
            boundary: {
                "prd-sam_storagedev": "kubernetes.io/hostname",
            },
            version: {
                "prd-sam_storagedev": "3.4.9",
            },
        },
    },

    perCluster: {
        fds_profiling: {
            "prd-sam_storagedev": "true",
            "prd-skipper": "true",
            "prd-sam_storage": "true",
            "prd-sam": "true",
        },
    },


    fds_profiling: self.perCluster.fds_profiling[estate],
    cephMetricsPool: (if estate == "prd-sam_storage" then self.cephEstates[estate][1] else self.cephEstates[estate][0]),

}
