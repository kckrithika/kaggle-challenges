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
] + if (kingdom != "prd" || estate == "prd-sam") then [
    "-recipient="+configs.watchdog_emailrec,
] else [
    # For now turn off test bed emails
],

shared_args_certs: [
    "-tlsEnabled=true",
    "-caFile="+configs.caFile,
    "-keyFile="+configs.keyFile,
    "-certFile="+configs.certFile,
],

# TODO: Add these in next slice
#
#config_volume_mount: {
#    "mountPath": "/config",
#    "name": "config"
#},
#
#config_volume: {
#    name: "config",
#    configMap: {
#        name: "watchdog",
#    }
#},


}
