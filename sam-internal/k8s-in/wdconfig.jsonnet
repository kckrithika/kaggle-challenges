{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",

shared_args: [
    "-timeout=2s",
    "-funnelEndpoint="+configs.funnelVIP,
    "-rcImtEndpoint="+configs.rcImtEndpoint,
    "-smtpServer="+configs.smtpServer,
    "-sender="+configs.watchdog_emailsender,
    "-recipient="+configs.watchdog_emailrec,
],

shared_args_certs: [
    "-tlsEnabled="+configs.tlsEnabled,
    "-caFile="+configs.caFile,
    "-keyFile="+configs.keyFile,
    "-certFile="+configs.certFile,
],

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

kube_config_volume_mount: {
    "mountPath": "/config",
    "name": "config"
},

kube_config_volume: {
    hostPath: {
        path: "/etc/kubernetes"
    },
    name: "config"
},

}
