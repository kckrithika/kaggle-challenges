{
    local estate = std.extVar("estate"),
    local kingdom = std.extVar("kingdom"),
    local slbimages = import "slbimages.jsonnet",
    local configs = import "config.jsonnet",
    local set_value_to_all_in_list(value, list) = { [item]: value for item in list },
    local set_value_to_all_in_list_skip(value, list, skip) = { [item]: value for item in list if item != skip },

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
    testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage'],
    slbEstates: $.prodEstates + $.testEstates,
    samrole: "samapp.slb",
    maxDeleteDefault: 10,
    nginxProxyName: "slb-nginx-config-b",
    hsmNginxProxyName: "slb-hsm-nginx",

    slbEstate: (
        if $.isTestEstate then
            configs.estate
        else if configs.estate == "prd-samtwo" then
            "prd-slbtwo"
        else
            configs.kingdom + "-slb"
    ),

    slbEstateNodeSelector: {
        nodeSelector: {
            pool: $.slbEstate,
        },
    },

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
            "xrd-sam": "136.146.48.0/23,136.146.67.0/24",
            "cdg-sam": "85.222.142.0/23",
            "fra-sam": "85.222.140.0/23",
            "par-sam": "185.79.142.0/23",
            "ukb-sam": "161.71.146.0/23",
            "prd-samtwo": "136.146.214.0/23,96.43.157.0/24",
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

        trustedProxies: {
            "prd-sdc": "10.252.240.0/25,10.252.247.32/27",
            "prd-sam": "10.252.240.0/25,10.252.247.32/27",
            "prd-samdev": "10.252.240.0/25,10.252.247.32/27",
            "prd-samtest": "10.252.240.0/25,10.252.247.32/27",
            "prd-samtwo": "10.252.240.0/25,10.252.247.32/27",
            "prd-sam_storage": "10.252.240.0/25,10.252.247.32/27",
            "phx-sam": "10.220.4.2/32,10.220.4.10/32,10.220.4.18/32,10.220.4.26/32,10.220.4.34/32,10.220.4.42/32,10.220.4.50/32,10.220.4.58/32,10.220.4.66/32,10.220.4.74/32,10.220.4.82/32,10.220.4.90/32,10.220.4.100/32,10.220.4.106/32,10.220.4.114/32,10.220.4.122/32,10.220.4.130/32,10.220.4.138/32,10.220.4.146/32,10.220.4.154/32,10.220.4.162/32,10.220.4.170/32,10.220.4.178/32,10.220.4.186/32,10.220.4.194/32,10.220.4.202/32,10.220.4.210/32,10.220.4.218/32,10.220.4.226/32,10.220.4.234/32,10.220.4.242/32,10.220.4.250/32,10.220.5.2/32,10.220.5.10/32,10.220.5.18/32,10.220.5.26/32,10.220.5.34/32,10.220.5.42/32,10.220.54.2/32,10.220.54.10/32,10.220.54.18/32,10.220.54.26/32,10.220.54.34/32,10.220.54.42/32,10.220.54.50/32,10.220.54.58/32,10.220.54.66/32,10.220.54.74/32,10.220.54.82/32,10.220.54.90/32,10.220.54.100/32,10.220.54.106/32,10.220.54.114/32,10.220.54.122/32,10.220.54.130/32,10.220.54.138/32,10.220.54.146/32,10.220.54.154/32,10.220.54.162/32,10.220.54.170/32,10.220.54.178/32,10.220.54.186/32,10.220.54.194/32,10.220.54.202/32,10.220.54.210/32,10.220.54.218/32,10.220.54.226/32,10.220.54.234/32,10.220.54.242/32,10.220.54.250/32,10.220.55.2/32,10.220.55.10/32,10.220.55.18/32,10.220.55.26/32,10.220.55.34/32,10.220.55.42/32,10.246.97.2/32,10.246.97.10/32,10.246.98.130/32,10.246.98.138/32,10.246.99.226/32,10.246.99.234/32,10.246.101.130/32,10.246.101.138/32,10.246.102.130/32,10.246.102.138/32,10.246.103.226/32,10.246.103.234/32,10.246.105.130/32,10.246.105.138/32,10.246.106.130/32,10.246.106.138/32,10.246.107.226/32,10.246.107.234/32,10.246.203.134/32,10.246.203.142/32,10.246.204.198/32,10.246.204.206/32,10.246.206.5/32,10.246.206.14/32,10.246.207.67/32,10.246.207.74/32,10.246.216.130/32,10.246.216.138/32,10.246.217.197/32,10.246.217.203/32,10.246.219.5/32,10.246.219.14/32,10.246.220.66/32,10.246.220.78/32,10.246.221.134/32,10.246.221.142/32,10.246.222.197/32,10.246.222.203/32,10.246.224.5/32,10.246.224.14/32,10.246.226.70/32,10.246.226.78/32,10.246.228.133/32,10.246.228.139/32,10.246.229.198/32,10.246.229.204/32,10.246.238.130/32,10.246.238.138/32,10.246.239.197/32,10.246.239.203/32,10.246.241.134/32,10.246.241.138/32,10.246.242.134/32,10.246.242.142/32,10.246.246.2/32,10.246.246.10/32,10.246.247.66/32,10.246.247.74/32,10.246.249.130/32,10.246.249.138/32,10.246.250.194/32,10.246.250.202/32",
            "iad-sam": "0.0.0.0/0",
            "xrd-sam": "0.0.0.0/0",
            "dfw-sam": "10.220.132.2/32,10.220.132.10/32,10.220.132.18/32,10.220.132.26/32,10.220.132.34/32,10.220.132.42/32,10.220.132.50/32,10.220.132.58/32,10.220.132.66/32,10.220.132.74/32,10.220.132.82/32,10.220.132.90/32,10.220.132.100/32,10.220.132.106/32,10.220.132.114/32,10.220.132.122/32,10.220.132.130/32,10.220.132.138/32,10.220.132.146/32,10.220.132.154/32,10.220.132.162/32,10.220.132.170/32,10.220.132.178/32,10.220.132.186/32,10.220.132.194/32,10.220.132.202/32,10.220.132.210/32,10.220.132.218/32,10.220.132.226/32,10.220.132.234/32,10.220.132.242/32,10.220.132.250/32,10.220.158.2/32,10.220.158.10/32,10.220.158.18/32,10.220.158.26/32,10.220.158.34/32,10.220.158.42/32,10.220.158.50/32,10.220.158.58/32,10.220.158.66/32,10.220.158.74/32,10.220.158.82/32,10.220.158.90/32,10.220.158.100/32,10.220.158.106/32,10.220.158.114/32,10.220.158.122/32,10.220.158.130/32,10.220.158.138/32,10.220.158.146/32,10.220.158.154/32,10.220.158.162/32,10.220.158.170/32,10.220.158.178/32,10.220.158.186/32,10.220.158.194/32,10.220.158.202/32,10.220.158.210/32,10.220.158.218/32,10.220.158.226/32,10.220.158.234/32,10.220.158.242/32,10.220.158.250/32,10.220.159.2/32,10.220.159.10/32,10.220.159.18/32,10.220.159.26/32,10.220.159.34/32,10.220.159.42/32,10.220.164.194/32,10.220.164.202/32,10.247.97.2/32,10.247.97.10/32,10.247.98.130/32,10.247.98.138/32,10.247.99.130/32,10.247.99.138/32,10.247.101.130/32,10.247.101.138/32,10.247.102.130/32,10.247.102.138/32,10.247.103.226/32,10.247.103.234/32,10.247.105.130/32,10.247.105.138/32,10.247.106.130/32,10.247.106.138/32,10.247.120.2/32,10.247.120.10/32,10.247.120.66/32,10.247.120.74/32,10.247.122.34/32,10.247.122.42/32,10.247.203.134/32,10.247.203.142/32,10.247.204.196/32,10.247.204.206/32,10.247.206.4/32,10.247.206.14/32,10.247.207.68/32,10.247.207.78/32,10.247.216.134/32,10.247.216.139/32,10.247.217.196/32,10.247.217.206/32,10.247.219.2/32,10.247.219.12/32,10.247.220.67/32,10.247.220.78/32,10.247.221.133/32,10.247.221.139/32,10.247.226.67/32,10.247.226.76/32,10.247.228.134/32,10.247.228.142/32,10.247.229.198/32,10.247.229.203/32,10.247.238.131/32,10.247.238.139/32,10.247.239.198/32,10.247.239.202/32,10.247.241.134/32,10.247.241.139/32,10.247.242.134/32,10.247.242.142/32,10.247.246.2/32,10.247.246.12/32,10.247.247.68/32,10.247.247.77/32,10.247.249.130/32,10.247.249.138/32,10.247.250.194/32,10.247.250.202/32",
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

        ipvsReplicaCount:
            set_value_to_all_in_list(2, $.testEstates)
            + set_value_to_all_in_list(3, $.prodEstates)
            + {
                    "prd-sdc": 3,
                    "prd-samtest": 1,
                    "prd-samtwo": 2,
            },

        nginxConfigReplicaCount:
            set_value_to_all_in_list(2, $.testEstates)
            + set_value_to_all_in_list(3, $.prodEstates)
            + {
                "prd-sdc": 6,
                "prd-sam": 4,
                "prd-samtest": 1,
                "prd-samdev": 1,
            },

        maxDeleteCount: {
            "prd-sdc": $.maxDeleteDefault,
            "prd-samtest": $.maxDeleteDefault,
            "prd-samdev": $.maxDeleteDefault,
            "prd-sam_storage": $.maxDeleteDefault,
            "prd-sam_storagedev": $.maxDeleteDefault,
            "prd-sam": 50,
            "frf-sam": $.maxDeleteDefault,
            "phx-sam": $.maxDeleteDefault,
            "iad-sam": $.maxDeleteDefault,
            "ord-sam": $.maxDeleteDefault,
            "dfw-sam": $.maxDeleteDefault,
            "hnd-sam": $.maxDeleteDefault,
            "xrd-sam": 20,
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

    getNodeApiClientSocketSettings():: [
        "--client.socketDir=" + $.configDir,
        "--client.dialSocket=true",
    ],

    getNodeApiServerSocketSettings():: [
        "--listenOnSocket=true",
        "--readOnly=false",
    ],

    // Avoid using kubedns for all SLB pods.
    getDnsPolicy():: { dnsPolicy: "Default" },

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
    slbInKingdom: kingdom in { [k]: 1 for k in $.slbKingdoms },
    slbInProdKingdom: kingdom in { [k]: 1 for k in $.prodKingdoms },
    isTestEstate: estate in { [e]: 1 for e in $.testEstates },
    isProdEstate: estate in { [e]: 1 for e in $.prodEstates },
    isSlbEstate: estate in { [e]: 1 for e in $.slbEstates },
    nginxConfigReplicaCount: self.perCluster.nginxConfigReplicaCount[estate],
    ipvsReplicaCount: self.perCluster.ipvsReplicaCount[estate],

    sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
    sdn_watchdog_emailrec: "slb@salesforce.com",

    customerCertsPath: "/customerCerts",
}
