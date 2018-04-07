local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
{
    sdn_watchdog_emailsender: "sdn-alerts@salesforce.com",
    sdn_watchdog_emailrec: (if kingdom == "chx" || kingdom == "wax" || estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-samtwo" || estate == "prd-sam_storage" || estate == "prd-sdc" || estate == "prd-data-flowsnake_test" then "sdn@salesforce.com" else "sdn-alerts@salesforce.com"),
    sdn_route_watchdog_emailrec: "sdn@salesforce.com",

    # SDN MoM VIP Endpoints
    momVIP: "https://ops0-momapi1-0-" + kingdom + ".data.sfdc.net/api/v1/network/device?key=host-bgp-routes",

    # Charon/Nyx Endpoints
    charonEndpoint: "https://sds2-polcore2-2-" + kingdom + ".eng.sfdc.net:9443/minions",

    # SDN K8S Secret File path
    bgpPasswordFilePath: (
        if utils.is_flowsnake_cluster(estate) then
            "/data/secrets/flowsnakebgppassword"
        else
            "/data/secrets/sambgppassword"
    ),

    # File path for logs
    logFilePath: "/data/logs/sdn/",

    logDirArg: "--log_dir=" + self.logFilePath,
    logToStdErrArg: "--logtostderr=true",
    alsoLogToStdErrArg: "--alsologtostderr=true",

    elasticsearchUrl: "http://" + sdnconfigs.sdn_elasticsearch_cluster_ip + ":" + portconfigs.sdn.sdn_elasticsearch,

    # Volume for logs
    sdn_logs_volume: {},
    #Previously:
    #{
    #    name: "sdnlogs",
    #    hostPath: {
    #      path: "/data/logs/sdn",
    #    },
    #},

    # Volume mount for logs
    sdn_logs_volume_mount: {},
    #Previously:
    #{
    #    mountPath: "/data/logs/sdn",
    #    name: "sdnlogs",
    #},

    # Volume for logstash conf
    sdn_logstash_conf_volume: {
        name: "logstashconf",
        hostPath: {
            path: "/etc/logstash/conf.d",
        },
    },

    # Volume mount for logstash conf
    sdn_logstash_conf_volume_mount: {
        name: "logstashconf",
        mountPath: "/etc/logstash/conf.d",
    },

    # Volume for logstash certs
    sdn_logstash_certs_volume: {
        name: "logstashcerts",
        hostPath: {
            path: "/etc/logstash/certs",
        },
    },

    # Volume mount for logstash certs
    sdn_logstash_certs_volume_mount: {
        name: "logstashcerts",
        mountPath: "/etc/logstash/certs",
    },

    sdn_elasticsearch_cluster_ip: "10.254.219.223",

    # Volume for kubectl
    sdn_kubectl_volume: {
        name: "kubectl",
        hostPath: {
            path: "/usr/bin/kubectl",
        },
    },

    # Volume mount for kubectl
    sdn_kubectl_volume_mount: {
        name: "kubectl",
        mountPath: "/usr/bin/kubectl",
    },

    # Pool in which sdn_control_svc should run
    sdn_control_pool: (
        if estate == "prd-sdc" then
            estate
        else
            kingdom + "-sdn_control"
    ),

    # Make the sdnc run in master nodes (Temporary fix)
    sdn_master: (
        if estate == "prd-sdc" then
            "true"
        else
            "false"
    ),

    # DDIService Endpoint
    ddiService: (
        "https://ddi-api-crz.data.sfdc.net/"
    ),

    awsRegion: (
    if kingdom == "cdu" || kingdom == "syd" then
        "ap-southeast-2"
    else if kingdom == "yhu" || kingdom == "yul" then
        "ca-central-1"
    ),

    awsAZ: (
    if kingdom == "yul" then
        "ca-central-1a"
    else if kingdom == "yhu" then
        "ca-central-1b"
    else if kingdom == "cdu" then
        "ap-southeast-2c"
    else if kingdom == "syd" then
        "ap-southeast-2b"
    ),
}
