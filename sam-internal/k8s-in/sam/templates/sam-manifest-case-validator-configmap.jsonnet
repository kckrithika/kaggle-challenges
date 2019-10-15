local configs = import "config.jsonnet";
if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sam-manifest-case-validator",
        labels: {} + configs.ownerLabel.sam,
        namespace: "default",
    },
    data: {
        "sammanifestcasevalidator.json": std.toString(import "configs/sam-manifest-case-validator-config.jsonnet"),
    },
} else "SKIP"
