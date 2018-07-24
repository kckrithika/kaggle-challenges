{
    local estate = std.extVar("estate"),
    local kingdom = std.extVar("kingdom"),
    local slbimages = import "slbimages.jsonnet",
    local configs = import "config.jsonnet",

    dirSuffix:: "",
    slbDir: "/host/data/slb",
    slbDockerDir: "/data/slb",
    configDir: self.slbDir + "/config/" + $.dirSuffix,
    logsDir: self.slbDir + "/logs/" + $.dirSuffix,
    cleanupLogsDir: self.logsDir + (if std.length($.dirSuffix) == 0 then "cleanup" else "/cleanup"),
    ipvsMarkerFile: self.slbDir + "/ipvs.marker",
    slbPortalTemplatePath: "/sdn/webfiles",
    prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra'],
    testEstateList: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage', 'prd-sam_storagedev'],
    samrole: "samapp.slb",
    perCluster: {
        ddiService: {
            [k]: "https://ddi-api-" + k + ".data.sfdc.net"
            for k in $.prodKingdoms + ["prd"]
        },

        subnet: {
            "prd-sdc": "10.251.129.224-233,10.251.129.235-240",
            "prd-samtest": "10.251.129.241-242",
            "prd-samdev": "10.251.129.243-248",
            "prd-sam_storage": "10.251.129.249-254,10.251.199.240-247",
            "prd-sam_storagedev": "",  # TODO: find a real subnet for this new estate.
            "prd-sam": "10.251.196.0-255,10.251.197.0-255,10.251.198.0-255,10.251.199.0-239",
            "frf-sam": "10.214.36.0/22",
            "phx-sam": "10.208.208.0/22",
            "iad-sam": "10.208.108.0/22",
            "ord-sam": "10.208.148.0/22",
            "dfw-sam": "10.214.188.0/22",
            "hnd-sam": "10.213.100.0/22",
            "xrd-sam": "10.229.32.0/22",
            "cdg-sam": "10.229.136.0/22",
            "fra-sam": "10.160.8.0/22",
            # prd-sam-a : 10.251.199.248-255
        },

        serviceList: {
            "prd-sdc": "",
            "prd-samtest": "",
            "prd-samdev": "",
            "prd-sam_storage": "",
            "prd-sam_storagedev": "",
            "prd-sam": "csrlb,controlplane-ptest",
        } + {
            [k + "-sam"]: ""
            for k in $.prodKingdoms
        },

        servicesToLbOverride: {
            "prd-sdc": "",
            "prd-sam": "",
        },

        servicesNotToLbOverride: {
            "prd-sdc": "slb-canary-proxy-tcp-service",
            "prd-sam": "slb-canary-proxy-http-service,slb-alpha-svc,slb-bravo-svc,slb-canary-service",
        },

        namespace: {
            "prd-sdc": "",
            "prd-samtest": "",
            "prd-samdev": "",
            "prd-sam_storage": "",
            "prd-sam_storagedev": "",
        } + {
            [k + "-sam"]: ""
            for k in $.prodKingdoms + ["prd"]
        },

        useProxyServicesList: {
            "prd-sdc": "slb-bravo-svc",
            "prd-samtest": "",
            "prd-samdev": "",
            "prd-sam_storage": "",
            "prd-sam_storagedev": "",
            "prd-sam": "slb-bravo-svc,csrlb,controlplane-ptest,cyanlb,controlplane-ptest-lb",
        } + {
            [k + "-sam"]: ""
            for k in $.prodKingdoms
        },

        podLabelList: {
            "prd-sdc": "name=slb-node-api, name=slb-ipvs, name=slb-portal, name=slb-realsvrcfg, name=slb-dns-register, name=slb-node-os-stats, name=slb-vip-watchdog, name=slb-nginx-config, name=slb-ipvsdata-watchdog, name=slb-iface-processor, name=slb-echo-client, name=slb-echo-server, name=slb-cleanup, name=slb-canary-proxy-tcp, name=slb-canary-proxy-http, name=slb-canary-passthrough-tls, name=slb-canary-passthrough-host-network, name=slb-canary, name=slb-bravo",
            "prd-sam": "name=slb-node-api, name=slb-ipvs, name=slb-portal, name=slb-realsvrcfg, name=slb-dns-register, name=slb-node-os-stats, name=slb-vip-watchdog, name=slb-nginx-config, name=slb-ipvsdata-watchdog, name=slb-iface-processor, name=slb-echo-client, name=slb-echo-server, name=slb-cleanup, name=slb-canary-proxy-tcp, name=slb-canary-proxy-http, name=slb-canary-passthrough-tls, name=slb-canary-passthrough-host-network, name=slb-canary, name=slb-bravo",
            "prd-samtest": "name=slb-vip-watchdog",
            "prd-samdev": "name=slb-vip-watchdog",
            "prd-sam_storage": "name=slb-vip-watchdog",
            "prd-sam_storagedev": "name=slb-vip-watchdog",
        },
        useVipLabelToSelectSvcs: {
            "prd-sdc": true,
            "prd-samtest": true,
            "prd-samdev": true,
            "prd-sam_storage": true,
            "prd-sam_storagedev": true,
        } + {
            [k + "-sam"]: true
            for k in $.prodKingdoms + ["prd"]
        },
        kneDomainName: {
            "prd-sdc": "prd-sdc.slb.sfdc.net",
            "prd-samtest": "",
            "prd-samdev": "",
            "prd-sam_storage": "",
            "prd-sam_storagedev": "",
        } + {
            [k + "-sam"]: "slb.sfdc.net"
            for k in $.prodKingdoms + ["prd"]
        },
        processKnEConfigs: {
            "prd-sdc": true,
            "prd-samtest": false,
            "prd-samdev": false,
            "prd-sam_storage": false,
            "prd-sam_storagedev": false,
            "prd-sam": true,
        } + {
            [k + "-sam"]: true
            for k in $.prodKingdoms
        },
        kneConfigDir: {
            "prd-sdc": "/var/slb/kneconfigs/testkneconfigs",
            "prd-samtest": "/var/slb/kneconfigs/testkneconfigs",
            "prd-samdev": "/var/slb/kneconfigs/testkneconfigs",
            "prd-sam_storage": "/var/slb/kneconfigs/testkneconfigs",
            "prd-sam_storagedev": "/var/slb/kneconfigs/testkneconfigs",
        } + {
            [k + "-sam"]: "/var/slb/kneconfigs/" + k
            for k in $.prodKingdoms + ["prd"]
        },
        canaryMaxParallelism: {
            "prd-sdc": 1,
            "prd-samtest": 1,
            "prd-samdev": 1,
            "prd-sam_storage": 1,
            "prd-sam_storagedev": 1,
            "prd-sam": 2,
        } + {
            [k + "-sam"]: 2
            for k in $.prodKingdoms
        },

        vipwdOptOutOptions: {
            "prd-sdc": ["--optOutNamespace=kne"],
            "prd-sam": ["--optOutServiceList=pra-sfc-prd,pra-dsm-prd", "--optOutNamespace=kne,podgroup-prebuild"],
            "xrd-sam": ["--optOutServiceList=slb-canary-service-ext"],
        },
    },


    # Frequently used volume: slb
    slb_volume: {
        name: "var-slb-volume",
        hostPath: {
            path: "/data/slb",
        },
    },
    slb_volume_mount: {
        name: "var-slb-volume",
        mountPath: "/host/data/slb",
    },

    # Frequently used volume: slb-config
    slb_config_volume: {
        name: "var-config-volume",
        hostPath: {
            path: "/data/slb/config/" + $.dirSuffix,
        },
    },
    slb_config_volume_mount: {
        name: "var-config-volume",
        mountPath: "/host/data/slb/config/" + $.dirSuffix,
    },

    # Frequently used volume: logs
    logs_volume: {
        name: "var-logs-volume",
        hostPath: {
            path: "/data/slb/logs/" + $.dirSuffix,
        },
    },
    logs_volume_mount: {
        name: "var-logs-volume",
        mountPath: "/host/data/slb/logs/" + $.dirSuffix,
    },
    nginx_logs_volume_mount: {
        name: "var-logs-volume",
        mountPath: "/host/data/slb/logs",
    },
    cleanup_logs_volume: {
        name: "var-cleanup-logs-volume",
        hostPath: {
            path: if std.length($.dirSuffix) == 0 then "/data/slb/logs/cleanup" else "/data/slb/logs/" + $.dirSuffix + "/cleanup",
        },
    },
    cleanup_logs_volume_mount: {
        name: "var-cleanup-logs-volume",
        mountPath: if std.length($.dirSuffix) == 0 then "/host/data/slb/logs/cleanup" else "/host/data/slb/logs/" + $.dirSuffix + "/cleanup",
    },

    # Frequently used volume: host/sbin
    sbin_volume: {
        name: "sbin-volume",
        hostPath: {
            path: "/sbin",
        },
    },
    sbin_volume_mount: {
        name: "sbin-volume",
        mountPath: "/host/sbin",
    },
    # Frequently used volume: /usr/sbin
    usr_sbin_volume: {
        name: "usr-sbin-volume",
        hostPath: {
            path: "/usr/sbin",
        },
    },
    usr_sbin_volume_mount: {
        name: "usr-sbin-volume",
        mountPath: "/host/usr/sbin",
    },
    # Frequently used volume: /proc
    proc_volume: {
        name: "proc-volume",
        hostPath: {
            path: "/proc",
        },
    },
    proc_volume_mount: {
        name: "proc-volume",
        mountPath: "/host/proc",
    },

    # Frequently used env variable: NODE_NAME
    node_name_env: {
        name: "NODE_NAME",
        valueFrom: {
            fieldRef: {
                fieldPath: "spec.nodeName",
            },
        },
    },
    subnet: self.perCluster.subnet[estate],
    serviceList: self.perCluster.serviceList[estate],
    namespace: self.perCluster.namespace[estate],
    ddiService: self.perCluster.ddiService[kingdom],
    useProxyServicesList: self.perCluster.useProxyServicesList[estate],
    podLabelList: self.perCluster.podLabelList[estate],
    useVipLabelToSelectSvcs: self.perCluster.useVipLabelToSelectSvcs[estate],
    kneDomainName: self.perCluster.kneDomainName[estate],
    processKnEConfigs: self.perCluster.processKnEConfigs[estate],
    kneConfigDir: self.perCluster.kneConfigDir[estate],
    configurePerPort: self.perCluster.configurePerPort[estate],
    servicesToLbOverride: self.perCluster.servicesToLbOverride[estate],
    servicesNotToLbOverride: self.perCluster.servicesNotToLbOverride[estate],
    canaryMaxParallelism: self.perCluster.canaryMaxParallelism[estate],
    slbInKingdom: kingdom in { [k]: 1 for k in $.prodKingdoms + ["prd"] },
    slbInProdKingdom: kingdom in { [k]: 1 for k in $.prodKingdoms },
    isTestEstate: estate in { [e]: 1 for e in $.testEstateList },

    sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
    sdn_watchdog_emailrec: "slb@salesforce.com",
}
