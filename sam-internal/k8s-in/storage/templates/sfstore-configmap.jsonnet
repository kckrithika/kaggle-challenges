local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfstore-configmap",
      namespace: "sam-system",
    },
    data: {
      "prd-1.10.json": std.toString(import "configs/prd-1.10.jsonnet"),
    },
} else if configs.estate == "prd-sam_storage" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "sfstore-configmap",
      namespace: "sam-system",
    },
    data: {
      "prddev-1.10.json": std.toString(import "configs/prddev-1.10.jsonnet"),
    },
} else if configs.estate == "prd-skipper" then {
        kind: "ConfigMap",
        apiVersion: "v1",
        metadata: {
                name: "sfstore-configmap",
                namespace: "sam-system",
        },
        data: {
                "skpr-1.10.json": std.toString(import "configs/skpr-1.10.jsonnet"),
        },
} else "SKIP"
