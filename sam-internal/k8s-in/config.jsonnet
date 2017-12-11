#
# NOTE: This file should contain the minimum set of shared data needed by the different teams (SAM, SLB, SDN, etc...)
# Do not put team-specific configuration here.  We should keep this file as small as possible.
#
{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local engOrOps = (if self.kingdom == "prd" then "eng" else "ops"),
local utils = import "util_functions.jsonnet",

    # === DISCOVERY ===

    # External services we need to talk to that are different in different kingdoms

    perKingdom: {

        # We should try and compute kingdom level config and not require an entry per kingdom!

        # Why are some of these 1-4, some 2-2, some 1-2, and others 2-1???
        # TODO: Clean this up
        smtpServer: {
            prd: "rd1-mta1-4-sfm.ops.sfdc.net:25",
            dfw: "ops0-mta2-2-dfw.ops.sfdc.net:25",
            phx: "ops0-mta1-2-phx.ops.sfdc.net:25",
            frf: "ops0-mta2-1-frf.ops.sfdc.net:25",
            par: "ops0-mta2-1-par.ops.sfdc.net:25",
            yul: "ops0-mta2-1-yul.ops.sfdc.net:25",
            yhu: "ops0-mta2-1-yhu.ops.sfdc.net:25",
            iad: "ops0-mta2-1-iad.ops.sfdc.net:25",
            ord: "ops0-mta2-1-ord.ops.sfdc.net:25",
            ukb: "ops0-mta2-1-ukb.ops.sfdc.net:25",
            hnd: "ops0-mta2-1-hnd.ops.sfdc.net:25",
            cdu: "ops0-mta2-1-cdu.ops.sfdc.net:25",
            syd: "ops0-mta2-1-syd.ops.sfdc.net:25",
            chx: "ops-mta1-4-chx.ops.sfdc.net:25",
            wax: "ops-mta1-4-wax.ops.sfdc.net:25",
        },

        # TODO: remove mom and charon endpoint to sdn-config
        charonEndpoint: {
            prd: "http://sds2-polcore2-2-prd.eng.sfdc.net:9443/minions",
        },

            zookeeperip: {
                prd: "shared0-discovery1-0-sfm.data.sfdc.net:2181",
            },

    },

    # Pass-through for the kingdom specific stuff above

    smtpServer: self.perKingdom.smtpServer[kingdom],
    momCollectorEndpoint: self.perKingdom.momCollectorEndpoint[kingdom],
    charonEndpoint: self.perKingdom.charonEndpoint[kingdom],
    zookeeperip: self.perKingdom.zookeeperip[kingdom],

    # Other discovery related things

    funnelVIP: (if kingdom == "par" || kingdom == "frf" then "mandm-funnel-" + kingdom + "1.data.sfdc.net:8080" else "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net:80"),
    tnrpArchiveEndpoint: (
    if kingdom == "par" || kingdom == "prd" || kingdom == "phx" then
        "https://ops0-piperepo1-0-" + kingdom + ".data.sfdc.net/tnrp/content_repo/0/archive"
    else if utils.is_gia(kingdom) then
        "https://ops-piperepo1-0-" + kingdom + ".data.sfdc.net/tnrp/content_repo/0/archive"
    else
        "https://ops0-piperepo1-1-" + kingdom + "." + engOrOps + ".sfdc.net/tnrp/content_repo/0/archive"
    ),
    registry: (
    if kingdom == "prd" then
        "ops0-artifactrepo2-0-" + kingdom + ".data.sfdc.net"
    else if utils.is_gia(kingdom) then
        "ops-artifactrepo1-0-" + kingdom + ".data.sfdc.net"
    else
        "ops0-artifactrepo1-0-" + kingdom + ".data.sfdc.net"
    ),
    rcImtEndpoint: (if kingdom == "dfw" then "http://shared0-samminionreportcollector1-1-dfw.ops.sfdc.net:18443/v1/bark" else "https://reportcollector-" + kingdom + ".data.sfdc.net:18443/v1/bark"),

    # === KUBERNETES ===

    # For things like volumes, volume_mounts and args, we want to be able to define a new entry centrally (config.jsonnet)
    # but to roll it out gradually.  Since each template has a list for these items, we have 2 bad options:
    #  1) Add an if statement for each template (several dozen)
    #  2) Add the items and a second list that conditionally contains those items centrally, then add them in the templates
    # by using this helper function, the central config can define an item that is {} when not in use, and this will remove it from output list
    filter_empty(in_list):: [i for i in in_list if i != {}],

    # Commonly used elements for kubernetes resources

    # For use by apps that talk to the Kube API server using the host's kubeConfig
    kube_config_env: {
        name: "KUBECONFIG",
        value: (if kingdom == "prd" || kingdom == "frf" then "/kubeconfig/kubeconfig-platform" else "/kubeconfig/kubeconfig"),
    },
    kube_config_volume_mount: {
        mountPath: "/kubeconfig",
        name: "kubeconfig",
    },
    kube_config_volume: {
        hostPath: {
            path: "/etc/kubernetes",
        },
        name: "kubeconfig",
    },

    # For Cleaning up SLB logs or other Random mounts to be used for ops-adhoc DaemonSet
    opsadhoc_volume_mount: {
        mountPath: "/slb",
        name: "slblogs",
    },
    opsadhoc_volume: {
        hostPath: {
            path: "/var/slb/logs",
        },
        name: "slblogs",
    },

    # For use by apps that read the host's certs from Certificate Services
    cert_volume_mount: {
        mountPath: "/data/certs",
        name: "certs",
    },
    cert_volume: {
        hostPath: {
            path: "/data/certs",
        },
        name: "certs",
    },
    caFile: (
        if !utils.is_public_cloud(kingdom) && !utils.is_gia(kingdom) then
            "/etc/pki_service/ca/cabundle.pem"
        else
            "/data/certs/ca.crt"
    ),
    keyFile: (
        if estate == "prd-samtest" || estate == "prd-samdev" || estate == "prd-sam" then
            "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem"
        else if utils.is_flowsnake_cluster(estate) then
            "/etc/pki_service/kubernetes/k8s-client/keys/k8s-client-key.pem"
        else
            "/data/certs/hostcert.key"
    ),
    certFile: (
        if estate == "prd-samtest" || estate == "prd-samdev" || estate == "prd-sam" then
            "/etc/pki_service/platform/platform-client/certificates/platform-client.pem"
        else if utils.is_flowsnake_cluster(estate) then
            "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem"
        else
            "/data/certs/hostcert.crt"
    ),
    chainFile: (
        if estate == "prd-samtest" || estate == "prd-samdev" || estate == "prd-sam" then
            "/etc/pki_service/kubernetes/chain-client.pem"
        else
            "/etc/certs/hostcert-chain.pem"
    ),
    maddogServerCAPath: "/etc/pki_service/ca/security-ca.pem",

    # For apps that read MadDog certs from the host
    maddog_cert_volume_mount: (if !utils.is_public_cloud(kingdom) && !utils.is_gia(kingdom) then
    {
        mountPath: "/etc/pki_service",
        name: "maddog-certs",
    } else {}),
    maddog_cert_volume: (if !utils.is_public_cloud(kingdom) && !utils.is_gia(kingdom) then
    {
        hostPath: {
            path: "/etc/pki_service",
        },
        name: "maddog-certs",
    } else {}),

    # For apps that use liveConfig + configMap for configuration
    config_volume_mount: {
        mountPath: "/config",
        name: "config",
    },
    config_volume(configMap):: {
        name: "config",
        configMap: {
            name: configMap,
        },
    },

    # [xiao] For testing CRD in prd
    endpoint: (
        if estate == "prd-samtest" then
            "test-manifests"
    ),

    # For apps that use sfdcLocation2
    sfdchosts_volume_mount: {
        mountPath: "/sfdchosts",
        name: "sfdchosts",
    },
    sfdchosts_volume: {
        name: "sfdchosts",
        configMap: {
            name: "sfdchosts",
        },
    },
    # [thargrove] New build has the deadlock fix.  Starting the slow roll again
    sfdchosts_arg: (if kingdom == "prd" || kingdom == "frf" || kingdom == "ord" then "--hostsConfigFile=/sfdchosts/hosts.json" else {}),

    # === OTHER ===

    # These are here so files that include this jsonnet can easily access estate/kingdom.
    # Please dont add any more here.  We want to reduce coupling to this global config.

    estate: estate,
    kingdom: kingdom,
}
