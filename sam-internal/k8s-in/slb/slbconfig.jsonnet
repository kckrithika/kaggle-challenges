{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),

slbDir: "/host/data/slb",
slbDockerDir: "/data/slb",
configDir: self.slbDir + "/config",
logsDir: self.slbDir + "/logs",
ipvsMarkerFile: self.slbDir + "/ipvs.marker",
slbPortalTemplatePath: "/sdn/webfiles",
prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd'],

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
            "prd-sam": "10.251.196.0-255,10.251.197.0-255,10.251.198.0-255,10.251.199.0-239",
            "frf-sam": "10.214.36.0/22",
            "phx-sam": "10.208.208.0/22",
            "iad-sam": "10.208.108.0/22",
            "ord-sam": "10.208.148.0/22",
            "dfw-sam": "10.214.188.0/22",
            "hnd-sam": "10.213.100.0/22",
            # prd-sam-a : 10.251.199.248-255
    },

    serviceList: {
        "prd-sdc": "",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
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
    } + {
        [k + "-sam"]: ""
            for k in $.prodKingdoms + ["prd"]
    },

    useProxyServicesList: {
        "prd-sdc": "slb-bravo-svc",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
        "prd-sam": "slb-bravo-svc,csrlb,controlplane-ptest,cyanlb,controlplane-ptest-lb",
    } + {
        [k + "-sam"]: ""
            for k in $.prodKingdoms
    },

    podLabelList: {
        "prd-sdc": "name=slb-ipvs, name=slb-portal, name=slb-realsvrcfg, name=slb-dns-register, name=slb-node-os-stats, name=slb-vip-watchdog, name=slb-nginx-config, name=slb-ipvsdata-watchdog, name=slb-iface-processor, name=slb-echo-client, name=slb-echo-server, name=slb-config-processor, name=slb-cleanup, name=slb-canary-proxy-tcp, name=slb-canary-proxy-http, name=slb-canary-passthrough-tls, name=slb-canary-passthrough-host-network, name=slb-canary, name=slb-bravo, name=slb-alpha",
        "prd-sam": "name=slb-vip-watchdog",
    },

    canaryServiceName: {
        "prd-sdc": "slb-sdc-svc",
        "prd-samtest": "slb-samtest-svc",
        "prd-samdev": "slb-samdev-svc",
        "prd-sam_storage": "slb-sam-storage-svc",
        "prd-sam": "slb-sam-svc",
    },
    useVipLabelToSelectSvcs: {
        "prd-sdc": true,
        "prd-samtest": true,
        "prd-samdev": true,
        "prd-sam_storage": true,
    } + {
        [k + "-sam"]: true
            for k in $.prodKingdoms + ["prd"]
    },
    kneDomainName: {
        "prd-sdc": "prd-sdc.slb.sfdc.net",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
    } + {
        [k + "-sam"]: "slb.sfdc.net"
            for k in $.prodKingdoms + ["prd"]
    },
    processKnEConfigs: {
        "prd-sdc": true,
        "prd-samtest": false,
        "prd-samdev": false,
        "prd-sam_storage": false,
        "prd-sam": true,
    } + {
        [k + "-sam"]: false
            for k in $.prodKingdoms
    },

    kneConfigDir: {
        "prd-sdc": "/var/slb/kneconfigs/testkneconfigs",
        "prd-samtest": "/var/slb/kneconfigs/testkneconfigs",
        "prd-samdev": "/var/slb/kneconfigs/testkneconfigs",
        "prd-sam_storage": "/var/slb/kneconfigs/testkneconfigs",
    } + {
        [k + "-sam"]: "/var/slb/kneconfig"
            for k in $.prodKingdoms + ["prd"]
    } + {  # this final block is temporary while phased shifting to a per-site kneConfigDir.
        [k + "-sam"]: "/var/slb/kneconfig/" + k
            for k in ["prd"]
    },
    canaryMaxParallelism: {
        "prd-sdc": 1,
        "prd-samtest": 1,
        "prd-samdev": 1,
        "prd-sam_storage": 1,
        "prd-sam": 2,
    },
    madkubServer: {
        [k]: "https://all.pkicontroller.pki.blank." + k + ".prod.non-estates.sfdcsd.net:8443"
            for k in $.prodKingdoms + ["prd"]
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
            path: "/data/slb/config",
        },
    },
    slb_config_volume_mount: {
        name: "var-config-volume",
        mountPath: "/host/data/slb/config",
    },

# Frequently used volume: logs
    logs_volume: {
        name: "var-logs-volume",
        hostPath: {
            path: "/data/slb/logs",
        },
    },
    logs_volume_mount: {
        name: "var-logs-volume",
        mountPath: "/host/data/slb/logs",
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

subnet: self.perCluster.subnet[estate],
serviceList: self.perCluster.serviceList[estate],
namespace: self.perCluster.namespace[estate],
ddiService: self.perCluster.ddiService[kingdom],
canaryServiceName: self.perCluster.canaryServiceName[estate],
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
madkubServer: self.perCluster.madkubServer[kingdom],
slbInKingdom: kingdom in { [k]: 1 for k in $.prodKingdoms + ["prd"] },
slbInProdKingdom: kingdom in { [k]: 1 for k in $.prodKingdoms },

sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
sdn_watchdog_emailrec: "slb@salesforce.com",


}
