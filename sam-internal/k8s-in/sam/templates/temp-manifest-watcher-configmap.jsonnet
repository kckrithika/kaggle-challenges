local configs = import "config.jsonnet";

if configs.kingdom == "prd" then
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "temp-manifest-watcher",
      namespace: "sam-system",
    },
    data: {
      "tempmanifestwatcher.json": std.toString(import "configs/temp-manifest-watcher-config.jsonnet"),
    },
} else "SKIP"
