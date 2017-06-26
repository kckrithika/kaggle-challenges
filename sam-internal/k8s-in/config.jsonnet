{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local engOrOps = (if self.kingdom == "prd" then "eng" else "ops"),

    perKingdom: {

        # We should try and compute kingdom level config and not require an entry per kingdom!

        # Why are some of these 1-4, some 2-2, some 1-2, and others 2-1???
        # TODO: Clean this up
        smtpServer: {
            "prd": "rd1-mta1-4-sfm.ops.sfdc.net:25",
            "dfw": "ops0-mta2-2-dfw.ops.sfdc.net:25",
            "phx": "ops0-mta1-2-phx.ops.sfdc.net:25",
            "frf": "ops0-mta2-1-frf.ops.sfdc.net:25",
            "par": "ops0-mta2-1-par.ops.sfdc.net:25",
            "yul": "ops0-mta2-1-yul.ops.sfdc.net:25",
            "yhu": "ops0-mta2-1-yhu.ops.sfdc.net:25",
            "iad": "ops0-mta2-1-iad.ops.sfdc.net:25",
            "ord": "ops0-mta2-1-ord.ops.sfdc.net:25",
            "ukb": "ops0-mta2-1-ukb.ops.sfdc.net:25"
        },

        momCollectorEndpoint: {
            "frf": "http://ops0-mom2-1-frf.ops.sfdc.net:8080/network/device?key=host-bgp-routes",
            "prd": "https://ops0-momapi1-0-prd.data.sfdc.net/network/device?key=host-bgp-routes",
        },

    },

    # Global

    caFile: "/data/certs/ca.crt",
    keyFile: "/data/certs/hostcert.key",
    certFile: "/data/certs/hostcert.crt",
    k8sapiserver: "",
    configPath: "/config/kubeconfig",

    watchdog_emailsender: "sam-alerts@salesforce.com",
    watchdog_emailrec: (if estate == "prd-sdc" then "sdn@salesforce.com" else "sam-alerts@salesforce.com"),

    # Computed values

    funnelVIP:(if kingdom == "par" || kingdom == "frf" then "mandm-funnel-"+kingdom+"1.data.sfdc.net:8080" else  "ajna0-funnel1-0-"+kingdom+".data.sfdc.net:80"),
    tnrpArchiveEndpoint: "https://ops0-piperepo1-1-"+kingdom+"."+engOrOps+".sfdc.net/tnrp/content_repo/0/archive",
    registry: (if kingdom == "prd" then "ops0-artifactrepo2-0-"+kingdom+".data.sfdc.net" else "ops0-artifactrepo1-0-"+kingdom+".data.sfdc.net"),
    rcImtEndpoint: (if kingdom == "dfw" then "http://shared0-samminionreportcollector1-1-dfw.ops.sfdc.net:18443/v1/bark" else "https://ops0-health1-1-"+kingdom+"."+engOrOps+".sfdc.net:18443/v1/bark"),

    # Pass-through below here only

    smtpServer: self.perKingdom.smtpServer[kingdom],
    momCollectorEndpoint: self.perKingdom.momCollectorEndpoint[kingdom],
    apiserver: self.perEstate.apiserver[estate],
    checkImageExistsFlag: "true",
    httpsDisableCertsCheck: "true",

    estate: estate,
    kingdom: kingdom,

    samcontrol_deployer_ObserveMode: false,
    samcontrol_deployer_EmailNotify: true,
    sam_secret_agent_ObserveMode: false,
}
