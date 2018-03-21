local configs = import "config.jsonnet";
if configs.estate == "prd-samtest" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sam-manifest-repo-watcher",
        namespace: "sam-system",
    },
    data: {
        "sammanifestrepowatcher.json": std.toString(import "configs/sam-manifest-repo-watcher-config.jsonnet"),
    },
} else "SKIP"
