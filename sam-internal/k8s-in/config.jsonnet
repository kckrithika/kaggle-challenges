{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local images = import "images.jsonnet",

    perKingdom: {
        funnelVIP: {
            "prd": "ajna0-funnel1-0-prd.data.sfdc.net:80",
            "dfw": "mandm-funnel-dfw1.data.sfdc.net:8080",
            "phx": "mandm-funnel-phx1.data.sfdc.net:8080",
            "frf": "mandm-funnel-frf1.data.sfdc.net:8080",
            "par": "mandm-funnel-par1.data.sfdc.net:8080"
        },

        tnrpArchiveEndpoint: {
            "prd": "https://ops0-piperepo1-1-prd.eng.sfdc.net/tnrp/content_repo/0/archive",
            "dfw": "https://ops0-piperepo1-1-dfw.ops.sfdc.net/tnrp/content_repo/0/archive",
            "phx": "https://ops0-piperepo1-1-phx.ops.sfdc.net/tnrp/content_repo/0/archive",
            "frf": "https://ops0-piperepo1-1-frf.ops.sfdc.net/tnrp/content_repo/0/archive",
            "par": "https://ops0-piperepo1-1-par.ops.sfdc.net/tnrp/content_repo/0/archive"
        },

        rcImtEndpoint: {
            "prd": "http://ops0-orch1-1-prd.eng.sfdc.net:8080/v1/bark",
            "dfw": "http://ops0-orch1-1-dfw.ops.sfdc.net:8080/v1/bark",
            "phx": "http://ops0-orch1-1-phx.ops.sfdc.net:8080/v1/bark",
            "frf": "http://ops0-orch1-1-frf.ops.sfdc.net:8080/v1/bark",
            "par": "http://ops0-orch1-1-par.ops.sfdc.net:8080/v1/bark"
        },

        smtpServer: {
            "prd": "rd1-mta1-4-sfm.ops.sfdc.net:25",
            "dfw": "ops0-mta2-2-dfw.ops.sfdc.net:25",
            "phx": "ops0-mta1-2-phx.ops.sfdc.net:25",
            "frf": "ops0-mta2-1-frf.ops.sfdc.net:25",
            "par": "ops0-mta2-1-par.ops.sfdc.net:25"
        },

    },

    perCluster: {
        registry: {
            "prd-sam": "ops0-artifactrepo2-0-prd.data.sfdc.net",
            "prd-samdev": "ops0-artifactrepo2-0-prd.data.sfdc.net",
            "prd-sdc": "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000",
            "dfw-sam": "ops0-artifactrepo1-0-dfw.data.sfdc.net",
            "phx-sam": "ops0-artifactrepo1-0-phx.data.sfdc.net",
            "frf-sam": "ops0-artifactrepo1-0-frf.data.sfdc.net",
            "par-sam": "ops0-artifactrepo1-0-par.data.sfdc.net"
        },

        tlsEnabled: {
            "prd-sam": "true",
            "prd-samdev": "true",
            "prd-sdc": "false",
            "dfw-sam": "true",
            "phx-sam": "true",
            "frf-sam": "true",
            "par-sam": "true"
        }

    },

    securityEnabled: {
        caFile: {
            "true": "/data/certs/ca.crt",
            "false": ""
        },

        keyFile: {
            "true": "/data/certs/hostcert.key",
            "false": ""
        },

        certFile: {
            "true": "/data/certs/hostcert.crt",
            "false": ""
        },

        k8sapiserver: {
            "true": "",
            "false": "http://localhost:8000"
        },

        configPath: {
            "true": "/config/kubeconfig",
            "false": "/sam/config"
        }

    },

    funnelVIP: self.perKingdom.funnelVIP[kingdom],
    tnrpArchiveEndpoint: self.perKingdom.tnrpArchiveEndpoint[kingdom],
    rcImtEndpoint: self.perKingdom.rcImtEndpoint[kingdom],
    smtpServer: self.perKingdom.smtpServer[kingdom],
    registry: self.perCluster.registry[estate],
    tlsEnabled: self.perCluster.tlsEnabled[estate],

    caFile: self.securityEnabled.caFile[self.perCluster.tlsEnabled[estate]],
    keyFile: self.securityEnabled.keyFile[self.perCluster.tlsEnabled[estate]],
    certFile: self.securityEnabled.certFile[self.perCluster.tlsEnabled[estate]],
    k8sapiserver: self.securityEnabled.k8sapiserver[self.perCluster.tlsEnabled[estate]],
    configPath: self.securityEnabled.configPath[self.perCluster.tlsEnabled[estate]],
    estate: estate,

    controller: images.controller,
    watchdog_common: images.watchdog_common,
    watchdog_master: images.watchdog_master,
    watchdog_etcd: images.watchdog_etcd,
    manifest_watcher: images.manifest_watcher,
    k8sproxy: images.k8sproxy,
    sam_deployment_portal: images.sam_deployment_portal,
    
    sdc_bird: images.sdc_bird,
    sdc_peering_agent: images.sdc_peering_agent,
}
