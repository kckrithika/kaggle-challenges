local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "sam-api-proxy",
    },
    data: {
        "sam-api-proxy.json": std.toString(import "configs/sam-api-proxy-config.jsonnet"),
    },
} else "SKIP"
