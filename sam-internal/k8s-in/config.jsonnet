#
# NOTE: This file should contain the minimum set of shared data needed by the different teams (SAM, SLB, SDN, etc...)
# Do not put team-specific configuration here.  We should keep this file as small as possible.
#
{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local engOrOps = (if self.kingdom == "prd" then "eng" else "ops"),

    # === DISCOVERY ===

    # External services we need to talk to that are different in different kingdoms

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
            "ukb": "ops0-mta2-1-ukb.ops.sfdc.net:25",
            "hnd": "ops0-mta2-1-hnd.ops.sfdc.net:25",
            "cdu": "ops0-mta2-1-cdu.ops.sfdc.net:25",
            "syd": "ops0-mta2-1-syd.ops.sfdc.net:25",
        },

        momCollectorEndpoint: {
            "dfw": "http://ops0-mom2-1-dfw.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "frf": "http://ops0-mom2-1-frf.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "hnd": "http://ops0-mom2-1-hnd.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "iad": "http://ops0-mom2-1-iad.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "ord": "http://ops0-mom2-1-ord.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "par": "http://ops0-mom2-1-par.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "phx": "http://ops0-mom2-1-phx.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "prd": "http://ops0-mom2-1-prd.eng.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
            "ukb": "http://ops0-mom2-1-ukb.ops.sfdc.net:8080/api/v1/network/device?key=host-bgp-routes",
        },

        # TODO: remove mom and charon endpoint to sdn-config
        charonEndpoint: {
            "prd": "http://sds2-polcore2-2-prd.eng.sfdc.net:9443/minions",
        },

	    zookeeperip : {
	        "prd" : "shared0-discovery1-0-sfm.data.sfdc.net:2181",
	    },

    },

    # Pass-through for the kingdom specific stuff above

    smtpServer: self.perKingdom.smtpServer[kingdom],
    momCollectorEndpoint: self.perKingdom.momCollectorEndpoint[kingdom],
    charonEndpoint: self.perKingdom.charonEndpoint[kingdom],
    zookeeperip: self.perKingdom.zookeeperip[kingdom],

    # Other discovery related things

    funnelVIP:(if kingdom == "par" || kingdom == "frf" then "mandm-funnel-"+kingdom+"1.data.sfdc.net:8080" else  "ajna0-funnel1-0-"+kingdom+".data.sfdc.net:80"),
    tnrpArchiveEndpoint: (if kingdom == "par" || kingdom == "prd" || kingdom == "phx" then "https://ops0-piperepo1-0-"+kingdom+".data.sfdc.net/tnrp/content_repo/0/archive" else "https://ops0-piperepo1-1-"+kingdom+"."+engOrOps+".sfdc.net/tnrp/content_repo/0/archive"),
    registry: (if kingdom == "prd" then "ops0-artifactrepo2-0-"+kingdom+".data.sfdc.net" else "ops0-artifactrepo1-0-"+kingdom+".data.sfdc.net"),
    rcImtEndpoint: (if kingdom == "dfw" then "http://shared0-samminionreportcollector1-1-dfw.ops.sfdc.net:18443/v1/bark" else "https://ops0-health1-1-"+kingdom+"."+engOrOps+".sfdc.net:18443/v1/bark"),

    # === KUBERNETES ===

    # Commonly used elements for kubernetes resources

    # For use by apps that talk to the Kube API server using the host's kubeConfig
    kube_config_env: {
        "name": "KUBECONFIG",
        "value": "/kubeconfig/kubeconfig"
    },
    kube_config_volume_mount: {
        "mountPath": "/kubeconfig",
        "name": "kubeconfig"
    },
    kube_config_volume: {
        hostPath: {
            path: "/etc/kubernetes"
        },
        name: "kubeconfig"
    },

    # For use by apps that read the host's certs from Certificate Services
    cert_volume_mount: {
        "mountPath": "/data/certs",
        "name": "certs"
    },
    cert_volume: {
        hostPath: {
            path: "/data/certs"
        },
        name: "certs"
    },
    caFile: (
        if estate == "prd-samtest" || estate == "prd-sam" || estate == "prd-samdev" then
            "/etc/pki_service/ca/cabundle.pem"
        else
            "/data/certs/ca.crt"
    ),
    maddogServerCAPath: "/etc/pki_service/ca/security-ca.pem",
    keyFile: "/data/certs/hostcert.key",
    certFile: "/data/certs/hostcert.crt",

    # For apps that read MadDog certs from the host
    maddog_cert_volume_mount: {
        "mountPath": "/etc/pki_service",
        "name": "maddog-certs"
    },
    maddog_cert_volume: {
        hostPath: {
            path: "/etc/pki_service"
        },
        name: "maddog-certs"
    },

    # Cert volume list
    cert_volume_mounts: (
        if kingdom == "prd" then
            [self.maddog_cert_volume_mount]
        else
            []
    ),
    cert_volumes: (
        if kingdom == "prd" then
            [self.maddog_cert_volume]
        else
            []
    ),

    # For apps that use liveConfig + configMap for configuration
    config_volume_mount: {
        "mountPath": "/config",
        "name": "config",
    },
    config_volume(configMap):: {
        name: "config",
        configMap: {
            name: configMap,
        }
    },

    # === OTHER ===

    # These are here so files that include this jsonnet can easily access estate/kingdom.
    # Please dont add any more here.  We want to reduce coupling to this global config.

    estate: estate,
    kingdom: kingdom,
}
