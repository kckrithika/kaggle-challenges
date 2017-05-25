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
            "prd": "https://ops0-health1-1-prd.eng.sfdc.net:18443/v1/bark",
            "dfw": "http://shared0-samminionreportcollector1-1-dfw.ops.sfdc.net:18443/v1/bark",
            "phx": "https://ops0-health1-1-phx.ops.sfdc.net:18443/v1/bark",
            "frf": "https://ops0-health1-1-frf.ops.sfdc.net:18443/v1/bark",
            "par": "https://ops0-health1-1-par.ops.sfdc.net:18443/v1/bark"
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
        apiserver: {
                "prd-sdc": "http://shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:40000/"
        },

        matricEndpoint:{
                "prd-sdc":"ajna0-funnel1-0-prd.data.sfdc.net"
        },

        registry: {
            "prd-sam": "ops0-artifactrepo2-0-prd.data.sfdc.net",
            "prd-samdev": "ops0-artifactrepo2-0-prd.data.sfdc.net",
            "prd-samtest": "ops0-artifactrepo2-0-prd.data.sfdc.net",
            "prd-sdc": "ops0-artifactrepo2-0-prd.data.sfdc.net",
            "dfw-sam": "ops0-artifactrepo1-0-dfw.data.sfdc.net",
            "phx-sam": "ops0-artifactrepo1-0-phx.data.sfdc.net",
            "frf-sam": "ops0-artifactrepo1-0-frf.data.sfdc.net",
            "par-sam": "ops0-artifactrepo1-0-par.data.sfdc.net"
        },

        insecureRegistries: {
            "prd-sam": "shared0-samcontrol1-1-prd.eng.sfdc.net:5000/",
            "prd-samdev": "shared0-samdevkubeapi1-1-prd.eng.sfdc.net:5000/",
            "prd-samtest": "shared0-samtestkubeapi1-1-prd.eng.sfdc.net:5000/",
            "prd-sdc": "shared0-sdcsamkubeapi1-1-prd.eng.sfdc.net:5000/",
            "dfw-sam": "",
            "phx-sam": "",
            "frf-sam": "",
            "par-sam": ""
        },

        checkImageExistsFlag: {
            "prd-sam": "true",
            "prd-samdev": "true",
            "prd-samtest": "true",
            "prd-sdc": "true",
            "dfw-sam": "true",
            "phx-sam": "true",
            "frf-sam": "true",
            "par-sam": "true"
        },

        httpsDisableCertsCheck: {
            "prd-sam": "true",
            "prd-samdev": "true",
            "prd-samtest": "true",
            "prd-sdc": "true",
            "dfw-sam": "true",
            "phx-sam": "true",
            "frf-sam": "true",
            "par-sam": "true"
        },
    },

    # Global

    caFile: "/data/certs/ca.crt",
    keyFile: "/data/certs/hostcert.key",
    certFile: "/data/certs/hostcert.crt",
    k8sapiserver: "",
    configPath: "/config/kubeconfig",

    watchdog_emailsender: "sam@salesforce.com",
    watchdog_emailrec: (if estate == "prd-sdc" then "sdn@salesforce.com" else "sam@salesforce.com"),

    # Pass-through below here only

    funnelVIP: self.perKingdom.funnelVIP[kingdom],
    tnrpArchiveEndpoint: self.perKingdom.tnrpArchiveEndpoint[kingdom],
    rcImtEndpoint: self.perKingdom.rcImtEndpoint[kingdom],
    smtpServer: self.perKingdom.smtpServer[kingdom],
    apiserver: self.perCluster.apiserver[estate],
    matricEndpoint: self.perCluster.matricEndpoint[estate],
    registry: self.perCluster.registry[estate],
    insecureRegistries: self.perCluster.insecureRegistries[estate],
    checkImageExistsFlag: self.perCluster.checkImageExistsFlag[estate],
    httpsDisableCertsCheck: self.perCluster.httpsDisableCertsCheck[estate],
    
    estate: estate,
    kingdom: kingdom,

    controller: images.controller,
    watchdog: images.watchdog,
    manifest_watcher: images.manifest_watcher,
    k8sproxy: images.k8sproxy,
    sam_deployment_portal: images.sam_deployment_portal,
    samcontrol_deployer: images.samcontrol_deployer,
    permissionInitContainer: images.permissionInitContainer,
    samcontrol_deployer_ObserveMode: false,
    samcontrol_deployer_EmailNotify: true,
    sam_deployment_reporter: images.sam_deployment_reporter,

    sdn_bird: images.sdn_bird,
    sdn_peering_agent: images.sdn_peering_agent,
    sdn_watchdog: images.sdn_watchdog,
    sdn_vault_agent: images.sdn_vault_agent,

    slb_iface_agent: images.slb_iface_agent,
    slb_ipvs: images.slb_ipvs,
    slb_realsvrcfg: images.slb_realsvrcfg,
    slb_config_processor: images.slb_config_processor
}
