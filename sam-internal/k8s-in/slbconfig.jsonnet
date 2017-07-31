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

    vipList: {
        "prd-sdc": "10.251.129.224:9090,10.251.129.225:9090,10.251.129.226:9090,10.251.129.227:0,10.251.129.228:0",
        "prd-samtest": "10.251.129.235:9090,10.251.129.236:0,10.251.129.237:0",
        "prd-samdev": "10.251.129.246:9090,10.251.129.247:0,10.251.129.248:0",
        "prd-sam": "10.251.167.224:0,10.251.167.225:0,10.251.167.226:0"
    },

    serviceList: {
        "prd-sdc": "slb-alpha,slb-bravo,slb-charlie,sam-deployment-portal,k8sproxy",
        "prd-samtest": "slb-delta,sam-deployment-portal,k8sproxy",
        "prd-samdev": "slb-echo,sam-deployment-portal,k8sproxy",
        "prd-sam": "slb-foxtrot,sam-deployment-portal,k8sproxy"
    },

    canaryServiceName: {
        "prd-sdc": "slb-sdc-svc",
        "prd-samtest": "slb-samtest-svc",
        "prd-samdev": "slb-samdev-svc",
        "prd-sam": "slb-sam-svc"
    },

    canaryServicePort: {
        "prd-sdc": 9111,
        "prd-samtest": 9112,
        "prd-samdev": 9113,
        "prd-sam": 9114
    },

    ipvsDataConnPort: {
        "prd-sdc": 9107,
        "prd-samtest": 9108,
        "prd-samdev": 9109,
        "prd-sam": 9110
    },
},

subnet: self.perCluster.subnet[estate],
vipList: self.perCluster.vipList[estate],
serviceList: self.perCluster.serviceList[estate],
ddiService: self.perCluster.ddiService[estate],
canaryServiceName: self.perCluster.canaryServiceName[estate],
canaryServicePort: self.perCluster.canaryServicePort[estate],
ipvsDataConnPort: self.perCluster.ipvsDataConnPort[estate],

}
