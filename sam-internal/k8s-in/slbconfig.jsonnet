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
        "prd-sam": ""
    },

    vipList: {
        "prd-sdc": "10.251.129.230:9090,10.251.129.231:9090,10.251.129.232:9090",
        "prd-samtest": "10.251.129.233:9090",
        "prd-samdev": "10.251.129.234:9090",
        "prd-sam": "10.251.129.235:0"
    },

    serviceList: {
        "prd-sdc": "slb-alpha,slb-bravo,slb-charlie",
        "prd-samtest": "slb-delta",
        "prd-samdev": "slb-echo",
        "prd-sam": "sam-deployment-portal"
    },
},

vipList: self.perCluster.vipList[estate],
serviceList: self.perCluster.serviceList[estate],
ddiService: self.perCluster.ddiService[estate],

}
