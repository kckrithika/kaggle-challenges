{
local estate = std.extVar("estate"),

slbDir: "/host/var/slb",
configDir: self.slbDir+"/config",
logsDir: self.slbDir+"/logs",
ipvsMarkerFile: self.slbDir+"/ipvs.marker",
slbPortalTemplatePath: "/sdn/webfiles",

perCluster: {
    ddiService: {
        "prd-sdc": "https://ddi-api-prd.data.sfdc.net",
        "prd-samtest": "https://ddi-api-prd.data.sfdc.net",
        "prd-samdev": "https://ddi-api-prd.data.sfdc.net",
        "prd-sam": "https://ddi-api-prd.data.sfdc.net",
        "prd-sam_storage": "https://ddi-api-prd.data.sfdc.net"
    },

    subnet: {
            "prd-sdc": "10.251.129.224-234",
            "prd-samtest": "10.251.129.235-240",
            "prd-samdev": "10.251.129.241-245",
            "prd-sam_storage": "10.251.129.246-255",
            "prd-sam": "10.251.167.224/27"
    },

    serviceList: {
        "prd-sdc": "",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
        "prd-sam": "csrlb,controlplane-ptest"
    },

    namespace: {
        "prd-sdc": "",
        "prd-samtest": "sam-system",
        "prd-samdev": "sam-system",
        "prd-sam_storage": "",
        "prd-sam": ""
    },

    useProxyServicesList: {
        "prd-sdc": "slb-bravo-svc",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam_storage": "",
        "prd-sam": "slb-bravo-svc,csrlb,controlplane-ptest"
    },

    canaryServiceName: {
        "prd-sdc": "slb-sdc-svc",
        "prd-samtest": "slb-samtest-svc",
        "prd-samdev": "slb-samdev-svc",
        "prd-sam_storage": "slb-sam-storage-svc",
        "prd-sam": "slb-sam-svc"
    },

    useVipLabelToSelectSvcs: {
        "prd-sdc": true,
        "prd-samtest": true,
        "prd-samdev": true,
        "prd-sam_storage": true,
        "prd-sam": true
    },
},


# Frequently used volume: slb
    slb_volume: {
        name: "var-slb-volume",
        hostPath: {
            "path": "/var/slb"
        }
    },
    slb_volume_mount: {
        "name": "var-slb-volume",
        "mountPath": "/host/var/slb"
    },

# Frequently used volume: slb-config
    slb_config_volume: {
        name: "var-config-volume",
        hostPath: {
            "path": "/var/slb/config"
        }
    },
    slb_config_volume_mount: {
        "name": "var-config-volume",
        "mountPath": "/host/var/slb/config"
    },

# Frequently used volume: host
    host_volume: {
        name: "host-volume",
        hostPath: {
            "path": "/"
        }
    },
    host_volume_mount: {
        "name": "host-volume",
        "mountPath": "/host"
    },

# Frequently used volume: logs
    logs_volume: {
        name: "var-logs-volume",
        hostPath: {
            "path": "/var/slb/logs"
        }
    },
    logs_volume_mount: {
        "name": "var-logs-volume",
        "mountPath": "/host/var/slb/logs"
    },

subnet: self.perCluster.subnet[estate],
serviceList: self.perCluster.serviceList[estate],
namespace: self.perCluster.namespace[estate],
ddiService: self.perCluster.ddiService[estate],
canaryServiceName: self.perCluster.canaryServiceName[estate],
useProxyServicesList: self.perCluster.useProxyServicesList[estate],
useVipLabelToSelectSvcs: self.perCluster.useVipLabelToSelectSvcs[estate],

sdn_watchdog_emailsender: "sam-alerts@salesforce.com",
sdn_watchdog_emailrec: "slb@salesforce.com",


}
