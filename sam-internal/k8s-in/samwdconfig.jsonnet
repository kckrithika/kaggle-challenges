{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",

shared_args: [
    "-timeout=2s",
    "-funnelEndpoint="+configs.funnelVIP,
    # TODO: Remove these next 3 when configMap is enabled everywhere
    "-rcImtEndpoint="+configs.rcImtEndpoint,
    "-smtpServer="+configs.smtpServer,
    "-sender="+configs.watchdog_emailsender,
    "-recipient="+configs.watchdog_emailrec,
] + if (kingdom == "prd" || kingdom == "frf" || kingdom == "yhu" || kingdom == "yul") then [
    "--config=/config/watchdog.json",
] else [],

shared_args_certs: [
    # TODO: Remove these next 4 when configMap is enabled everywhere
    "-tlsEnabled=true",
    "-caFile="+configs.caFile,
    "-keyFile="+configs.keyFile,
    "-certFile="+configs.certFile,
],

}
