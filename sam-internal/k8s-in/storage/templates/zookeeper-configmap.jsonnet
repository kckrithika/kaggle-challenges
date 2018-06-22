local configs = import "config.jsonnet";

if configs.estate == "prd-sam_storage" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "zookeeper-configmap",
      namespace: "sam-system",
    },
    data: {
      "3.4.9.json": std.toString(import "configs/zookeeper/prddev-3.4.9.jsonnet"),
      "3.4.9-zkGenConfig.json": std.toString(import "configs/zookeeper/prddev-3.4.9-zkGenConfig.jsonnet"),
    },
} else if configs.estate == "prd-skipper" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "zookeeper-configmap",
      namespace: "sam-system",
    },
    data: {
      "3.4.9.json": std.toString(import "configs/zookeeper/skpr-3.4.9.jsonnet"),
      "3.4.9-zkGenConfig.json": std.toString(import "configs/zookeeper/skpr-3.4.9-zkGenConfig.jsonnet"),
    },
} else "SKIP"
