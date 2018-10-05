{
    local estate = std.extVar("estate"),
    local kingdom = std.extVar("kingdom"),
    local slbimages = import "slbimages.jsonnet",
    local configs = import "config.jsonnet",
    local set_value_to_all_in_list(v, list) = { [k]: v for k in list },
    local set_value_to_all_in_list_skip(v, list, s) = { [k]: v for k in list if k != s },

    dirSuffix:: "",
    slbDir: "/host/data/slb",
    slbDockerDir: "/data/slb",
    configDir: self.slbDir + "/config/" + $.dirSuffix,
    logsDir: self.slbDir + "/logs/" + $.dirSuffix,
    manifestDir: self.slbDir + "/manifests/" + $.dirSuffix,
    cleanupLogsDir: self.logsDir + (if std.length($.dirSuffix) == 0 then "cleanup" else "/cleanup"),
    ipvsMarkerFile: self.slbDir + "/ipvs.marker",
    slbPortalTemplatePath: "/sdn/webfiles",
    prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra'],
    slbKingdoms: $.prodKingdoms + ["prd"],
    prodEstates: [k + "-sam" for k in $.slbKingdoms] + ['prd-samtwo'],
    testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage', 'prd-sam_storagedev'],
    slbEstates: $.prodEstates + $.testEstates,
    samrole: "samapp.slb",
    maxDeleteDefault: 10,

    perCluster: {
        ddiService: {
            [k]: "https://ddi-api-" + k + ".data.sfdc.net"
            for k in $.slbKingdoms
        },

        subnet: {
            "prd-sdc": "10.254.247.0/24",
            "prd-samtest": "10.251.129.241-242",
            "prd-samdev": "10.251.129.243-248",
            "prd-sam_storage": "10.251.129.249-254,10.251.199.240-247",
            "prd-sam_storagedev": "",  # TODO: find a real subnet for this new estate.
            "prd-sam": "10.251.196.0/22",
            "frf-sam": "10.214.36.0/22",
            "phx-sam": "10.208.208.0/22",
            "iad-sam": "10.208.108.0/22",
            "ord-sam": "10.208.148.0/22",
            "dfw-sam": "10.214.188.0/22",
            "hnd-sam": "10.213.100.0/22",
            "xrd-sam": "10.229.32.0/22",
            "cdg-sam": "10.229.136.0/22",
            "fra-sam": "10.160.8.0/22",
            "prd-samtwo": "10.254.252.0/22",
        },

        publicSubnet: {
            "prd-sdc": "",
            "prd-samtest": "",
            "prd-samdev": "",
            "prd-sam_storage": "",
            "prd-sam_storagedev": "",
            "prd-sam": "",
            "frf-sam": "185.79.140.0/23",
            "phx-sam": "13.110.30.0/23",
            "iad-sam": "13.110.24.0/23",
            "ord-sam": "13.110.26.0/23",
            "dfw-sam": "13.110.28.0/23",
            "hnd-sam": "161.71.144.0/23",
            "xrd-sam": "",
            "cdg-sam": "85.222.142.0/23",
            "fra-sam": "85.222.140.0/23",
            "par-sam": "185.79.142.0/23",
            "ukb-sam": "161.71.146.0/23",
            "prd-samtwo": "",
        },

        reservedIps: {
            "prd-sdc": "",
            "prd-samtest": "",
            "prd-samdev": "",
            "prd-sam_storage": "",
            "prd-sam_storagedev": "",
            "prd-sam": "10.251.196.91/32,10.251.196.42/32,10.251.196.111/32,10.251.196.44/32",
            "frf-sam": "",
            "phx-sam": "",
            "iad-sam": "10.208.108.0/32",
            "ord-sam": "10.208.148.10/32",
            "dfw-sam": "",
            "hnd-sam": "",
            "xrd-sam": "",
            "cdg-sam": "",
            "fra-sam": "",
            "par-sam": "",
            "ukb-sam": "",
            "prd-samtwo": "",
        },

        serviceList: {
            "prd-sam": "csrlb,controlplane-ptest",
        } + set_value_to_all_in_list_skip("", $.slbEstates, "prd-sam"),

        servicesToLbOverride: {
            "prd-sdc": "",
            "prd-sam": "",
        },

        servicesNotToLbOverride: {
            "prd-sdc": "slb-canary-proxy-tcp-service",
            "prd-sam": "slb-canary-proxy-http-service,slb-alpha-svc,slb-bravo-svc,slb-canary-service",
        },

        namespace: set_value_to_all_in_list("", $.slbEstates),

        useProxyServicesList: {
            "prd-sdc": "slb-bravo-svc",
            "prd-sam": "slb-bravo-svc,csrlb,controlplane-ptest,cyanlb,controlplane-ptest-lb",
        } + set_value_to_all_in_list_skip("", $.prodEstates, "prd-sam")
          + set_value_to_all_in_list_skip("", $.testEstates, "prd-sdc"),

        podLabelList: {
            "prd-sdc": "name=slb-node-api, name=slb-ipvs, name=slb-portal, name=slb-realsvrcfg, name=slb-dns-register, name=slb-node-os-stats, name=slb-vip-watchdog, name=slb-nginx-config-b, name=slb-ipvsdata-watchdog, name=slb-iface-processor, name=slb-echo-client, name=slb-echo-server, name=slb-cleanup, name=slb-canary-proxy-tcp, name=slb-canary-proxy-http, name=slb-canary-passthrough-tls, name=slb-canary-passthrough-host-network, name=slb-canary, name=slb-bravo",
            "prd-sam": "name=slb-node-api, name=slb-ipvs, name=slb-portal, name=slb-realsvrcfg, name=slb-dns-register, name=slb-node-os-stats, name=slb-vip-watchdog, name=slb-nginx-config-b, name=slb-ipvsdata-watchdog, name=slb-iface-processor, name=slb-echo-client, name=slb-echo-server, name=slb-cleanup, name=slb-canary-proxy-tcp, name=slb-canary-proxy-http, name=slb-canary-passthrough-tls, name=slb-canary-passthrough-host-network, name=slb-canary, name=slb-bravo",
            "prd-samtest": "name=slb-vip-watchdog",
            "prd-samdev": "name=slb-vip-watchdog",
            "prd-sam_storage": "name=slb-vip-watchdog",
            "prd-sam_storagedev": "name=slb-vip-watchdog",
        },
        useVipLabelToSelectSvcs: set_value_to_all_in_list(true, $.slbEstates),
        kneDomainName: {
            "prd-sdc": "prd-sdc.slb.sfdc.net",
        } + set_value_to_all_in_list_skip("", $.testEstates, "prd-sdc")
          + set_value_to_all_in_list("slb.sfdc.net", $.prodEstates),

        processKnEConfigs: {
            "prd-sdc": true,
            "prd-samtest": false,
            "prd-samdev": false,
            "prd-sam_storage": false,
            "prd-sam_storagedev": false,
            "prd-samtwo": true,
        } + set_value_to_all_in_list(true, $.prodEstates),

        kneConfigDir: {
            "prd-sdc": "/var/slb/kneconfigs/testkneconfigs",
            "prd-samtest": "/var/slb/kneconfigs/testkneconfigs",
            "prd-samdev": "/var/slb/kneconfigs/testkneconfigs",
            "prd-sam_storage": "/var/slb/kneconfigs/testkneconfigs",
            "prd-sam_storagedev": "/var/slb/kneconfigs/testkneconfigs",
            "prd-samtwo": "/var/slb/kneconfigs/testkneconfigs",
        } + {
            [k + "-sam"]: "/var/slb/kneconfigs/" + k
            for k in $.slbKingdoms
        },
        canaryMaxParallelism: {
            "prd-samtwo": 2,
        } + set_value_to_all_in_list_skip(1, $.testEstates, "prd-samtwo")
          + set_value_to_all_in_list(2, $.prodEstates)
        + {
            "fra-sam": 4,
            "cdg-sam": 4,
        },

        vipwdOptOutOptions: {
            "prd-sam": ["--optOutServiceList=pra-sfc-prd,pra-dsm-prd", "--optOutNamespace=podgroup-prebuild"],
            "xrd-sam": ["--optOutServiceList=slb-canary-service-ext"],
        },

        maxDeleteCount: {
            "prd-sdc": $.maxDeleteDefault,
            "prd-samtest": $.maxDeleteDefault,
            "prd-samdev": $.maxDeleteDefault,
            "prd-sam_storage": $.maxDeleteDefault,
            "prd-sam_storagedev": $.maxDeleteDefault,
            "prd-sam": $.maxDeleteDefault,
            "frf-sam": $.maxDeleteDefault,
            "phx-sam": $.maxDeleteDefault,
            "iad-sam": $.maxDeleteDefault,
            "ord-sam": $.maxDeleteDefault,
            "dfw-sam": $.maxDeleteDefault,
            "hnd-sam": $.maxDeleteDefault,
            "xrd-sam": $.maxDeleteDefault,
            "cdg-sam": $.maxDeleteDefault,
            "fra-sam": $.maxDeleteDefault,
            "prd-samtwo": $.maxDeleteDefault,
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
    publicSubnet: self.perCluster.publicSubnet[estate],
    reservedIps: self.perCluster.reservedIps[estate],
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
    slbProdCluster: estate in { [k]: 1 for k in $.prodEstates },
    slbInKingdom: kingdom in { [k]: 1 for k in $.slbKingdoms },
    slbInProdKingdom: kingdom in { [k]: 1 for k in $.prodKingdoms },
    isTestEstate: estate in { [e]: 1 for e in $.testEstates },
    isProdEstate: estate in { [e]: 1 for e in $.prodEstates },
    isSlbEstate: estate in { [e]: 1 for e in $.slbEstates },

    sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
    sdn_watchdog_emailrec: "slb@salesforce.com",

    customerCertsPath: "/customerCerts",
}
