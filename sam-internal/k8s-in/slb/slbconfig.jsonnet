{
local estate = std.extVar("estate"),

slbDir: self.perCluster.slbDir[estate],
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
        "prd-samtest": "sam-system",
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
        "prd-sam": false,

    },
    kneConfigDir: {
        "prd-sdc": "/var/slb/testkneconfigs",
        "prd-samtest": "/var/slb/testkneconfigs",
        "prd-samdev": "/var/slb/testkneconfigs",
        "prd-sam_storage": "/var/slb/testkneconfigs",
        "prd-sam": "/var/slb/kneconfig",
    },

    # we should move config below out of per estate section once we have shipped to phase-II
    slbDir: {
        "prd-sdc": "/host/data/slb",
        "prd-samtest": "/host/var/slb",
        "prd-samdev": "/host/var/slb",
        "prd-sam": "/host/var/slb",
        "prd-sam_storage": "/host/var/slb",
    },

    slb_volume: {
        "prd-sdc": {
            name: "var-slb-volume",
            hostPath: {
                path: "/data/slb",
            },
        },
        "prd-sam": {
            name: "var-slb-volume",
            hostPath: {
                path: "/var/slb",
            },
        },
        "prd-sam_storage": {
            name: "var-slb-volume",
            hostPath: {
                path: "/var/slb",
            },
        },
    },
    slb_volume_mount: {
        "prd-sdc": {
            name: "var-slb-volume",
            mountPath: "/host/data/slb",
        },
        "prd-sam": {
            name: "var-slb-volume",
            mountPath: "/host/var/slb",
        },
        "prd-sam_storage": {
            name: "var-slb-volume",
            mountPath: "/host/var/slb",
        },
    },
    slb_config_volume: {
        "prd-sdc": {
            name: "var-config-volume",
            hostPath: {
                path: "/data/slb/config",
            },
        },
        "prd-sam": {
            name: "var-config-volume",
            hostPath: {
                path: "/var/slb/config",
            },
        },
        "prd-sam_storage": {
            name: "var-config-volume",
            hostPath: {
                path: "/var/slb/config",
            },
        },
    },
    slb_config_volume_mount: {
        "prd-sdc": {
             name: "var-config-volume",
             mountPath: "/host/data/slb/config",
        },
        "prd-sam": {
             name: "var-config-volume",
             mountPath: "/host/var/slb/config",
        },
        "prd-sam_storage": {
             name: "var-config-volume",
             mountPath: "/host/var/slb/config",
        },
    },
    logs_volume: {
        "prd-sdc": {
            name: "var-logs-volume",
            hostPath: {
                path: "/data/slb/logs",
            },
        },
        "prd-sam": {
            name: "var-logs-volume",
            hostPath: {
                path: "/var/slb/logs",
            },
        },
        "prd-sam_storage": {
            name: "var-logs-volume",
            hostPath: {
                path: "/var/slb/logs",
            },
        },
    },
    logs_volume_mount: {
        "prd-sdc": {
             name: "var-logs-volume",
             mountPath: "/host/data/slb/logs",
        },
        "prd-sam": {
             name: "var-logs-volume",
             mountPath: "/host/var/slb/logs",
        },
        "prd-sam_storage": {
             name: "var-logs-volume",
             mountPath: "/host/var/slb/logs",
        },
    },
},


# Frequently used volume: slb
    slb_volume: self.perCluster.slb_volume[estate],
    slb_volume_mount: self.perCluster.slb_volume_mount[estate],

# Frequently used volume: slb-config
    slb_config_volume: self.perCluster.slb_config_volume[estate],
    slb_config_volume_mount: self.perCluster.slb_config_volume_mount[estate],

# Frequently used volume: host
    host_volume: {
        name: "host-volume",
        hostPath: {
            path: "/",
        },
    },
    host_volume_mount: {
        name: "host-volume",
        mountPath: "/host",
    },

# Frequently used volume: logs
    logs_volume: self.perCluster.logs_volume[estate],
    logs_volume_mount: self.perCluster.logs_volume_mount[estate],

subnet: self.perCluster.subnet[estate],
serviceList: self.perCluster.serviceList[estate],
namespace: self.perCluster.namespace[estate],
ddiService: self.perCluster.ddiService[estate],
canaryServiceName: self.perCluster.canaryServiceName[estate],
useProxyServicesList: self.perCluster.useProxyServicesList[estate],
useVipLabelToSelectSvcs: self.perCluster.useVipLabelToSelectSvcs[estate],
kneDomainName: self.perCluster.kneDomainName[estate],
processKnEConfigs: self.perCluster.processKnEConfigs[estate],
kneConfigDir: self.perCluster.kneConfigDir[estate],

sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
sdn_watchdog_emailrec: "slb@salesforce.com",


}
