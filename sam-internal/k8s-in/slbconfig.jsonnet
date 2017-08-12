{
local estate = std.extVar("estate"),

slbDir: "/host/var/slb",
configDir: self.slbDir+"/config",
ipvsMarkerFile: self.slbDir+"/ipvs.marker",

perCluster: {
    ddiService: {
        "prd-sdc": "https://ddi-api-prd.data.sfdc.net",
        "prd-samtest": "https://ddi-api-prd.data.sfdc.net",
        "prd-samdev": "https://ddi-api-prd.data.sfdc.net",
        "prd-sam": "https://ddi-api-prd.data.sfdc.net"
    },

    subnet: {
            "prd-sdc": "10.251.129.224-234",
            "prd-samtest": "10.251.129.235-245",
            "prd-samdev": "10.251.129.246-255",
            "prd-sam": "10.251.167.224/27"
    },

    serviceList: {
        "prd-sdc": "",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam": ""
    },

    useProxyServicesList: {
        "prd-sdc": "slb-bravo-svc",
        "prd-samtest": "",
        "prd-samdev": "",
        "prd-sam": ""
    },

    canaryServiceName: {
        "prd-sdc": "slb-sdc-svc",
        "prd-samtest": "slb-samtest-svc",
        "prd-samdev": "slb-samdev-svc",
        "prd-sam": "slb-sam-svc"
    },

    useVipLabelToSelectSvcs: {
        "prd-sdc": false,
        "prd-samtest": true,
        "prd-samdev": true,
        "prd-sam": true
    },
},

subnet: self.perCluster.subnet[estate],
serviceList: self.perCluster.serviceList[estate],
ddiService: self.perCluster.ddiService[estate],
canaryServiceName: self.perCluster.canaryServiceName[estate],
useProxyServicesList: self.perCluster.useProxyServicesList[estate],
useVipLabelToSelectSvcs: self.perCluster.useVipLabelToSelectSvcs[estate],

}
