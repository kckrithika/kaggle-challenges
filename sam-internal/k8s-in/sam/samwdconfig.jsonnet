{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",

shared_args: [
    "-timeout=2s",
    "-funnelEndpoint="+configs.funnelVIP,
    "--config=/config/watchdog.json",
],
}
