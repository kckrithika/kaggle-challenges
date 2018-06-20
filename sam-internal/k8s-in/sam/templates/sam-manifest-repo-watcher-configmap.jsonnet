local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sam-manifest-repo-watcher",
        namespace: "sam-system",
        labels: {} + if configs.estate == "prd-samdev" then {
                owner: "sam",
              } else {},
    },
    data: {
        "sammanifestrepowatcher.json": std.toString(import "configs/sam-manifest-repo-watcher-config.jsonnet"),
    },
} else "SKIP"
