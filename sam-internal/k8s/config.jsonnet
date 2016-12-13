{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local images = import "images.jsonnet",

    perKingdom: {
        funnelVIP: {
            "prd": "mandm-funnel-sfz.data.sfdc.net:8080",
            "dfw": "mandm-funnel-dfw1.data.sfdc.net:8080",
            "phx": "mandm-funnel-phx1.data.sfdc.net:8080"
        },

        tnrpArchiveEndpoint: {
            "prd": "https://ops0-piperepo1-1-prd.eng.sfdc.net/tnrp/content_repo/0/archive",
            "dfw": "https://ops0-piperepo1-1-dfw.ops.sfdc.net/tnrp/content_repo/0/archive",
            "phx": "https://ops0-piperepo1-1-phx.ops.sfdc.net/tnrp/content_repo/0/archive",
        },

        rcImtEndpoint: {
            "prd": "http://ops0-orch1-1-prd.eng.sfdc.net:8080/v1/bark",
            "dfw": "http://ops0-orch1-1-dfw.ops.sfdc.net:8080/v1/bark",
            "phx": "http://ops0-orch1-1-phx.ops.sfdc.net:8080/v1/bark"
        },

        smtpServer: {
            "prd": "rd1-mta1-4-sfm.ops.sfdc.net:25",
            "dfw": "ops0-mta2-2-dfw.ops.sfdc.net:25",
            "phx": "ops0-mta1-2-phx.ops.sfdc.net"
        },

    },

    perCluster: {
        registry: {
            "prd-sam": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000",
            "prd-samtemp": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000",
            "prd-samdev": "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000",
            "prd-sdc": "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000",
            "dfw-sam": "shared0-samkubeapi1-1-dfw.ops.sfdc.net:5000",
            "phx-sam": "shared0-samkubeapi1-1-phx.ops.sfdc.net:5000"
        },

        tlsEnabled: {
            "prd-sam": "false",
            "prd-samtemp": "false",
            "prd-samdev": "true",
            "prd-sdc": "false",
            "dfw-sam": "false",
            "phx-sam": "true"
        },

        caFile: {
            "prd-sam": "",
            "prd-samtemp": "",
            "prd-samdev": "/data/certs/ca.crt",
            "prd-sdc": "",
            "dfw-sam": "",
            "phx-sam": "/data/certs/ca.crt"
        },

        keyFile: {
            "prd-sam": "",
            "prd-samtemp": "",
            "prd-samdev": "/data/certs/hostcert.key",
            "prd-sdc": "",
            "dfw-sam": "",
            "phx-sam": "/data/certs/hostcert.key"
          },

        certFile: {
            "prd-sam": "",
            "prd-samtemp": "",
            "prd-samdev": "/data/certs/hostcert.crt",
            "prd-sdc": "",
            "dfw-sam": "",
            "phx-sam": "/data/certs/hostcert.crt"
         },

        k8sapiserver: {
            "prd-sam": "http://localhost:8000",
            "prd-samtemp": "http://localhost:8000",
            "prd-samdev": "",
            "prd-sdc": "http://localhost:8000",
            "dfw-sam": "http://localhost:8000",
            "phx-sam": ""
        }

    },

    funnelVIP: self.perKingdom.funnelVIP[kingdom],
    tnrpArchiveEndpoint: self.perKingdom.tnrpArchiveEndpoint[kingdom],
    rcImtEndpoint: self.perKingdom.rcImtEndpoint[kingdom],
    smtpServer: self.perKingdom.smtpServer[kingdom],
    registry: self.perCluster.registry[estate],
    tlsEnabled: self.perCluster.tlsEnabled[estate],
    caFile: self.perCluster.caFile[estate],
    keyFile: self.perCluster.keyFile[estate],
    certFile: self.perCluster.certFile[estate],
    k8sapiserver: self.perCluster.k8sapiserver[estate],
    estate: estate,

    controller: images.controller,
    watchdog_common: images.watchdog_common,
    watchdog_master: images.watchdog_master,
    watchdog_etcd: images.watchdog_etcd,
    manifest_watcher: images.manifest_watcher,
}
