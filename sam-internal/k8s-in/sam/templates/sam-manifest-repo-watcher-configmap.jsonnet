local configs = import "config.jsonnet";
if configs.estate == "prd-sam" || configs.estate == "prd-samtwo" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sam-manifest-repo-watcher",
        labels: {} + configs.ownerLabel.sam,
        namespace: "sam-system",
    },
    data: {
        "sammanifestrepowatcher.json": std.toString(import "configs/sam-manifest-repo-watcher-config.jsonnet"),
    },
} else "SKIP"
