local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local configs = import "config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
if !watchdog.watchdog_enabled || !std.objectHas(flowsnake_images.feature_flags, "btrfs_watchdog_hard_reset") then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "check-btrfs-sh",
      namespace: "flowsnake",
    },
    data: {
      "check-btrfs.sh": (importstr "check-btrfs.sh"),
    },
}
