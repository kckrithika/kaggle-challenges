{
local estate = std.extVar("estate"),

slbDir: "/host/data/slb",
slbDockerDir: "/data/slb",
configDir: self.slbDir + "/config",
logsDir: self.slbDir + "/logs",
ipvsMarkerFile: self.slbDir + "/ipvs.marker",
slbPortalTemplatePath: "/sdn/webfiles",

perCluster: {
    ddiService: {
        "prd-sdc": "https://ddi-api-prd.data.sfdc.net",
        "prd-samtest": "https://ddi-api-prd.data.sfdc.net",
        "prd-samdev": "https://ddi-api-prd.data.sfdc.net",
        "prd-sam": "https://ddi-api-prd.data.sfdc.net",
        "prd-sam_storage": "https://ddi-api-prd.data.sfdc.net",
    },

    subnet: {
            "prd-sdc": "10.251.129.224-240",
            "prd-samtest": "10.251.129.241-242",
            "prd-samdev": "10.251.129.243-245",
            "prd-sam_storage": "10.251.129.246-254",
            "prd-sam": "10.251.196.0/22",
    },

    serviceList: {
        "prd-sdc": "",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
        "prd-sam": "csrlb,controlplane-ptest",
    },

    namespace: {
        "prd-sdc": "",
        "prd-samtest": "",
        "prd-samdev": "sam-system",
        "prd-sam_storage": "",
        "prd-sam": "",
    },

    useProxyServicesList: {
        "prd-sdc": "slb-bravo-svc",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
        "prd-sam": "slb-bravo-svc,csrlb,controlplane-ptest",
    },

    podLabelList: {
        "prd-sdc": "name=slb-ipvs, name=slb-portal, name=slb-realsvrcfg, name=slb-dns-register, name=slb-node-os-stats, name=slb-vip-watchdog, name=slb-nginx-config, name=slb-ipvsdata-watchdog, name=slb-iface-processor, name=slb-echo-client, name=slb-echo-server, name=slb-config-processor, name=slb-cleanup, name=slb-canary-proxy-tcp, name=slb-canary-proxy-http, name=slb-canary-passthrough-tls, name=slb-canary-passthrough-host-network, name=slb-canary, name=slb-bravo, name=slb-alpha",
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
        "prd-sam": true,
    },
    kneDomainName: {
        "prd-sdc": "prd-sdc.slb.sfdc.net",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
        "prd-sam": "slb.sfdc.net",
    },
    processKnEConfigs: {
        "prd-sdc": true,
        "prd-samtest": false,
        "prd-samdev": false,
        "prd-sam_storage": false,
        "prd-sam": true,

    },
    kneConfigDir: {
        "prd-sdc": "/var/slb/testkneconfigs",
        "prd-samtest": "/var/slb/testkneconfigs",
        "prd-samdev": "/var/slb/testkneconfigs",
        "prd-sam_storage": "/var/slb/testkneconfigs",
        "prd-sam": "/var/slb/kneconfig",
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

subnet: self.perCluster.subnet[estate],
serviceList: self.perCluster.serviceList[estate],
namespace: self.perCluster.namespace[estate],
ddiService: self.perCluster.ddiService[estate],
canaryServiceName: self.perCluster.canaryServiceName[estate],
useProxyServicesList: self.perCluster.useProxyServicesList[estate],
podLabelList: self.perCluster.podLabelList[estate],
useVipLabelToSelectSvcs: self.perCluster.useVipLabelToSelectSvcs[estate],
kneDomainName: self.perCluster.kneDomainName[estate],
processKnEConfigs: self.perCluster.processKnEConfigs[estate],
kneConfigDir: self.perCluster.kneConfigDir[estate],

sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
sdn_watchdog_emailrec: "slb@salesforce.com",


}
