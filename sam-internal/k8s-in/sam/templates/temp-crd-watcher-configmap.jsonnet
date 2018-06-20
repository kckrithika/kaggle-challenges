local configs = import "config.jsonnet";

if configs.kingdom == "prd" then
    {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
            name: "temp-crd-watcher",
            namespace: "sam-system",
            labels: {} + if configs.estate == "prd-samdev" then {
                    owner: "sam",
                  } else {},
        },
        data: {
            "tempmanifestwatcher.json": std.toString(import "configs/temp-crd-watcher-config.jsonnet"),
        },
    } else "SKIP"
