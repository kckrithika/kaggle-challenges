{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local images = import "images.jsonnet",

    perKingdom: {
        funnelVIP: {
            "prd": "mandm-funnel-sfz.data.sfdc.net",
            "dfw": "mandm-funnel-dfw1.data.sfdc.net:8080",
        },

        tnrpArchiveEndpoint: {
            "prd": "https://ops0-piperepo1-1-prd.eng.sfdc.net/tnrp/content_repo/0/archive",
            "dfw": "https://ops0-piperepo1-1-dfw.ops.sfdc.net/tnrp/content_repo/0/archive",
        },

        rcImtEndpoint: {
            "prd": "http://ops0-orch1-1-prd.eng.sfdc.net:8080/v1/bark",
            "dfw": "http://ops0-orch1-1-dfw.ops.sfdc.net:8080/v1/bark",
        },

        smtpServer: {
            "prd": "rd1-mta1-4-sfm.ops.sfdc.net:25",
            "dfw": "ops0-mta2-2-dfw.ops.sfdc.net:25",
        },
    },

    perCluster: {
        registry: {
            "prd-sam": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000",
            "prd-samtemp": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000",
            "prd-samdev": "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000",
            "dfw-sam": "shared0-samkubeapi1-1-dfw.ops.sfdc.net:5000",
        },
    },

    funnelVIP: self.perKingdom.funnelVIP[kingdom],
    tnrpArchiveEndpoint: self.perKingdom.tnrpArchiveEndpoint[kingdom],
    rcImtEndpoint: self.perKingdom.rcImtEndpoint[kingdom],
    smtpServer: self.perKingdom.smtpServer[kingdom],
    registry: self.perCluster.registry[estate],
    estate: estate,

    controller: images.controller,
    watchdog_common: images.watchdog_common,
    watchdog_master: images.watchdog_master,
    watchdog_etcd: images.watchdog_etcd,
    manifest_watcher: images.manifest_watcher,
}
