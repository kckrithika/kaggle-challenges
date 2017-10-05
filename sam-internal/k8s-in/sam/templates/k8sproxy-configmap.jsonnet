local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "k8sproxy",
      namespace: "sam-system",
    },
    data: {
      "haproxy-maddog.cfg": std.toString(importstr "configs/haproxy-maddog.cfg") + configs.chainFile
    }
} else "SKIP"
