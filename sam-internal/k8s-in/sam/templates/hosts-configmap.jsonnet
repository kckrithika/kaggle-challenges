local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "hosts",
      namespace: "sam-system",
    },
    data: {
      "hosts.json": std.toString(import "configs/hosts.jsonnet")
    }
} else 
  "SKIP"
