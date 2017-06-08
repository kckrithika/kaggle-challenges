{
local estate = std.extVar("estate"),

slbDir: "/host/var/slb",
configDir: self.slbDir+"/config",
ipvsMarkerFile: self.slbDir+"/ipvs.marker",

perCluster: {
    vipList: {
        "prd-sdc": "10.251.129.230:9090,10.251.129.231:9090,10.251.129.232:9090",
        "prd-samtest": "10.251.129.233:9090",
        "prd-samdev": "10.251.129.234:9090",
        "prd-sam": ""
    },

    serviceList: {
        "prd-sdc": "slb-alpha,slb-bravo,slb-charlie",
        "prd-samtest": "slb-delta",
        "prd-samdev": "slb-echo",
        "prd-sam": ""
    },
},

vipList: self.perCluster.vipList[estate],
serviceList: self.perCluster.serviceList[estate],

}
