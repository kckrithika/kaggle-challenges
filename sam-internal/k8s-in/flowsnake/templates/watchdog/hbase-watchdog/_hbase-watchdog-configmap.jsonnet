local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local hbasewatchdog = import "hbase-watchdog.libsonnet";
if watchdog.watchdog_enabled && flowsnakeconfig.hbase_enabled then
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "hbase-watchdog",
      namespace: "flowsnake",
    },
    data: {
      "hbase-watchdog.json": std.toString(hbasewatchdog.watchdog_config),
    },
}
else
"SKIP"
