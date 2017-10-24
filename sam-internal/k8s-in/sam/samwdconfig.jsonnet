{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",

shared_args: configs.filter_empty([
    "-timeout=2s",
    "-funnelEndpoint=" + configs.funnelVIP,
    "--config=/config/watchdog.json",
    configs.sfdchosts_arg,
]),
}
