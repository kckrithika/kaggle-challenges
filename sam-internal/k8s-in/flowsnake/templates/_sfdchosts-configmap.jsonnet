local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
if !(flowsnakeconfig.node_monitor_enabled || watchdog.watchdog_enabled) then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfdchosts",
      namespace: "flowsnake",
    },
    data: {
      "hosts.json": std.toString(import "flowsnake_hosts.jsonnet"),
    },
}
